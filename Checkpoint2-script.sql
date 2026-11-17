
-- ============================================================================
-- CSE 111 - Fall 2026 - Project Checkpoint 2
-- Project: PulsePlay - Workout Music Recommendation Database
-- Team Members: Hari Brunda Gopireddy, Roma Alimchandani
-- Filename: Checkpoint2-script.sql
-- ============================================================================

-- ============================================================================
-- SCHEMA MODIFICATIONS SINCE CHECKPOINT 1
-- ============================================================================
-- This script uses the corrected PulsePlay database schema.
-- The schema uses PerformanceRatings to store workout performance ratings
-- and links Recommendations to WorkoutPhases and Songs.
--
-- The schema uses the corrected column names, including song_id, username,
-- tempo_bpm, start_time, end_time, target_hr_min, target_hr_max, phase_name,
-- and user_rating.
--
-- PlaylistSongs uses a composite primary key and does not include date_added.
-- Recommendation statuses are PENDING, PLAYED, SKIPPED, and RATED.
-- A user rating is required only when a recommendation has RATED status.
--
-- No additional relational schema changes were made for Checkpoint 2.
-- ============================================================================

-- ============================================================================
-- MEMBER CONTRIBUTIONS SUMMARY
-- ============================================================================
-- Each statement totals 100% across both team members.
--
-- SECTION 1: STATEMENTS 01-12
-- Statement 01: Hari: 100%, Roma: 0%
-- Statement 02: Hari: 100%, Roma: 0%
-- Statement 03: Hari: 100%, Roma: 0%
-- Statement 04: Hari: 100%, Roma: 0%
-- Statement 05: Hari: 100%, Roma: 0%
-- Statement 06: Hari: 0%, Roma: 100%
-- Statement 07: Hari: 0%, Roma: 100%
-- Statement 08: Hari: 0%, Roma: 100%
-- Statement 09: Hari: 0%, Roma: 100%
-- Statement 10: Hari: 0%, Roma: 100%
-- Statement 11: Hari: 100%, Roma: 0%
-- Statement 12: Hari: 100%, Roma: 0%
--
-- SECTION 2: STATEMENTS 13-24
-- Statement 13: Hari: 100%, Roma: 0%
-- Statement 14: Hari: 100%, Roma: 0%
-- Statement 15: Hari: 100%, Roma: 0%
-- Statement 16: Hari: 100%, Roma: 0%
-- Statement 17: Hari: 0%, Roma: 100%
-- Statement 18: Hari: 0%, Roma: 100%
-- Statement 19: Hari: 0%, Roma: 100%
-- Statement 20: Hari: 0%, Roma: 100%
-- Statement 21: Hari: 0%, Roma: 100%
-- Statement 22: Hari: 100%, Roma: 0%
-- Statement 23: Hari: 100%, Roma: 0%
-- Statement 24: Hari: 100%, Roma: 0%
--
-- SECTION 3: STATEMENTS 25-36
-- Statement 25: Hari: 100%, Roma: 0%
-- Statement 26: Hari: 100%, Roma: 0%
-- Statement 27: Hari: 0%, Roma: 100%
-- Statement 28: Hari: 0%, Roma: 100%
-- Statement 29: Hari: 0%, Roma: 100%
-- Statement 30: Hari: 0%, Roma: 100%
-- Statement 31: Hari: 0%, Roma: 100%
-- Statement 32: Hari: 0%, Roma: 100%
-- Statement 33: Hari: 100%, Roma: 0%
-- Statement 34: Hari: 100%, Roma: 0%
-- Statement 35: Hari: 100%, Roma: 0%
-- Statement 36: Hari: 100%, Roma: 0%
-- ============================================================================

-- ============================================================================
-- WHAT THIS SCRIPT DOES
-- ============================================================================
-- These statements demonstrate how the PulsePlay database stores and
-- retrieves information about users, workouts, songs, playlists,
-- heart-rate readings, recommendations, and performance ratings.
--
-- The script contains 36 numbered SQL statements. The sample data is
-- already included in Checkpoint2-dbase.sqlite3.
--
-- Run this script against the populated database, not an empty database.
-- SQLite foreign-key enforcement is enabled for this connection.
-- ============================================================================

