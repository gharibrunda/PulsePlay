-- CSE 111 - PulsePlay Checkpoint 2
-- Roma's 16 assigned SQL statements: 6-10, 17-21, and 27-32.
-- These statements use the 9-table PulsePlay-schema-corrected.sql design.
--
-- Schema changes to document in the final combined Checkpoint2-script.sql:
-- The corrected schema replaces WorkoutSongs with PerformanceRatings,
-- connects Recommendations to WorkoutPhases, and changes some column names
-- and recommendation status values compared with our earlier Checkpoint 1 PDF.
-- The team should confirm this is the final approved schema before submitting.
--
-- Run this file against a POPULATED Checkpoint2-dbase.sqlite3 file.
-- The INSERT, UPDATE, and DELETE commands make changes to that database.

-- Turn on foreign-key checking so relationships stay valid during changes.
PRAGMA foreign_keys = ON;
.headers on
.mode column

-- SIMPLE STATEMENTS: 6-10

-- 6. Insert a new workout playlist for an existing user.
-- This gives us another playlist that can hold workout songs.
INSERT INTO Playlists (playlist_id, user_id, playlist_name)
VALUES (91006, 1, 'PulsePlay Practice Mix')
ON CONFLICT(playlist_id) DO NOTHING;
-- 7. Insert a new sample song into our song catalog.
-- Its tempo is 124 BPM, which could work for a steady workout.
INSERT INTO Songs (song_id, title, artist, genre, tempo_bpm)
VALUES (91007, 'Workout Test Track', 'PulsePlay Demo', 'Electronic', 124)
ON CONFLICT(song_id) DO NOTHING;

-- 8. Update the name of the practice playlist we just created.
-- We only change the playlist with the matching ID.
UPDATE Playlists
SET playlist_name = 'PulsePlay Updated Practice Mix'
WHERE playlist_id = 91006;

-- 9. Update the sample song's tempo from 124 BPM to 132 BPM.
-- This shows how we can correct a song's information later.
UPDATE Songs
SET tempo_bpm = 132
WHERE song_id = 91007;

-- 10. Delete the temporary test song after using it for practice.
-- We leave all the real sample songs in the database unchanged.
DELETE FROM Songs
WHERE song_id = 91007;

-- INTERMEDIATE STATEMENTS: 17-21

-- 17. Show each recommendation with its song and workout information.
-- The joins help us see who worked out, which phase they were in, and what song was suggested.
SELECT r.recommendation_id,
       u.username,
       w.session_id,
       wp.phase_name,
       s.title AS song_title,
       s.artist,
       s.tempo_bpm,
       r.status,
       r.recommended_at
FROM Recommendations AS r
JOIN Songs AS s ON r.song_id = s.song_id
JOIN WorkoutPhases AS wp ON r.phase_id = wp.phase_id
JOIN WorkoutSessions AS w ON wp.session_id = w.session_id
JOIN Users AS u ON w.user_id = u.user_id
ORDER BY r.recommendation_id;

-- 18. Show the performance scores users gave their workout sessions.
-- We also include their comments to see how the workouts went.
SELECT u.username,
       w.session_id,
       w.start_time,
       pr.performance_score,
       pr.comments
FROM PerformanceRatings AS pr
JOIN WorkoutSessions AS w ON pr.session_id = w.session_id
JOIN Users AS u ON w.user_id = u.user_id
ORDER BY u.username, w.start_time;

-- 19. Count how many times each song has been recommended.
-- We list the most recommended songs first and only show songs with at least one recommendation.
SELECT s.song_id,
       s.title,
       s.artist,
       COUNT(r.recommendation_id) AS recommendation_count
FROM Songs AS s
JOIN Recommendations AS r ON s.song_id = r.song_id
GROUP BY s.song_id, s.title, s.artist
HAVING COUNT(r.recommendation_id) > 0
ORDER BY recommendation_count DESC, s.title
LIMIT 10;

-- 20. Show workout sessions and the phases that belong to them.
-- A LEFT JOIN keeps a session in the results even if it does not have any phases yet.
SELECT w.session_id,
       u.username,
       w.start_time AS workout_start,
       wp.phase_id,
       wp.phase_name,
       wp.start_time AS phase_start,
       wp.end_time AS phase_end
FROM WorkoutSessions AS w
JOIN Users AS u ON w.user_id = u.user_id
LEFT JOIN WorkoutPhases AS wp ON w.session_id = wp.session_id
ORDER BY w.session_id, wp.start_time;

-- 21. Find users who have completed more workout sessions than the average user.
-- The subquery finds the average session count, and HAVING compares each user against it.
SELECT u.user_id,
       u.username,
       COUNT(w.session_id) AS total_sessions
