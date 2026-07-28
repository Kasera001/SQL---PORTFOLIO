CREATE TABLE stadiums(
    stadium_id INT NOT NULL AUTO_INCREMENT,
    stadium_name VARCHAR(100) NOT NULL,
    capacity INT,
    city VARCHAR(100),
    PRIMARY KEY (stadium_id)
);


CREATE TABLE teams (
    team_id INT NOT NULL AUTO_INCREMENT,
    team_name VARCHAR(100) NOT NULL,
    stadium_id INT,
    city VARCHAR(100),
    founded_year YEAR,
    PRIMARY KEY (team_id),
    FOREIGN KEY (stadium_id) REFERENCES stadiums(stadium_id),
    FOREIGN KEY (stadium_id) REFERENCES stadiums(stadium_id);
);

CREATE TABLE  managers (
    manager_id INT NOT NULL AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    Nationality VARCHAR(50),
    team_id INT,
    appointed_date DATE,
    PRIMARY KEY (manager_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

CREATE TABLE IF NOT EXISTS players (
    player_id INT NOT NULL AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    position VARCHAR(3) NOT NULL,
    team_id INT,
    date_of_birth DATE,
    nationality VARCHAR(50),
    market_value DECIMAL(6, 2),
    PRIMARY KEY (player_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id)
);


CREATE TABLE seasons(
    season_id INT PRIMARY KEY AUTO_INCREMENT,
    season_name VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
);

CREATE TABLE matches (
    match_id INT NOT NULL AUTO_INCREMENT,
    home_team_id INT NOT NULL,
    away_team_id INT NOT NULL,
    stadium_id INT NOT NULL,
    match_date DATETIME NOT NULL,
    home_goals INT,
    away_goals INT,
    season_id INT NOT NULL,
    PRIMARY KEY (match_id),
    FOREIGN KEY (home_team_id) REFERENCES teams(team_id),
    FOREIGN KEY (away_team_id) REFERENCES teams(team_id),
    FOREIGN KEY (stadium_id) REFERENCES stadiums(stadium_id),
    FOREIGN KEY (season_id) REFERENCES seasons(season_id)
);

CREATE TABLE match_events(
    event_id INT NOT NULL AUTO_INCREMENT,
    match_id INT NOT NULL,
    player_id INT NOT NULL,
    event_type ENUM('goal','assist', 'yellow_card', 'red_card','substitution') NOT NULL,
    event_time TIME NOT NULL,
    PRIMARY KEY (event_id),
    FOREIGN KEY (match_id) REFERENCES matches(match_id),
    FOREIGN KEY (player_id) REFERENCES players(player_id)
);

DROP table teams;