
-- ============================================================
-- PULSEPLAY DATABASE PROJECT - CHECKPOINT 2
-- HARI BRUNDA GOPIREDDY
-- SQL STATEMENTS: 1-5, 11-16, 22-26
-- Individual Contribution: 100% for each statement below
-- ============================================================

PRAGMA foreign_keys = ON;
.headers on
.mode column

-- ============================================================
-- SIMPLE SQL STATEMENTS (1-5)
-- ============================================================

-- Statement 1: Display All Users
-- This query displays all registered users in PulsePlay.
-- Results are ordered alphabetically by username.

SELECT *
FROM Users
ORDER BY username;


-- Statement 2: Find Songs by Genre
-- This query displays all songs in the Pop genre.
-- Results are ordered alphabetically by song title.

SELECT song_id, title, artist, genre, tempo_bpm
FROM Songs
WHERE genre = 'Pop'
ORDER BY title;


-- Statement 3: Display Playlists by Creation Date
-- This query displays all playlists and their creation dates.
-- The newest playlists appear first.

SELECT playlist_id, user_id, playlist_name, created_at
FROM Playlists
ORDER BY created_at DESC;


-- Statement 4: Calculate Average Heart Rate
-- This query calculates the average heart rate across all recorded readings.
-- The result provides one overall average for the sample workout data.

SELECT AVG(heart_rate_bpm) AS average_heart_rate
FROM HeartRateReadings;


-- Statement 5: Find Users by Email Pattern
-- This query finds users whose email addresses end in 'example.com'.
-- Results are ordered alphabetically by username.

SELECT user_id, username, email
FROM Users
WHERE email LIKE '%example.com'
ORDER BY username;


-- ============================================================
-- INTERMEDIATE SQL STATEMENTS (11-16)
-- ============================================================

-- Statement 11: Users and Their Playlists
-- This query displays users alongside the playlists they created.
-- Users without playlists are not included.

SELECT u.user_id, u.username, p.playlist_id, p.playlist_name
FROM Users AS u
JOIN Playlists AS p ON u.user_id = p.user_id
ORDER BY u.username, p.playlist_name;


-- Statement 12: Songs in Each Playlist
-- This query displays the songs assigned to each playlist.
-- Results are organized by playlist name and song title.

SELECT p.playlist_name, s.song_id, s.title, s.artist
FROM Playlists AS p
JOIN PlaylistSongs AS ps ON p.playlist_id = ps.playlist_id
JOIN Songs AS s ON ps.song_id = s.song_id
ORDER BY p.playlist_name, s.title;


-- Statement 13: Workout Sessions by User
-- This query displays each workout session with the user who completed it.
-- Results are organized by username and session start time.

SELECT u.username, ws.session_id, ws.start_time, ws.end_time
FROM Users AS u
JOIN WorkoutSessions AS ws ON u.user_id = ws.user_id
ORDER BY u.username, ws.start_time;


-- Statement 14: Workout Phases by Session
-- This query displays the phases associated with each workout session.
-- It also identifies the user who completed each session.

SELECT ws.session_id, u.username, wp.phase_id, wp.phase_name,
       wp.start_time, wp.end_time
FROM WorkoutSessions AS ws
JOIN Users AS u ON ws.user_id = u.user_id
JOIN WorkoutPhases AS wp ON ws.session_id = wp.session_id
ORDER BY ws.session_id, wp.start_time;


-- Statement 15: Heart Rate Readings by Workout Phase
-- This query displays heart rate readings alongside their workout phases.
-- Results are organized by phase and recording time.

SELECT wp.phase_id, wp.phase_name, hr.reading_id,
       hr.recorded_at, hr.heart_rate_bpm
FROM WorkoutPhases AS wp
JOIN HeartRateReadings AS hr ON wp.phase_id = hr.phase_id
ORDER BY wp.phase_id, hr.recorded_at;


-- Statement 16: Playlists Containing Multiple Songs
-- This query finds playlists that contain more than one song.
-- The song count is displayed for each qualifying playlist.

SELECT p.playlist_id, p.playlist_name,
       COUNT(ps.song_id) AS song_count
FROM Playlists AS p
JOIN PlaylistSongs AS ps ON p.playlist_id = ps.playlist_id
GROUP BY p.playlist_id, p.playlist_name
HAVING COUNT(ps.song_id) > 1
ORDER BY song_count DESC, p.playlist_name;


-- ============================================================
-- COMPLEX SQL STATEMENTS (22-26)
-- ============================================================

-- Statement 22: Users Who Have Workout Sessions
-- This query finds users who have completed at least one workout session.
-- EXISTS checks whether a matching workout session exists for each user.

SELECT u.user_id, u.username, u.email
FROM Users AS u
WHERE EXISTS (
    SELECT 1
    FROM WorkoutSessions AS ws
    WHERE ws.user_id = u.user_id
)
ORDER BY u.username;


-- Statement 23: Songs Never Recommended
-- This query finds songs that have never appeared in the Recommendations table.
-- NOT EXISTS checks that no recommendation exists for each song.

SELECT s.song_id, s.title, s.artist, s.genre
FROM Songs AS s
WHERE NOT EXISTS (
    SELECT 1
    FROM Recommendations AS r
    WHERE r.song_id = s.song_id
)
ORDER BY s.title;


-- Statement 24: Songs in Playlists but Never Recommended
-- This query finds songs that appear in playlists but have never been recommended.
-- EXCEPT returns songs in the playlist collection that are not in the recommendations collection.

SELECT s.song_id, s.title, s.artist
FROM Songs AS s
WHERE s.song_id IN (
    SELECT song_id
    FROM PlaylistSongs

    EXCEPT

    SELECT song_id
    FROM Recommendations
)
ORDER BY s.title;


-- Statement 25: Songs Both in Playlists and Recommendations
-- This query finds songs that appear in both playlists and recommendations.
-- INTERSECT returns only song IDs found in both collections.

SELECT s.song_id, s.title, s.artist
FROM Songs AS s
WHERE s.song_id IN (
    SELECT song_id
    FROM PlaylistSongs

    INTERSECT

    SELECT song_id
    FROM Recommendations
)
ORDER BY s.title;


-- Statement 26: Average Heart Rate per Workout Session
-- This query calculates the average heart rate for each workout session.
-- A CTE combines workout phases and heart rate readings before calculating the averages.

WITH SessionHeartRates AS (
    SELECT wp.session_id,
           AVG(hr.heart_rate_bpm) AS average_heart_rate
    FROM WorkoutPhases AS wp
    JOIN HeartRateReadings AS hr
        ON wp.phase_id = hr.phase_id
    GROUP BY wp.session_id
)
SELECT ws.session_id, u.username,
       shr.average_heart_rate
FROM WorkoutSessions AS ws
JOIN Users AS u
    ON ws.user_id = u.user_id
LEFT JOIN SessionHeartRates AS shr
    ON ws.session_id = shr.session_id
ORDER BY ws.session_id;
