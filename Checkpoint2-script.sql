-- CSE 111 - Fall 2026 - Project Checkpoint 2
-- Project: PulsePlay - Workout Music Recommendation Database
-- Filename: Checkpoint2-script.sql
--
-- WHAT THIS SCRIPT DOES:
-- These queries show how the PulsePlay database stores users, workouts, songs,
-- playlists, heart-rate readings, song recommendations, and workout ratings.
-- There are 36 numbered SQL statements: 12 Simple, 12 Intermediate, 12 Complex.
-- All sample data is simulated and already included in Checkpoint2-dbase.sqlite3.
-- Run this script against that database (do not run it against an empty file).
--
-- SCHEMA REFINEMENTS SINCE THE EARLIER CHECKPOINT 1 PDF DRAFT:
-- We use the team's later PulsePlay-schema-corrected.sql definition (Oct 19).
-- This design uses PerformanceRatings instead of WorkoutSongs; keeps workout
-- ratings in PerformanceRatings rather than WorkoutSessions; and links
-- Recommendations to WorkoutPhases instead of directly to HeartRateReadings.
-- It also uses username, tempo_bpm, start_time/end_time, target_hr_min/max,
-- phase_name, and user_rating in place of the draft's earlier column names.
-- PlaylistSongs no longer stores added_at. Recommendation status values are
-- PENDING, PLAYED, SKIPPED, RATED, with ratings required only for RATED.
-- No additional relational schema changes were made after corrected SQL.
-- IMPORTANT: Confirm with your teammate which Checkpoint 1 version was submitted.
--
-- DATA CHANGES IN THIS SCRIPT:
-- Statements 9-11 demonstrate INSERT, UPDATE, DELETE on a temporary user.
-- Statement 23 demonstrates a conditional update on a pending recommendation.
-- Statement 35 creates a reusable view. The script is safe to rerun.
--
-- SQLite foreign keys are turned on for this connection.
PRAGMA foreign_keys = ON;

-- 01. Simple: Show each user and their email address in alphabetical order.
SELECT user_id, username, email
FROM Users
ORDER BY username;

-- 02. Simple: Find songs with a fast tempo of at least 145 BPM, with the fastest listed first.
SELECT song_id, title, artist, tempo_bpm
FROM Songs
WHERE tempo_bpm >= 145
ORDER BY tempo_bpm DESC, title;

-- 03. Simple: Find every song with a title that begins with the letter S.
SELECT title, artist, genre
FROM Songs
WHERE title LIKE 'S%'
ORDER BY title;

-- 04. Simple: Count the number of songs and calculate the average tempo in the catalog.
SELECT COUNT(*) AS total_songs, ROUND(AVG(tempo_bpm), 1) AS average_bpm
FROM Songs;

-- 05. Simple: Display users who have an example.com email address.
SELECT username, email
FROM Users
WHERE email LIKE '%@example.com'
ORDER BY user_id;

-- 06. Simple: Find playlists that include the word Cardio in their name.
SELECT playlist_id, playlist_name, created_at
FROM Playlists
WHERE playlist_name LIKE '%Cardio%'
ORDER BY created_at;

-- 07. Simple: Show completed workout sessions, starting with the most recent one.
SELECT session_id, user_id, start_time, end_time
FROM WorkoutSessions
WHERE end_time IS NOT NULL
ORDER BY start_time DESC;

-- 08. Simple: List heart-rate readings between 110 and 150 BPM.
SELECT reading_id, phase_id, recorded_at, heart_rate_bpm
FROM HeartRateReadings
WHERE heart_rate_bpm BETWEEN 110 AND 150
ORDER BY heart_rate_bpm DESC, reading_id;

-- 09. Simple: Add a temporary sample user to demonstrate INSERT. This ID does not conflict with the seeded users.
INSERT INTO Users (user_id, username, email)
VALUES (9001, 'checkpoint_demo', 'checkpoint_demo@example.com')
ON CONFLICT(user_id) DO NOTHING;

-- 10. Simple: Change the temporary user's email to demonstrate UPDATE.
UPDATE Users
SET email = 'checkpoint_demo_updated@example.com'
WHERE user_id = 9001;