PRAGMA foreign_keys = ON;

-- Set output format for readability during evaluation.
.headers on
.mode column


-- ============================================================================
-- SECTION 1: STATEMENTS 01-12
-- ============================================================================


-- 01. Display All Users
-- This query displays all registered users and their email addresses.
-- Results are ordered alphabetically by username.

SELECT user_id, username, email
FROM Users
ORDER BY username;


-- 02. Find Fast Songs
-- This query finds songs with a tempo of at least 145 BPM.
-- The fastest songs appear first in the results.

SELECT song_id, title, artist, tempo_bpm
FROM Songs
WHERE tempo_bpm >= 145
ORDER BY tempo_bpm DESC, title;


-- 03. Find Songs by Title
-- This query finds songs whose titles begin with the letter S.
-- Results are displayed alphabetically by song title.

SELECT title, artist, genre
FROM Songs
WHERE title LIKE 'S%'
ORDER BY title;


-- 04. Calculate Song Statistics
-- This query counts the total number of songs in the catalog.
-- It also calculates the average tempo of all songs.

SELECT COUNT(*) AS total_songs,
       ROUND(AVG(tempo_bpm), 1) AS average_bpm
FROM Songs;


-- 05. Find Users by Email
-- This query displays users whose email addresses end in example.com.
-- Results are ordered by user ID.

SELECT username, email
FROM Users
WHERE email LIKE '%@example.com'
ORDER BY user_id;


-- 06. Find Cardio Playlists
-- This query finds playlists with the word Cardio in their names.
-- The playlist creation dates are displayed in chronological order.

SELECT playlist_id, playlist_name, created_at
FROM Playlists
WHERE playlist_name LIKE '%Cardio%'
ORDER BY created_at;


-- 07. Display Completed Workouts
-- This query displays workout sessions that have an end time.
-- The most recently started workouts appear first.

SELECT session_id, user_id, start_time, end_time
FROM WorkoutSessions
WHERE end_time IS NOT NULL
ORDER BY start_time DESC;


-- 08. Find Heart-Rate Readings Within a Range
-- This query displays heart-rate readings between 110 and 150 BPM.
-- Results are ordered from the highest heart rate to the lowest.

SELECT reading_id, phase_id, recorded_at, heart_rate_bpm
FROM HeartRateReadings
WHERE heart_rate_bpm BETWEEN 110 AND 150
ORDER BY heart_rate_bpm DESC, reading_id;


-- 09. Insert a Temporary User
-- This statement inserts a temporary user to demonstrate the INSERT operation.
-- The conflict clause prevents a duplicate user ID if the script is rerun.

INSERT INTO Users (user_id, username, email)
VALUES (9001, 'checkpoint_demo', 'checkpoint_demo@example.com')
ON CONFLICT(user_id) DO NOTHING;


-- 10. Update a User's Email
-- This statement changes the email address of the temporary user.
-- It demonstrates how existing user information can be updated.

UPDATE Users
SET email = 'checkpoint_demo_updated@example.com'
WHERE user_id = 9001;


-- 11. Delete a Temporary User
-- This statement removes the temporary user created in Statement 09.
-- It demonstrates DELETE while leaving the original user records unchanged.

DELETE FROM Users
WHERE user_id = 9001;


-- 12. Find Highly Rated Recommendations
-- This query displays recommendations with user ratings between 4 and 5.
-- Results are ordered from the highest rating to the lowest.

SELECT recommendation_id, song_id, status, user_rating
FROM Recommendations
WHERE user_rating BETWEEN 4 AND 5
ORDER BY user_rating DESC, recommendation_id;


-- ============================================================================
-- SECTION 2: STATEMENTS 13-24
-- ============================================================================


-- 13. Display Playlists and Their Owners
-- This query displays each playlist alongside the username of its owner.
-- Results are organized by username and playlist name.

SELECT p.playlist_id, p.playlist_name, u.username
FROM Playlists AS p
INNER JOIN Users AS u ON p.user_id = u.user_id
ORDER BY u.username, p.playlist_name;


-- 14. Display Songs in Each Playlist
-- This query lists the songs saved in each playlist, including their titles,
-- genres, and tempos. Results are organized by playlist and song tempo.

