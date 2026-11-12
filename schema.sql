
PRAGMA foreign_keys = ON;

-- 1. Users
CREATE TABLE Users (
    user_id INTEGER PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE
);

-- 2. Songs
CREATE TABLE Songs (
    song_id INTEGER PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    artist VARCHAR(100) NOT NULL,
    genre VARCHAR(50),
    tempo_bpm INTEGER CHECK (tempo_bpm > 0)
);

-- 3. Playlists
CREATE TABLE Playlists (
    playlist_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    playlist_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 4. PlaylistSongs
CREATE TABLE PlaylistSongs (
    playlist_id INTEGER NOT NULL,
    song_id INTEGER NOT NULL,
    PRIMARY KEY (playlist_id, song_id),
    FOREIGN KEY (playlist_id) REFERENCES Playlists(playlist_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (song_id) REFERENCES Songs(song_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 5. WorkoutSessions
CREATE TABLE WorkoutSessions (
    session_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    start_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    target_hr_min INTEGER NOT NULL CHECK (target_hr_min > 0),
    target_hr_max INTEGER NOT NULL,
    CHECK (target_hr_max >= target_hr_min),
    CHECK (end_time IS NULL OR end_time >= start_time),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 6. WorkoutPhases
CREATE TABLE WorkoutPhases (
    phase_id INTEGER PRIMARY KEY,
    session_id INTEGER NOT NULL,
    phase_name VARCHAR(50) NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    CHECK (end_time IS NULL OR end_time >= start_time),
    FOREIGN KEY (session_id) REFERENCES WorkoutSessions(session_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 7. HeartRateReadings
CREATE TABLE HeartRateReadings (
    reading_id INTEGER PRIMARY KEY,
    phase_id INTEGER NOT NULL,
    recorded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    heart_rate_bpm INTEGER NOT NULL CHECK (heart_rate_bpm > 0),
    FOREIGN KEY (phase_id) REFERENCES WorkoutPhases(phase_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 8. Recommendations
CREATE TABLE Recommendations (
    recommendation_id INTEGER PRIMARY KEY,
    phase_id INTEGER NOT NULL,
    song_id INTEGER NOT NULL,
    recommended_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (status IN ('PENDING', 'PLAYED', 'SKIPPED', 'RATED')),
    user_rating INTEGER CHECK (user_rating BETWEEN 1 AND 5),
    CHECK (
        (status = 'RATED' AND user_rating IS NOT NULL)
        OR
        (status <> 'RATED' AND user_rating IS NULL)
    ),
    FOREIGN KEY (phase_id) REFERENCES WorkoutPhases(phase_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (song_id) REFERENCES Songs(song_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 9. PerformanceRatings
CREATE TABLE PerformanceRatings (
    rating_id INTEGER PRIMARY KEY,
    session_id INTEGER NOT NULL UNIQUE,
    performance_score INTEGER NOT NULL
        CHECK (performance_score BETWEEN 1 AND 5),
    comments TEXT,
    FOREIGN KEY (session_id) REFERENCES WorkoutSessions(session_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