-- 11. Simple: Remove the temporary user to demonstrate DELETE and leave the original user data unchanged.
DELETE FROM Users
WHERE user_id = 9001;

-- 12. Simple: Show the recommendations that have a user rating from 4 to 5.
SELECT recommendation_id, song_id, status, user_rating
FROM Recommendations
WHERE user_rating BETWEEN 4 AND 5
ORDER BY user_rating DESC, recommendation_id;

-- ===========================================================================
-- INTERMEDIATE QUERIES (12 STATEMENTS)
-- ===========================================================================

-- 13. Intermediate: Show each playlist along with the username of the person who created it.
SELECT p.playlist_id, p.playlist_name, u.username
FROM Playlists AS p
INNER JOIN Users AS u ON p.user_id = u.user_id
ORDER BY u.username, p.playlist_name;

-- 14. Intermediate: List the songs in each playlist, including song title, genre, and BPM.
SELECT p.playlist_name, s.title, s.genre, s.tempo_bpm
FROM PlaylistSongs AS ps
JOIN Playlists AS p ON ps.playlist_id = p.playlist_id
JOIN Songs AS s ON ps.song_id = s.song_id
ORDER BY p.playlist_id, s.tempo_bpm DESC;

-- 15. Intermediate: Show each workout and its owner, including the selected heart-rate target range.
SELECT w.session_id, u.username, w.start_time, w.target_hr_min, w.target_hr_max
FROM WorkoutSessions AS w
JOIN Users AS u ON w.user_id = u.user_id
ORDER BY w.session_id;

-- 16. Intermediate: List workout phases with the session and username they belong to.
SELECT u.username, wp.session_id, wp.phase_name, wp.start_time, wp.end_time
FROM WorkoutPhases AS wp
JOIN WorkoutSessions AS w ON wp.session_id = w.session_id
JOIN Users AS u ON w.user_id = u.user_id
ORDER BY wp.session_id, wp.start_time;

-- 17. Intermediate: Count how many playlists each user has, including users with no playlists.
SELECT u.user_id, u.username, COUNT(p.playlist_id) AS playlist_count
FROM Users AS u
LEFT JOIN Playlists AS p ON u.user_id = p.user_id
GROUP BY u.user_id, u.username
ORDER BY playlist_count DESC, u.username;

-- 18. Intermediate: Show all workout sessions and any performance rating left by the user.
SELECT w.session_id, u.username, pr.performance_score, pr.comments
FROM WorkoutSessions AS w
JOIN Users AS u ON u.user_id = w.user_id
LEFT JOIN PerformanceRatings AS pr ON pr.session_id = w.session_id
ORDER BY w.session_id;

-- 19. Intermediate: Display recommendations with the song, workout phase, and workout owner.
SELECT r.recommendation_id, u.username, wp.phase_name,
       s.title, s.tempo_bpm, r.status
FROM Recommendations AS r
JOIN Songs AS s ON s.song_id = r.song_id
JOIN WorkoutPhases AS wp ON wp.phase_id = r.phase_id
JOIN WorkoutSessions AS w ON w.session_id = wp.session_id
JOIN Users AS u ON u.user_id = w.user_id
ORDER BY r.recommendation_id;

-- 20. Intermediate: Count the songs in each genre and include genres with at least four songs.
SELECT genre, COUNT(*) AS song_count, ROUND(AVG(tempo_bpm), 1) AS average_bpm
FROM Songs
GROUP BY genre
HAVING COUNT(*) >= 4
ORDER BY song_count DESC, genre;

-- 21. Intermediate: Calculate the average heart rate of each session and show sessions with an average above 110 BPM.
SELECT w.session_id, ROUND(AVG(hr.heart_rate_bpm), 1) AS average_heart_rate,
       COUNT(hr.reading_id) AS reading_count
FROM WorkoutSessions AS w
JOIN WorkoutPhases AS wp ON wp.session_id = w.session_id
JOIN HeartRateReadings AS hr ON hr.phase_id = wp.phase_id
GROUP BY w.session_id
HAVING AVG(hr.heart_rate_bpm) > 110
ORDER BY average_heart_rate DESC;