SELECT p.playlist_name, s.title, s.genre, s.tempo_bpm
FROM PlaylistSongs AS ps
JOIN Playlists AS p ON ps.playlist_id = p.playlist_id
JOIN Songs AS s ON ps.song_id = s.song_id
ORDER BY p.playlist_id, s.tempo_bpm DESC;


-- 15. Display Workouts and Their Owners
-- This query displays each workout session with the username of its owner.
-- It also includes the selected minimum and maximum heart-rate targets.

SELECT w.session_id, u.username, w.start_time,
       w.target_hr_min, w.target_hr_max
FROM WorkoutSessions AS w
JOIN Users AS u ON w.user_id = u.user_id
ORDER BY w.session_id;


-- 16. Display Workout Phases
-- This query lists workout phases with the session and username they belong to.
-- Results are ordered by workout session and phase start time.

SELECT u.username, wp.session_id, wp.phase_name,
       wp.start_time, wp.end_time
FROM WorkoutPhases AS wp
JOIN WorkoutSessions AS w ON wp.session_id = w.session_id
JOIN Users AS u ON w.user_id = u.user_id
ORDER BY wp.session_id, wp.start_time;


-- 17. Count Playlists for Each User
-- This query counts the number of playlists owned by each user.
-- LEFT JOIN includes users who do not currently have any playlists.

SELECT u.user_id, u.username,
       COUNT(p.playlist_id) AS playlist_count
FROM Users AS u
LEFT JOIN Playlists AS p ON u.user_id = p.user_id
GROUP BY u.user_id, u.username
ORDER BY playlist_count DESC, u.username;


-- 18. Display Workout Performance Ratings
-- This query displays workout sessions alongside any performance ratings and comments submitted by their users. LEFT JOIN also keeps sessions that do not have a performance rating.

SELECT w.session_id, u.username,
       pr.performance_score, pr.comments
FROM WorkoutSessions AS w
JOIN Users AS u ON u.user_id = w.user_id
LEFT JOIN PerformanceRatings AS pr ON pr.session_id = w.session_id
ORDER BY w.session_id;


-- 19. Display Recommendations and Song Details
-- This query displays each recommendation with its song, workout phase, and workout owner. It also includes the song tempo and recommendation status.

SELECT r.recommendation_id, u.username, wp.phase_name,
       s.title, s.tempo_bpm, r.status
FROM Recommendations AS r
JOIN Songs AS s ON s.song_id = r.song_id
JOIN WorkoutPhases AS wp ON wp.phase_id = r.phase_id
JOIN WorkoutSessions AS w ON w.session_id = wp.session_id
JOIN Users AS u ON u.user_id = w.user_id
ORDER BY r.recommendation_id;


-- 20. Count Songs by Genre
-- This query counts the number of songs in each genre and calculate the average tempo. Only genres containing at least four songs are included.

SELECT genre, COUNT(*) AS song_count,
       ROUND(AVG(tempo_bpm), 1) AS average_bpm
FROM Songs
GROUP BY genre
HAVING COUNT(*) >= 4
ORDER BY song_count DESC, genre;


-- 21. Find Workouts with Above-Average Heart Rates
-- This query calculates the average heart rate and number of readings for each workout session. Only sessions with an average above 110 BPM are included.

SELECT w.session_id,
       ROUND(AVG(hr.heart_rate_bpm), 1) AS average_heart_rate,
       COUNT(hr.reading_id) AS reading_count
FROM WorkoutSessions AS w
JOIN WorkoutPhases AS wp ON wp.session_id = w.session_id
JOIN HeartRateReadings AS hr ON hr.phase_id = wp.phase_id
GROUP BY w.session_id
HAVING AVG(hr.heart_rate_bpm) > 110
ORDER BY average_heart_rate DESC;


-- 22. Find Songs Above the Average Tempo
-- This query finds songs with a tempo higher than the average tempo of the entire song catalog. Results are ordered from fastest to slowest.

SELECT song_id, title, tempo_bpm
FROM Songs
WHERE tempo_bpm > (SELECT AVG(tempo_bpm) FROM Songs)
ORDER BY tempo_bpm DESC, title;


-- 23. Update a Pending Recommendation
-- This statement changes a recommendation's status to PLAYED.
-- The update occurs only if recommendation 1 is still in PENDING status.

