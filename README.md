# PulsePlay
<<<<<<< Updated upstream

CSE 111 Database Project

PulsePlay is a music recommendation application that recommends songs
from user playlists based on workout phases and target heart rates.

## Project Files

- schema.sql: Database table definitions.
- seed.sql: Sample data for the database.
- Checkpoint2-script.sql: SQL queries and data modification statements.
- Checkpoint2-dbase.sqlite3: Populated SQLite database.
=======
PulsePlay is a local SQLite workout and music recommendation database. It connects users and workout sessions with playlist songs, simulated heart-rate readings, song recommendations, and feedback.

Deliverables
- Checkpoint2-dbase.sqlite3: a self-contained SQLite database containing the nine tables and already-populated sample records.
- Checkpoint2-script.sql: a sequential SQLite script containing 36 numbered SQL statements (12 simple, 12 intermediate, 12 complex), each with an explanation, plus one final verification SELECT.

Database tables
1. Users: a user's username and email.
2. Playlists: playlists created by users.
3. Songs: local song catalog, including tempo in beats per minute (BPM).
4. PlaylistSongs: many-to-many playlist-to-song relationships.
5. WorkoutSessions: workouts with user-selected minimum and maximum target heart rates.
6. WorkoutPhases: portions of each session (warmup, active, recovery, cooldown).
7. HeartRateReadings: recorded heart rates assigned to phases.
8. Recommendations: song suggestions saved per phase, with their statuses and optional ratings.
9. PerformanceRatings: ratings of workout sessions, when provided.
Foreign keys and CHECK constraints are included in the database. A simulated recommendation is simply a saved suggestion; these files do not stream audio or automatically control exercise intensity.
How to test on a Mac or a computer with SQLite installed
1. Put the .sqlite3 and .sql files in the same folder.
2. In Terminal, cd into that folder.
3. Run:
sqlite3 Checkpoint2-dbase.sqlite3
4. Inside SQLite, run:
.read Checkpoint2-script.sql
5. You can then verify the schema and data:
.tables
SELECT COUNT(*) FROM Users;
SELECT COUNT(*) FROM WorkoutSessions;
SELECT COUNT(*) FROM Recommendations;
PRAGMA foreign_key_check;
.quit



>>>>>>> Stashed changes
