-- Seed and load script for Premier League analysis DB (MySQL 8+)
-- Run after create_tables.sql

-- 1) Core reference data (stadiums, teams, season)
INSERT INTO stadiums (stadium_name, capacity, city) VALUES
('Emirates Stadium', 60704, 'London'),
('Villa Park', 42682, 'Birmingham'),
('Vitality Stadium', 11364, 'Bournemouth'),
('Gtech Community Stadium', 17250, 'London'),
('Amex Stadium', 31800, 'Brighton'),
('Turf Moor', 21944, 'Burnley'),
('Stamford Bridge', 40343, 'London'),
('Selhurst Park', 25486, 'London'),
('Goodison Park', 39572, 'Liverpool'),
('Craven Cottage', 29600, 'London'),
('Anfield', 61276, 'Liverpool'),
('Kenilworth Road', 10356, 'Luton'),
('Etihad Stadium', 53400, 'Manchester'),
('Old Trafford', 74310, 'Manchester'),
('St James'' Park', 52305, 'Newcastle upon Tyne'),
('City Ground', 30445, 'Nottingham'),
('Bramall Lane', 32050, 'Sheffield'),
('Tottenham Hotspur Stadium', 62850, 'London'),
('London Stadium', 62500, 'London'),
('Molineux Stadium', 32050, 'Wolverhampton');

INSERT INTO teams (team_name, stadium_id, city, founded_year) VALUES
('Arsenal', 1, 'London', 1886),
('Aston Villa', 2, 'Birmingham', 1874),
('Bournemouth', 3, 'Bournemouth', 1899),
('Brentford', 4, 'London', 1889),
('Brighton', 5, 'Brighton', 1901),
('Burnley', 6, 'Burnley', 1882),
('Chelsea', 7, 'London', 1905),
('Crystal Palace', 8, 'London', 1905),
('Everton', 9, 'Liverpool', 1878),
('Fulham', 10, 'London', 1879),
('Liverpool', 11, 'Liverpool', 1892),
('Luton', 12, 'Luton', 1885),
('Man City', 13, 'Manchester', 1880),
('Man United', 14, 'Manchester', 1878),
('Newcastle', 15, 'Newcastle', 1892),
('Nott''m Forest', 16, 'Nottingham', 1865),
('Sheffield United', 17, 'Sheffield', 1889),
('Tottenham', 18, 'London', 1882),
('West Ham', 19, 'London', 1895),
('Wolves', 20, 'Wolverhampton', 1877);

INSERT INTO seasons (season_name, start_date, end_date) VALUES
('2023/2024', '2023-08-11', '2024-05-19');

INSERT INTO players (full_name, team_id, position, nationality) VALUES
('Erling Haaland', 13, 'FWD', 'Norway'),
('Cole Palmer', 7, 'FWD', 'England'),
('Alexander Isak', 15, 'FWD', 'Sweden'),
('Phil Foden', 13, 'MID', 'England'),
('Dominic Solanke', 3, 'FWD', 'England'),
('Ollie Watkins', 2, 'FWD', 'England'),
('Mohamed Salah', 11, 'FWD', 'Egypt'),
('Son Heung-min', 18, 'FWD', 'South Korea'),
('Jarrod Bowen', 19, 'FWD', 'England'),
('Jean-Philippe Mateta', 8, 'FWD', 'France');

-- 2) Match result loader from CSV (recommended)
-- Source file: https://datahub.io/football/english-premier-league/_r/-/season-2324.csv
-- Save CSV locally and set this path before running LOAD DATA.
SET @csv_file := '/absolute/path/to/season-2324.csv';

DROP TEMPORARY TABLE IF EXISTS stg_premier_league;
CREATE TEMPORARY TABLE stg_premier_league (
    `Div` VARCHAR(10),
    `Date` VARCHAR(20),
    `Time` VARCHAR(20),
    `HomeTeam` VARCHAR(100),
    `AwayTeam` VARCHAR(100),
    `FTHG` INT,
    `FTAG` INT,
    `FTR` VARCHAR(2)
);

SET @load_sql = CONCAT(
    "LOAD DATA LOCAL INFILE '", REPLACE(@csv_file, "'", "\\'"),
    "' INTO TABLE stg_premier_league ",
    "FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ",
    "LINES TERMINATED BY '\\n' IGNORE 1 LINES ",
    "(`Div`,`Date`,`Time`,`HomeTeam`,`AwayTeam`,`FTHG`,`FTAG`,`FTR`)"
);
PREPARE stmt FROM @load_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

INSERT INTO matches (
    season_id,
    matchweek,
    home_team_id,
    away_team_id,
    stadium_id,
    match_date,
    home_goals,
    away_goals
)
SELECT
    1 AS season_id,
    CEIL(ROW_NUMBER() OVER (ORDER BY STR_TO_DATE(s.`Date`, '%Y-%m-%d'), s.`HomeTeam`) / 10) AS matchweek,
    ht.team_id AS home_team_id,
    at.team_id AS away_team_id,
    ht.stadium_id,
    STR_TO_DATE(s.`Date`, '%Y-%m-%d') AS match_date,
    s.`FTHG` AS home_goals,
    s.`FTAG` AS away_goals
FROM stg_premier_league s
JOIN teams ht ON ht.team_name = s.`HomeTeam`
JOIN teams at ON at.team_name = s.`AwayTeam`
ORDER BY STR_TO_DATE(s.`Date`, '%d/%m/%Y'), s.`HomeTeam`;

-- Optional sanity check: should return 380 rows for one full season.
SELECT COUNT(*) AS loaded_matches FROM matches WHERE season_id = 1;
