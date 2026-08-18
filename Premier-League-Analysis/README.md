# Premier League Analysis (Advanced SQL)

This project builds a Premier League analytics database and includes advanced SQL queries with clear comments.

## Files

- `create_tables.sql` - clean database schema with constraints
- `insert values to stadium and teams.sql` - seed data + CSV match loader
- `advanced_analysis_queries.sql` - advanced analytics queries (league table, form, home advantage, top scorers)

## Recommended run order

1. Run `create_tables.sql`
2. Run `insert values to stadium and teams.sql`
3. Run queries from `advanced_analysis_queries.sql`

## Match data source

- https://datahub.io/football/english-premier-league/_r/-/season-2324.csv

Update `@csv_file` in the seed script to your local CSV path before running the loader section.

### MySQL `LOAD DATA LOCAL INFILE` prerequisites
- Ensure the server allows local infile (`local_infile=1`).
- Use a client invocation that enables it (example: `mysql --local-infile=1`).