-- 22. Intermediate: Find songs with a tempo higher than the average tempo across all songs.
SELECT song_id, title, tempo_bpm
FROM Songs
WHERE tempo_bpm > (SELECT AVG(tempo_bpm) FROM Songs)
ORDER BY tempo_bpm DESC, title;

-- 23. Intermediate: Change one pending recommendation to played, but only if it is still pending.
UPDATE Recommendations
SET status = 'PLAYED'
WHERE recommendation_id = 1 AND status = 'PENDING';

-- 24. Intermediate: Show how many recommendations each song received, including songs never recommended.
SELECT s.song_id, s.title, COUNT(r.recommendation_id) AS times_recommended
FROM Songs AS s
LEFT JOIN Recommendations AS r ON r.song_id = s.song_id
GROUP BY s.song_id, s.title
ORDER BY times_recommended DESC, s.title;

-- ===========================================================================
-- COMPLEX QUERIES (12 STATEMENTS)
-- ===========================================================================

-- 25. Complex: Find users who own at least one playlist containing a song of 150 BPM or faster.
SELECT u.user_id, u.username
FROM Users AS u
WHERE EXISTS (
    SELECT 1
    FROM Playlists AS p
    JOIN PlaylistSongs AS ps ON ps.playlist_id = p.playlist_id
    JOIN Songs AS s ON s.song_id = ps.song_id
    WHERE p.user_id = u.user_id AND s.tempo_bpm >= 150
)
ORDER BY u.username;

-- 26. Complex: Find catalog songs that have never appeared in any recommendation.
SELECT s.song_id, s.title, s.artist
FROM Songs AS s
WHERE NOT EXISTS (
    SELECT 1 FROM Recommendations AS r WHERE r.song_id = s.song_id
)
ORDER BY s.title;

-- 27. Complex: Combine the titles of Pop songs and Electronic songs into one distinct list.
SELECT title, artist, genre FROM Songs WHERE genre = 'Pop'
UNION
SELECT title, artist, genre FROM Songs WHERE genre = 'Electronic'
ORDER BY title;

-- 28. Complex: Find song IDs that are both saved in at least one playlist and have been recommended.
SELECT song_id FROM PlaylistSongs
INTERSECT
SELECT song_id FROM Recommendations
ORDER BY song_id;

-- 29. Complex: Find songs saved in playlists that have not yet been recommended.
SELECT s.song_id, s.title
FROM Songs AS s
WHERE s.song_id IN (
    SELECT song_id FROM PlaylistSongs
    EXCEPT
    SELECT song_id FROM Recommendations
)
ORDER BY s.song_id;

-- 30. Complex: Use a CTE to find the latest heart-rate reading in every workout and compare it with that workout's selected target range.
WITH latest_readings AS (
    SELECT w.session_id, w.target_hr_min, w.target_hr_max,
           hr.heart_rate_bpm, hr.recorded_at,
           ROW_NUMBER() OVER (PARTITION BY w.session_id
                              ORDER BY hr.recorded_at DESC, hr.reading_id DESC) AS rn
    FROM WorkoutSessions AS w
    JOIN WorkoutPhases AS wp ON wp.session_id = w.session_id
    JOIN HeartRateReadings AS hr ON hr.phase_id = wp.phase_id
)
SELECT session_id, heart_rate_bpm, target_hr_min, target_hr_max,
       CASE WHEN heart_rate_bpm < target_hr_min THEN 'BELOW TARGET'
            WHEN heart_rate_bpm > target_hr_max THEN 'ABOVE TARGET'
            ELSE 'IN TARGET' END AS heart_rate_status
FROM latest_readings
WHERE rn = 1
ORDER BY session_id;

-- 31. Complex: Use multiple CTEs to compare each user's average session heart rate with their workout count.
WITH session_averages AS (
    SELECT w.session_id, w.user_id, AVG(hr.heart_rate_bpm) AS session_avg
    FROM WorkoutSessions AS w
    JOIN WorkoutPhases AS wp ON wp.session_id = w.session_id
    JOIN HeartRateReadings AS hr ON hr.phase_id = wp.phase_id
    GROUP BY w.session_id, w.user_id
), user_summary AS (
    SELECT user_id, COUNT(*) AS workout_count,
           ROUND(AVG(session_avg), 1) AS mean_session_hr
    FROM session_averages
    GROUP BY user_id
)
SELECT u.username, us.workout_count, us.mean_session_hr
FROM user_summary AS us
JOIN Users AS u ON u.user_id = us.user_id
ORDER BY us.mean_session_hr DESC;