UPDATE Recommendations
SET status = 'PLAYED'
WHERE recommendation_id = 1 AND status = 'PENDING';


-- 24. Count Recommendations for Each Song
-- This query counts how many times each song has been recommended.
-- LEFT JOIN includes songs that have never been recommended.

SELECT s.song_id, s.title,
       COUNT(r.recommendation_id) AS times_recommended
FROM Songs AS s
LEFT JOIN Recommendations AS r ON r.song_id = s.song_id
GROUP BY s.song_id, s.title
ORDER BY times_recommended DESC, s.title;


-- ============================================================================
-- SECTION 3: STATEMENTS 25-36
-- ============================================================================


-- 25. Find Users with Fast Songs in Their Playlists
-- This query finds users who own at least one playlist containing
-- a song with a tempo of 150 BPM or faster. EXISTS checks whether
-- at least one matching playlist and song are present.

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


-- 26. Find Songs That Were Never Recommended
-- This query finds songs in the catalog that do not appear
-- in the Recommendations table. NOT EXISTS checks for the absence
-- of a matching recommendation.

SELECT s.song_id, s.title, s.artist
FROM Songs AS s
WHERE NOT EXISTS (
    SELECT 1
    FROM Recommendations AS r
    WHERE r.song_id = s.song_id
)
ORDER BY s.title;


-- 27. Combine Pop and Electronic Songs
-- This query combines Pop and Electronic songs into one result set.
-- UNION removes duplicate rows from the combined results.

SELECT title, artist, genre
FROM Songs
WHERE genre = 'Pop'

UNION

SELECT title, artist, genre
FROM Songs
WHERE genre = 'Electronic'

ORDER BY title;


-- 28. Find Songs in Playlists and Recommendations
-- This query finds song IDs that appear in both PlaylistSongs and Recommendations. INTERSECT returns only IDs present in both results.

SELECT song_id
FROM PlaylistSongs

INTERSECT

SELECT song_id
FROM Recommendations

ORDER BY song_id;


-- 29. Find Playlist Songs That Were Never Recommended
-- This query finds songs saved in playlists but absent from the recommendations table. EXCEPT removes song IDs that have been recommended.

SELECT s.song_id, s.title
FROM Songs AS s
WHERE s.song_id IN (
    SELECT song_id
    FROM PlaylistSongs

    EXCEPT

    SELECT song_id
    FROM Recommendations
)
ORDER BY s.song_id;


-- 30. Find the Latest Heart-Rate Reading for Each Workout
-- This query uses a common table expression and ROW_NUMBER to identify
-- the latest heart-rate reading for each workout session. It compares
-- that reading with the workout's selected target heart-rate range.

WITH latest_readings AS (
    SELECT w.session_id, w.target_hr_min, w.target_hr_max,
           hr.heart_rate_bpm, hr.recorded_at,
           ROW_NUMBER() OVER (
               PARTITION BY w.session_id
               ORDER BY hr.recorded_at DESC, hr.reading_id DESC
           ) AS rn
    FROM WorkoutSessions AS w
    JOIN WorkoutPhases AS wp ON wp.session_id = w.session_id
    JOIN HeartRateReadings AS hr ON hr.phase_id = wp.phase_id
)
SELECT session_id, heart_rate_bpm, target_hr_min, target_hr_max,
       CASE
           WHEN heart_rate_bpm < target_hr_min THEN 'BELOW TARGET'
           WHEN heart_rate_bpm > target_hr_max THEN 'ABOVE TARGET'
           ELSE 'IN TARGET'
       END AS heart_rate_status
FROM latest_readings
WHERE rn = 1
ORDER BY session_id;


-- 31. Compare Users' Average Workout Heart Rates
-- This query uses multiple common table expressions to calculate
-- the average heart rate for each workout and summarize the results
-- for each user, including the number of sessions with readings.

