CREATE TABLE teams (
    team_id INT NOT NULL AUTO_INCREMENT,
    team_name VARCHAR(100) NOT NULL,
    stadium_id INT,
    city VARCHAR(100),
    founded_year YEAR,
    PRIMARY KEY (team_id)
);

CREATE TABLE stadiums
(
    stadium_id INT NOT NULL AUTO_INCREMENT,
    stadium_name VARCHAR(100) NOT NULL,
    capacity INT,
    city VARCHAR(100),
    PRIMARY KEY (stadium_id)
);