-- 32. Complex: Rank songs by tempo inside each genre and show the two fastest songs from each genre.
WITH ranked_songs AS (
    SELECT song_id, genre, title, tempo_bpm,
           ROW_NUMBER() OVER (PARTITION BY genre ORDER BY tempo_bpm DESC, title) AS tempo_rank
    FROM Songs
)
SELECT genre, title, tempo_bpm, tempo_rank
FROM ranked_songs
WHERE tempo_rank <= 2
ORDER BY genre, tempo_rank;

-- 33. Complex: Rank the users by their number of saved playlist songs, allowing ties to share a rank.
WITH playlist_sizes AS (
    SELECT u.user_id, u.username, COUNT(ps.song_id) AS saved_songs
    FROM Users AS u
    LEFT JOIN Playlists AS p ON p.user_id = u.user_id
    LEFT JOIN PlaylistSongs AS ps ON ps.playlist_id = p.playlist_id
    GROUP BY u.user_id, u.username
)
SELECT username, saved_songs,
       DENSE_RANK() OVER (ORDER BY saved_songs DESC) AS activity_rank
FROM playlist_sizes
ORDER BY activity_rank, username;

-- 34. Complex: Classify recommendation outcomes and show the count in each outcome category using CASE.
SELECT CASE WHEN status = 'RATED' AND user_rating >= 4 THEN 'HIGHLY RATED'
            WHEN status = 'RATED' THEN 'LOW RATED'
            WHEN status = 'PLAYED' THEN 'PLAYED WITHOUT RATING'
            WHEN status = 'SKIPPED' THEN 'SKIPPED'
            ELSE 'AWAITING ACTION' END AS outcome,
       COUNT(*) AS outcome_count
FROM Recommendations
GROUP BY CASE WHEN status = 'RATED' AND user_rating >= 4 THEN 'HIGHLY RATED'
              WHEN status = 'RATED' THEN 'LOW RATED'
              WHEN status = 'PLAYED' THEN 'PLAYED WITHOUT RATING'
              WHEN status = 'SKIPPED' THEN 'SKIPPED'
              ELSE 'AWAITING ACTION' END
ORDER BY outcome_count DESC, outcome;

-- 35. Complex: Create a reusable workout-summary view showing owners, average heart rates, and any performance scores.
CREATE VIEW IF NOT EXISTS vw_WorkoutOverview AS
SELECT w.session_id, u.username, w.start_time,
       w.target_hr_min, w.target_hr_max,
       ROUND(AVG(hr.heart_rate_bpm), 1) AS average_heart_rate,
       COUNT(DISTINCT hr.reading_id) AS number_of_readings,
       pr.performance_score
FROM WorkoutSessions AS w
JOIN Users AS u ON u.user_id = w.user_id
LEFT JOIN WorkoutPhases AS wp ON wp.session_id = w.session_id
LEFT JOIN HeartRateReadings AS hr ON hr.phase_id = wp.phase_id
LEFT JOIN PerformanceRatings AS pr ON pr.session_id = w.session_id
GROUP BY w.session_id, u.username, w.start_time,
         w.target_hr_min, w.target_hr_max, pr.performance_score;

-- 36. Complex: Find the most recently recorded heart rate for each workout using a correlated subquery.
SELECT w.session_id, u.username,
       (SELECT hr.heart_rate_bpm
        FROM WorkoutPhases AS wp
        JOIN HeartRateReadings AS hr ON hr.phase_id = wp.phase_id
        WHERE wp.session_id = w.session_id
        ORDER BY hr.recorded_at DESC, hr.reading_id DESC
        LIMIT 1) AS latest_heart_rate
FROM WorkoutSessions AS w
JOIN Users AS u ON u.user_id = w.user_id
ORDER BY w.session_id;

-- Extra verification: Read the view created in statement 35.
-- This is not needed to reach the required 30 statements, but proves that
-- the view exists and returns useful workout data after the script runs.
SELECT * FROM vw_WorkoutOverview ORDER BY session_id;
