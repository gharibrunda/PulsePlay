
PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

-- 1. Users
INSERT INTO Users (user_id, username, email) VALUES
(1, 'alex_fit', 'alex@example.com'),
(2, 'jordan_runs', 'jordan@example.com'),
(3, 'sam_active', 'sam@example.com'),
(4, 'taylor_music', 'taylor@example.com');

-- 2. Songs
INSERT INTO Songs (song_id, title, artist, genre, tempo_bpm) VALUES
(1, 'Blinding Lights', 'The Weeknd', 'Pop', 171),
(2, 'Levitating', 'Dua Lipa', 'Pop', 103),
(3, 'Yellow', 'Coldplay', 'Alternative', 87),
(4, 'Stronger', 'Kanye West', 'Hip-Hop', 104),
(5, 'Perfect', 'Ed Sheeran', 'Pop', 95),
(6, 'Eye of the Tiger', 'Survivor', 'Rock', 109),
(7, 'Sunflower', 'Post Malone', 'Pop', 90),
(8, 'Lose Yourself', 'Eminem', 'Hip-Hop', 171),
(99, 'Test Song', 'Test Artist', 'Test', 100);

-- 3. Playlists
INSERT INTO Playlists
(playlist_id, user_id, playlist_name, created_at) VALUES
(1, 1, 'Running Mix', '2026-10-01 08:00:00'),
(2, 1, 'Workout Favorites', '2026-10-05 09:30:00'),
(3, 2, 'Relaxed Workout', '2026-10-10 10:00:00'),
(4, 3, 'High Energy', '2026-10-15 07:45:00');

-- 4. PlaylistSongs
INSERT INTO PlaylistSongs (playlist_id, song_id) VALUES
(1, 1),
(1, 2),
(1, 3),
(2, 2),
(2, 4),
(3, 5),
(4, 6),
(4, 7);

-- 5. WorkoutSessions
INSERT INTO WorkoutSessions
(session_id, user_id, start_time, end_time, target_hr_min, target_hr_max) VALUES
(1, 1, '2026-10-20 07:00:00', '2026-10-20 08:00:00', 120, 160),
(2, 1, '2026-10-22 07:30:00', '2026-10-22 08:15:00', 115, 155),
(3, 2, '2026-10-23 06:30:00', '2026-10-23 07:30:00', 125, 165),
(4, 3, '2026-10-24 17:00:00', '2026-10-24 18:00:00', 110, 150);

-- 6. WorkoutPhases
INSERT INTO WorkoutPhases
(phase_id, session_id, phase_name, start_time, end_time) VALUES
(1, 1, 'Warmup', '2026-10-20 07:00:00', '2026-10-20 07:15:00'),
(2, 1, 'Main Workout', '2026-10-20 07:15:00', '2026-10-20 07:45:00'),
(3, 1, 'Cooldown', '2026-10-20 07:45:00', '2026-10-20 08:00:00'),
(4, 2, 'Main Workout', '2026-10-22 07:30:00', '2026-10-22 08:15:00'),
(5, 3, 'Warmup', '2026-10-23 06:30:00', '2026-10-23 06:45:00'),
(6, 3, 'Main Workout', '2026-10-23 06:45:00', '2026-10-23 07:30:00');

-- 7. HeartRateReadings
INSERT INTO HeartRateReadings
(reading_id, phase_id, recorded_at, heart_rate_bpm) VALUES
(1, 1, '2026-10-20 07:05:00', 105),
(2, 1, '2026-10-20 07:10:00', 118),
(3, 2, '2026-10-20 07:25:00', 145),
(4, 2, '2026-10-20 07:35:00', 162),
(5, 3, '2026-10-20 07:50:00', 130),
(6, 4, '2026-10-22 07:45:00', 150),
(7, 4, '2026-10-22 08:00:00', 158),
(8, 5, '2026-10-23 06:35:00', 115),
(9, 6, '2026-10-23 07:00:00', 170),
(10, 6, '2026-10-23 07:20:00', 155);

-- 8. Recommendations
INSERT INTO Recommendations
(recommendation_id, phase_id, song_id, recommended_at, status, user_rating) VALUES
(1, 1, 1, '2026-10-20 07:06:00', 'PLAYED', NULL),
(2, 2, 2, '2026-10-20 07:26:00', 'RATED', 5),
(3, 2, 4, '2026-10-20 07:36:00', 'SKIPPED', NULL),
(4, 3, 6, '2026-10-20 07:51:00', 'PENDING', NULL),
(5, 4, 1, '2026-10-22 07:46:00', 'PLAYED', NULL),
(6, 5, 2, '2026-10-23 06:36:00', 'RATED', 4),
(7, 6, 6, '2026-10-23 07:01:00', 'SKIPPED', NULL);

-- 9. PerformanceRatings
INSERT INTO PerformanceRatings
(rating_id, session_id, performance_score, comments) VALUES
(1, 1, 5, 'Great workout with consistent energy.'),
(2, 2, 4, 'Good workout with a strong finish.'),
(3, 3, 3, 'Moderate workout with some fatigue.');

COMMIT;
