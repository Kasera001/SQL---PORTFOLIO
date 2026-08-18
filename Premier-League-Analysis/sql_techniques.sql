-- SQL techniques on the Premier League dataset

-- 1) INNER JOIN: match records with home team and stadium
SELECT m.match_id, t.team_name AS home_team, s.stadium_name
FROM matches m
INNER JOIN teams t ON t.team_id = m.home_team_id
INNER JOIN stadiums s ON s.stadium_id = m.stadium_id;

-- 2) Aggregate with GROUP BY: total home goals by team
SELECT t.team_name, SUM(m.home_goals) AS total_home_goals
FROM matches m
INNER JOIN teams t ON t.team_id = m.home_team_id
GROUP BY t.team_name
ORDER BY total_home_goals DESC;

-- 3) CASE expression: classify match outcome for home team
SELECT
    match_id,
    home_team_id,
    away_team_id,
    home_goals,
    away_goals,
    CASE
        WHEN home_goals > away_goals THEN 'Home Win'
        WHEN home_goals < away_goals THEN 'Away Win'
        ELSE 'Draw'
    END AS result_type
FROM matches;

-- 4) CTE: goal difference summary per team (home matches)
WITH home_summary AS (
    SELECT
        home_team_id AS team_id,
        SUM(home_goals) AS goals_scored,
        SUM(away_goals) AS goals_conceded
    FROM matches
    GROUP BY home_team_id
)
SELECT
    t.team_name,
    hs.goals_scored,
    hs.goals_conceded,
    (hs.goals_scored - hs.goals_conceded) AS goal_difference
FROM home_summary hs
INNER JOIN teams t ON t.team_id = hs.team_id
ORDER BY goal_difference DESC;

-- 5) Window function: running home goals by date for each team
SELECT
    m.home_team_id,
    t.team_name,
    m.match_date,
    m.home_goals,
    SUM(m.home_goals) OVER (
        PARTITION BY m.home_team_id
        ORDER BY m.match_date, m.match_id
    ) AS running_home_goals
FROM matches m
INNER JOIN teams t ON t.team_id = m.home_team_id
ORDER BY m.home_team_id, m.match_date, m.match_id;

-- 6) DENSE_RANK: rank teams by total home points
WITH home_points AS (
    SELECT
        home_team_id AS team_id,
        SUM(
            CASE
                WHEN home_goals > away_goals THEN 3
                WHEN home_goals = away_goals THEN 1
                ELSE 0
            END
        ) AS points
    FROM matches
    GROUP BY home_team_id
)
SELECT
    t.team_name,
    hp.points,
    DENSE_RANK() OVER (ORDER BY hp.points DESC) AS points_rank
FROM home_points hp
INNER JOIN teams t ON t.team_id = hp.team_id
ORDER BY points_rank, t.team_name;
