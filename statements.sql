SELECT u.username, w.session_id, w.start_time,
       w.target_hr_min, w.target_hr_max
FROM WorkoutSessions AS w
JOIN Users AS u ON w.user_id = u.user_id
ORDER BY u.username, w.start_time;

-- 8. Count how many playlists each user created. LEFT JOIN also keeps
--    users who have not made a playlist yet in the results.
SELECT u.user_id, u.username,
       COUNT(p.playlist_id) AS total_playlists
FROM Users AS u
LEFT JOIN Playlists AS p ON u.user_id = p.user_id
GROUP BY u.user_id, u.username
ORDER BY total_playlists DESC, u.username;

-- 9. Find workouts with an average heart rate above 110 BPM. We use
--    GROUP BY and HAVING because each workout has several readings.
SELECT w.session_id,
       ROUND(AVG(hr.heart_rate_bpm), 1) AS average_heart_rate,
       COUNT(hr.reading_id) AS total_readings
FROM WorkoutSessions AS w
JOIN WorkoutPhases AS wp ON w.session_id = wp.session_id
JOIN HeartRateReadings AS hr ON wp.phase_id = hr.phase_id
GROUP BY w.session_id
HAVING AVG(hr.heart_rate_bpm) > 110
ORDER BY average_heart_rate DESC;

-- 10. Show workout ratings and comments when they exist. LEFT JOIN
--     makes sure unrated workouts still appear in the results.
SELECT w.session_id, u.username,
       pr.performance_score, pr.comments
FROM WorkoutSessions AS w
JOIN Users AS u ON w.user_id = u.user_id
LEFT JOIN PerformanceRatings AS pr ON w.session_id = pr.session_id
ORDER BY w.session_id;

-- 11. Find songs that are faster than the overall average song tempo.
--     The smaller query first calculates the average for comparison.
SELECT song_id, title, artist, tempo_bpm
FROM Songs
WHERE tempo_bpm > (
    SELECT AVG(tempo_bpm)
    FROM Songs
)
ORDER BY tempo_bpm DESC, title;


-- COMPLEX STATEMENTS (12-16) !!!


-- 12. Find users who have at least one playlist with a song at or above
--     150 BPM. EXISTS checks that a matching playlist song is present.
SELECT u.user_id, u.username
FROM Users AS u
WHERE EXISTS (
    SELECT 1
    FROM Playlists AS p
    JOIN PlaylistSongs AS ps ON p.playlist_id = ps.playlist_id
    JOIN Songs AS s ON ps.song_id = s.song_id
    WHERE p.user_id = u.user_id
      AND s.tempo_bpm >= 150
)
ORDER BY u.username;

-- 13. Find songs that have never been recommended to anyone. NOT EXISTS
--     checks that there is no recommendation connected to each song.
SELECT s.song_id, s.title, s.artist
FROM Songs AS s
WHERE NOT EXISTS (
    SELECT 1
    FROM Recommendations AS r
    WHERE r.song_id = s.song_id
)
ORDER BY s.title;

-- 14. Make one list of Pop and Electronic songs without duplicates.
--     UNION combines the results of the two separate searches.
SELECT title, artist, genre
FROM Songs
WHERE genre = 'Pop'
UNION
SELECT title, artist, genre
FROM Songs
WHERE genre = 'Electronic'
ORDER BY title;

-- 15. Find the most recent heart-rate reading for every workout. The
--     CTE and ROW_NUMBER pick one reading, and CASE checks whether its
--     value is below, inside, or above that workout's target range.
WITH ranked_readings AS (
    SELECT w.session_id, w.target_hr_min, w.target_hr_max,
           hr.heart_rate_bpm, hr.recorded_at,
           ROW_NUMBER() OVER (
               PARTITION BY w.session_id
               ORDER BY hr.recorded_at DESC, hr.reading_id DESC
           ) AS reading_rank
    FROM WorkoutSessions AS w
    JOIN WorkoutPhases AS wp ON w.session_id = wp.session_id
    JOIN HeartRateReadings AS hr ON wp.phase_id = hr.phase_id
)
SELECT session_id, heart_rate_bpm, target_hr_min, target_hr_max,
       CASE
           WHEN heart_rate_bpm < target_hr_min THEN 'BELOW TARGET'
           WHEN heart_rate_bpm > target_hr_max THEN 'ABOVE TARGET'
           ELSE 'IN TARGET'
       END AS target_status
FROM ranked_readings
WHERE reading_rank = 1
ORDER BY session_id;

-- 16. Find song IDs that are in at least one playlist but have never
--     been recommended. EXCEPT removes the recommended IDs from the
--     list of songs saved in playlists.
SELECT song_id
FROM PlaylistSongs
EXCEPT
SELECT song_id
FROM Recommendations
ORDER BY song_id;