FROM Users AS u
LEFT JOIN WorkoutSessions AS w ON u.user_id = w.user_id
GROUP BY u.user_id, u.username
HAVING COUNT(w.session_id) > (
    SELECT AVG(session_count)
    FROM (
        SELECT COUNT(ws.session_id) AS session_count
        FROM Users AS u2
        LEFT JOIN WorkoutSessions AS ws ON u2.user_id = ws.user_id
        GROUP BY u2.user_id
    ) AS session_totals
)
ORDER BY total_sessions DESC, u.username;


-- COMPLEX STATEMENTS: 27-32


-- 27. Combine songs saved in playlists with songs that have been recommended.
-- UNION puts the two kinds of song information into one result without repeating the same source entry.
SELECT s.song_id, s.title, s.artist, 'IN PLAYLIST' AS song_source
FROM Songs AS s
WHERE EXISTS (
    SELECT 1 FROM PlaylistSongs AS ps WHERE ps.song_id = s.song_id
)
UNION
SELECT s.song_id, s.title, s.artist, 'RECOMMENDED' AS song_source
FROM Songs AS s
WHERE EXISTS (
    SELECT 1 FROM Recommendations AS r WHERE r.song_id = s.song_id
)
ORDER BY title, song_source;

-- 28. Rank songs by how often they appear in the recommendation history.
-- The CTE counts recommendations, and DENSE_RANK gives matching counts the same rank.
WITH song_counts AS (
    SELECT s.song_id,
           s.title,
           COUNT(r.recommendation_id) AS recommendation_count
    FROM Songs AS s
    LEFT JOIN Recommendations AS r ON s.song_id = r.song_id
    GROUP BY s.song_id, s.title
)
SELECT song_id,
       title,
       recommendation_count,
       DENSE_RANK() OVER (ORDER BY recommendation_count DESC) AS song_rank
FROM song_counts
ORDER BY song_rank, title
LIMIT 15;

-- 29. Create a view that summarizes recommendations for every song.
-- It keeps totals for recommended, played, skipped, and rated songs so we can reuse them later.
CREATE VIEW IF NOT EXISTS PulsePlayRecommendationSummary AS
SELECT s.song_id,
       s.title,
       s.artist,
       COUNT(r.recommendation_id) AS total_recommendations,
       SUM(CASE WHEN r.status = 'PLAYED' THEN 1 ELSE 0 END) AS played_count,
       SUM(CASE WHEN r.status = 'SKIPPED' THEN 1 ELSE 0 END) AS skipped_count,
       SUM(CASE WHEN r.status = 'RATED' THEN 1 ELSE 0 END) AS rated_count,
       ROUND(AVG(r.user_rating), 2) AS average_user_rating
FROM Songs AS s
LEFT JOIN Recommendations AS r ON s.song_id = r.song_id
GROUP BY s.song_id, s.title, s.artist;

-- 30. Read the recommendation summary view created in statement 29.
-- We show the ten most recommended songs and their played, skipped, and rated totals.
SELECT song_id,
       title,
       total_recommendations,
       played_count,
       skipped_count,
       rated_count,
       average_user_rating
FROM PulsePlayRecommendationSummary
WHERE total_recommendations > 0
ORDER BY total_recommendations DESC, title
LIMIT 10;

-- 31. Create a trigger that updates a recommendation's status automatically.
-- If a new pending recommendation is added to a workout phase that already ended, it is marked as skipped.
CREATE TRIGGER IF NOT EXISTS PulsePlaySkipLateRecommendation
AFTER INSERT ON Recommendations
WHEN NEW.status = 'PENDING'
     AND EXISTS (
         SELECT 1
         FROM WorkoutPhases AS wp
         WHERE wp.phase_id = NEW.phase_id
           AND wp.end_time IS NOT NULL
     )
BEGIN
    UPDATE Recommendations
    SET status = 'SKIPPED'
    WHERE recommendation_id = NEW.recommendation_id;
END;

-- 32. Classify each heart-rate reading based on that workout's target range.
-- CASE labels each reading as below target, in target, or above target.
SELECT hr.reading_id,
       u.username,
       wp.phase_name,
       hr.heart_rate_bpm,
       w.target_hr_min,
       w.target_hr_max,
       CASE
           WHEN hr.heart_rate_bpm < w.target_hr_min THEN 'BELOW TARGET'
           WHEN hr.heart_rate_bpm > w.target_hr_max THEN 'ABOVE TARGET'
           ELSE 'IN TARGET'
       END AS heart_rate_category
FROM HeartRateReadings AS hr
JOIN WorkoutPhases AS wp ON hr.phase_id = wp.phase_id
JOIN WorkoutSessions AS w ON wp.session_id = w.session_id
JOIN Users AS u ON w.user_id = u.user_id
ORDER BY hr.reading_id
LIMIT 30;
