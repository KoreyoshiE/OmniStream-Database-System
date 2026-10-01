# OmniStream Database Project

A PostgreSQL coursework project for a video-streaming service. It covers relational schema design, seed data, analytical queries, a JSONB index, and a transaction rollback example.

## Contents

| Path | Contents |
|---|---|
| [`sql/DDL.sql`](sql/DDL.sql) | Tables, keys, constraints and the `pgcrypto` extension |
| [`sql/DML.sql`](sql/DML.sql) | Example users, subscriptions, movies and activity data |
| [`sql/DQL_and_TCL.sql`](sql/DQL_and_TCL.sql) | Analytical queries, JSONB GIN index and an intentional rollback demonstration |
| [`docs/`](docs/) | Design report and editable ER/schema diagrams |
| [`backup/`](backup/) | A PostgreSQL backup from the coursework environment |

The schema includes users, subscription plans, subscriptions, payment methods, invoices, movies, genres, watchlists, viewing history and reviews. The SQL uses joins, aggregations and JSONB metadata. The design report discusses normalization; the repository does not include a measured performance study.

## Recreate the example database

Use PostgreSQL with permission to create the `pgcrypto` extension. In a new database, run the schema and seed scripts in order:

```bash
psql -v ON_ERROR_STOP=1 -d omnistream -f sql/DDL.sql
psql -v ON_ERROR_STOP=1 -d omnistream -f sql/DML.sql
```

`sql/DQL_and_TCL.sql` contains example queries followed by an index creation and a deliberately invalid invoice insert inside a transaction. The invalid insert is intended to demonstrate a foreign-key failure and rollback, so do not treat the whole file as a successful migration or run it against a database you need to preserve. Review individual queries before running them.

The checked-in backup is a separate coursework artifact. Its restore procedure has not been verified here; use the ordered SQL files for inspection and fresh setup.
