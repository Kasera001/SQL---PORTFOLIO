-- Advanced Premier League analysis queries (MySQL 8+)
-- These queries are written with clear comments so you can adapt them quickly.

-- 1) Final league table from raw match results
-- Builds points, wins, draws, losses, goals for/against, and goal difference.
WITH all_results AS (
    SELECT
        m.season_id,
        m.home_team_id AS team_id,
        m.home_goals AS goals_for,
        m.away_goals AS goals_against,
        CASE
            WHEN m.home_goals > m.away_goals THEN 3
            WHEN m.home_goals = m.away_goals THEN 1
            ELSE 0
        END AS points,
        CASE WHEN m.home_goals > m.away_goals THEN 1 ELSE 0 END AS wins,
        CASE WHEN m.home_goals = m.away_goals THEN 1 ELSE 0 END AS draws,
        CASE WHEN m.home_goals < m.away_goals THEN 1 ELSE 0 END AS losses
    FROM matches m
    WHERE m.home_goals IS NOT NULL AND m.away_goals IS NOT NULL
    UNION ALL
    SELECT
        m.season_id,
        m.away_team_id AS team_id,
        m.away_goals AS goals_for,
        m.home_goals AS goals_against,
        CASE
            WHEN m.away_goals > m.home_goals THEN 3
            WHEN m.away_goals = m.home_goals THEN 1
            ELSE 0
        END AS points,
        CASE WHEN m.away_goals > m.home_goals THEN 1 ELSE 0 END AS wins,
        CASE WHEN m.away_goals = m.home_goals THEN 1 ELSE 0 END AS draws,
        CASE WHEN m.away_goals < m.home_goals THEN 1 ELSE 0 END AS losses
    FROM matches m
)
SELECT
    s.season_name,
    t.team_name,
    COUNT(*) AS played,
    SUM(r.wins) AS wins,
    SUM(r.draws) AS draws,
    SUM(r.losses) AS losses,
    SUM(r.goals_for) AS goals_for,
    SUM(r.goals_against) AS goals_against,
    SUM(r.goals_for) - SUM(r.goals_against) AS goal_difference,
    SUM(r.points) AS points
FROM all_results r
JOIN teams t ON t.team_id = r.team_id
JOIN seasons s ON s.season_id = r.season_id
GROUP BY s.season_name, t.team_name
ORDER BY points DESC, goal_difference DESC, goals_for DESC;

-- 2) Home advantage by team
-- Compares home points with away points to find clubs that benefit most at home.
WITH home_points AS (
    SELECT
        home_team_id AS team_id,
        SUM(CASE WHEN home_goals > away_goals THEN 3 WHEN home_goals = away_goals THEN 1 ELSE 0 END) AS points_home
    FROM matches
    GROUP BY home_team_id
),
away_points AS (
    SELECT
        away_team_id AS team_id,
        SUM(CASE WHEN away_goals > home_goals THEN 3 WHEN away_goals = home_goals THEN 1 ELSE 0 END) AS points_away
    FROM matches
    GROUP BY away_team_id
)
SELECT
    t.team_name,
    hp.points_home,
    ap.points_away,
    hp.points_home - ap.points_away AS home_advantage_points
FROM teams t
JOIN home_points hp ON hp.team_id = t.team_id
JOIN away_points ap ON ap.team_id = t.team_id
ORDER BY home_advantage_points DESC;

-- 3) Last 5 matches form guide (points and goal difference)
-- Shows short-term form, useful for previews and betting trends.
WITH team_matches AS (
    SELECT
        m.match_id,
        m.match_date,
        m.home_team_id AS team_id,
        CASE WHEN m.home_goals > m.away_goals THEN 3 WHEN m.home_goals = m.away_goals THEN 1 ELSE 0 END AS points,
        (m.home_goals - m.away_goals) AS goal_diff
    FROM matches m
    UNION ALL
    SELECT
        m.match_id,
        m.match_date,
        m.away_team_id AS team_id,
        CASE WHEN m.away_goals > m.home_goals THEN 3 WHEN m.away_goals = m.home_goals THEN 1 ELSE 0 END AS points,
        (m.away_goals - m.home_goals) AS goal_diff
    FROM matches m
),
ranked AS (
    SELECT
        tm.*,
        ROW_NUMBER() OVER (PARTITION BY tm.team_id ORDER BY tm.match_date DESC, tm.match_id DESC) AS rn
    FROM team_matches tm
)
SELECT
    t.team_name,
    SUM(r.points) AS points_last_5,
    SUM(r.goal_diff) AS gd_last_5
FROM ranked r
JOIN teams t ON t.team_id = r.team_id
WHERE r.rn <= 5
GROUP BY t.team_name
ORDER BY points_last_5 DESC, gd_last_5 DESC;

-- 4) Top scorers from event-level data
-- Requires match_events entries where event_type = 'goal'.
SELECT
    p.full_name,
    t.team_name,
    COUNT(*) AS goals
FROM match_events e
JOIN players p ON p.player_id = e.player_id
JOIN teams t ON t.team_id = p.team_id
WHERE e.event_type = 'goal'
GROUP BY p.full_name, t.team_name
ORDER BY goals DESC, p.full_name;