WITH session_averages AS (
    SELECT w.session_id, w.user_id,
           AVG(hr.heart_rate_bpm) AS session_avg
    FROM WorkoutSessions AS w
    JOIN WorkoutPhases AS wp ON wp.session_id = w.session_id
    JOIN HeartRateReadings AS hr ON hr.phase_id = wp.phase_id
    GROUP BY w.session_id, w.user_id
),
user_summary AS (
    SELECT user_id,
           COUNT(*) AS workout_count,
           ROUND(AVG(session_avg), 1) AS mean_session_hr
    FROM session_averages
    GROUP BY user_id
)
SELECT u.username, us.workout_count, us.mean_session_hr
FROM user_summary AS us
JOIN Users AS u ON u.user_id = us.user_id
ORDER BY us.mean_session_hr DESC;


-- 32. Rank Songs by Tempo Within Each Genre
-- This query uses ROW_NUMBER to rank songs by tempo separately
-- within each genre. It displays the two fastest songs from each genre.

WITH ranked_songs AS (
    SELECT song_id, genre, title, tempo_bpm,
           ROW_NUMBER() OVER (
               PARTITION BY genre
               ORDER BY tempo_bpm DESC, title
           ) AS tempo_rank
    FROM Songs
)
SELECT genre, title, tempo_bpm, tempo_rank
FROM ranked_songs
WHERE tempo_rank <= 2
ORDER BY genre, tempo_rank;


-- 33. Rank Users by Saved Playlist Songs
-- This query counts the number of songs saved across each user's playlists.
-- DENSE_RANK assigns the same rank to users with equal song counts.

WITH playlist_sizes AS (
    SELECT u.user_id, u.username,
           COUNT(ps.song_id) AS saved_songs
    FROM Users AS u
    LEFT JOIN Playlists AS p ON p.user_id = u.user_id
    LEFT JOIN PlaylistSongs AS ps ON ps.playlist_id = p.playlist_id
    GROUP BY u.user_id, u.username
)
SELECT username, saved_songs,
       DENSE_RANK() OVER (ORDER BY saved_songs DESC) AS activity_rank
FROM playlist_sizes
ORDER BY activity_rank, username;


-- 34. Classify Recommendation Outcomes
-- This query uses CASE to group recommendations into outcome categories
-- based on their status and user rating. It counts the recommendations
-- in each category.

SELECT
    CASE
        WHEN status = 'RATED' AND user_rating >= 4 THEN 'HIGHLY RATED'
        WHEN status = 'RATED' THEN 'LOW RATED'
        WHEN status = 'PLAYED' THEN 'PLAYED WITHOUT RATING'
        WHEN status = 'SKIPPED' THEN 'SKIPPED'
        ELSE 'AWAITING ACTION'
    END AS outcome,
    COUNT(*) AS outcome_count
FROM Recommendations
GROUP BY
    CASE
        WHEN status = 'RATED' AND user_rating >= 4 THEN 'HIGHLY RATED'
        WHEN status = 'RATED' THEN 'LOW RATED'
        WHEN status = 'PLAYED' THEN 'PLAYED WITHOUT RATING'
        WHEN status = 'SKIPPED' THEN 'SKIPPED'
        ELSE 'AWAITING ACTION'
    END
ORDER BY outcome_count DESC, outcome;


-- 35. Create a Workout Summary View
-- This view summarizes workout sessions with their owners, target heart-rate
-- ranges, average heart rates, number of readings, and performance scores.
-- It can be queried later without repeating the full joins and aggregation.

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


-- 36. Find the Latest Heart-Rate Reading Using a Correlated Subquery
-- This query finds the most recently recorded heart-rate value
-- for each workout session. The correlated subquery uses the current
-- workout session to retrieve its latest reading.

SELECT w.session_id, u.username,
       (
           SELECT hr.heart_rate_bpm
           FROM WorkoutPhases AS wp
           JOIN HeartRateReadings AS hr ON hr.phase_id = wp.phase_id
           WHERE wp.session_id = w.session_id
           ORDER BY hr.recorded_at DESC, hr.reading_id DESC
           LIMIT 1
       ) AS latest_heart_rate
FROM WorkoutSessions AS w
JOIN Users AS u ON u.user_id = w.user_id
ORDER BY w.session_id;


-- ============================================================================
-- EXTRA VERIFICATION
-- ============================================================================
-- This query displays the workout summary view created in Statement 35.
-- It is included for verification and is not counted as one of the 36
-- numbered SQL statements.
-- ============================================================================

SELECT *
FROM vw_WorkoutOverview
ORDER BY session_id;
