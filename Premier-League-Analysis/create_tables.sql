-- Premier League analytics schema (MySQL 8+)
-- This script creates a clean relational model for teams, fixtures, and match events.

-- Drop child tables first so the script can be re-run safely.
DROP TABLE IF EXISTS match_events;
DROP TABLE IF EXISTS matches;
DROP TABLE IF EXISTS managers;
DROP TABLE IF EXISTS players;
DROP TABLE IF EXISTS teams;
DROP TABLE IF EXISTS seasons;
DROP TABLE IF EXISTS stadiums;

CREATE TABLE stadiums (
    stadium_id INT NOT NULL AUTO_INCREMENT,
    stadium_name VARCHAR(100) NOT NULL,
    capacity INT,
    city VARCHAR(100),
    PRIMARY KEY (stadium_id),
    UNIQUE KEY uk_stadium_name (stadium_name)
);

CREATE TABLE teams (
    team_id INT NOT NULL AUTO_INCREMENT,
    team_name VARCHAR(100) NOT NULL,
    stadium_id INT NOT NULL,
    city VARCHAR(100),
    founded_year YEAR,
    PRIMARY KEY (team_id),
    UNIQUE KEY uk_team_name (team_name),
    CONSTRAINT fk_teams_stadium
        FOREIGN KEY (stadium_id) REFERENCES stadiums(stadium_id)
);

CREATE TABLE managers (
    manager_id INT NOT NULL AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    nationality VARCHAR(50),
    team_id INT,
    appointed_date DATE,
    PRIMARY KEY (manager_id),
    CONSTRAINT fk_managers_team
        FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

CREATE TABLE players (
    player_id INT NOT NULL AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    position ENUM('GK', 'DEF', 'MID', 'FWD') NOT NULL,
    team_id INT,
    date_of_birth DATE,
    nationality VARCHAR(50),
    market_value DECIMAL(10, 2),
    PRIMARY KEY (player_id),
    CONSTRAINT fk_players_team
        FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

CREATE TABLE seasons (
    season_id INT NOT NULL AUTO_INCREMENT,
    season_name VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    PRIMARY KEY (season_id),
    UNIQUE KEY uk_season_name (season_name),
    CONSTRAINT chk_season_dates CHECK (start_date < end_date)
);

CREATE TABLE matches (
    match_id INT NOT NULL AUTO_INCREMENT,
    season_id INT NOT NULL,
    matchweek TINYINT NOT NULL,
    home_team_id INT NOT NULL,
    away_team_id INT NOT NULL,
    stadium_id INT NOT NULL,
    match_date DATE NOT NULL,
    home_goals TINYINT UNSIGNED,
    away_goals TINYINT UNSIGNED,
    PRIMARY KEY (match_id),
    UNIQUE KEY uk_season_fixture (season_id, matchweek, home_team_id, away_team_id),
    CONSTRAINT fk_matches_season
        FOREIGN KEY (season_id) REFERENCES seasons(season_id),
    CONSTRAINT fk_matches_home_team
        FOREIGN KEY (home_team_id) REFERENCES teams(team_id),
    CONSTRAINT fk_matches_away_team
        FOREIGN KEY (away_team_id) REFERENCES teams(team_id),
    CONSTRAINT fk_matches_stadium
        FOREIGN KEY (stadium_id) REFERENCES stadiums(stadium_id),
    CONSTRAINT chk_different_teams CHECK (home_team_id <> away_team_id)
);

CREATE TABLE match_events (
    event_id INT NOT NULL AUTO_INCREMENT,
    match_id INT NOT NULL,
    player_id INT NOT NULL,
    event_type ENUM('goal', 'assist', 'yellow_card', 'red_card', 'substitution') NOT NULL,
    event_minute TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (event_id),
    CONSTRAINT fk_events_match
        FOREIGN KEY (match_id) REFERENCES matches(match_id),
    CONSTRAINT fk_events_player
        FOREIGN KEY (player_id) REFERENCES players(player_id),
    CONSTRAINT chk_event_minute CHECK (event_minute BETWEEN 1 AND 130)
);
