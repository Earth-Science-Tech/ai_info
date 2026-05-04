# SQL Safety Rules

## The dev-first workflow (HARD RULE)

**All schema changes go through `liberty_link_dev` first, then promote to `liberty_link_stage` (production) via a migration script.** Never edit production directly.

```
liberty_link_dev   ←  engineer makes change here first
       ↓
emed_sql/migrations/pending/<YYYY-MM-DD>_<desc>.sql   ←  hand-written, idempotent
       ↓
liberty_link_stage   ←  applied via "push prod" skill
```

### Run the migration with one command

The engineer's standard tool:

```bash
cd emed_sql
python python/apply_migration.py migrations/pending/<YYYY-MM-DD>_<desc>.sql
```

This applies the migration to `liberty_link_dev`, regenerates `dev/`, and shows the `prod/` vs `dev/` diff so you can verify the migration captures the full change. The `--db prod --confirm` flag exists for the "push prod" path; never invoke it manually.

### NEVER EDIT THESE BY HAND

| Path | Why |
|------|-----|
| `emed_sql/prod/*.sql` | Auto-generated from `liberty_link_stage`. Edits will be lost on next regeneration. |
| `emed_sql/dev/*.sql` | Auto-generated from `liberty_link_dev`. Same. |
| `emed_sql/prod/info.claude`, `emed_sql/dev/info.claude` | Auto-generated markdown summary. |
| `emed_sql/prod/_GENERATED.md`, `emed_sql/dev/_GENERATED.md` | Auto-generated metadata. |

The only hand-edited SQL files in `emed_sql/` are:
- `migrations/pending/<YYYY-MM-DD>_<desc>.sql` — new migrations (auto-moved to `migrations/applied/` after shipping to prod)
- `create_emed_app_user.sql` and `create_emed_etl_user.sql` — bootstrap (rarely changed)

If you find yourself editing a file in `prod/` or `dev/`, STOP — you almost certainly want to write a migration instead.

### NEVER touch liberty_link_stage directly

Do not run `INSERT`/`UPDATE`/`DELETE`/DDL against `liberty_link_stage` from a script, REPL, or SSMS during development. The only sanctioned writes to prod are:
1. The application's runtime database connection (uses `emed_app` / `emed_etl` users, never admin)
2. The `push prod` skill applying a reviewed migration

## Mandatory Table Fields

ALL tables in the database MUST include these fields:

```sql
id INT IDENTITY(1,1) PRIMARY KEY,
sql_user NVARCHAR(100) DEFAULT SUSER_SNAME(),
date_created DATETIME DEFAULT GETDATE(),
date_modified DATETIME DEFAULT GETDATE(),
is_invalid BIT DEFAULT 0
```

## Least-Privilege Database Users

The platform uses two application-level database users. **Never use the admin account in application code.**

| User | Purpose | Used By |
|------|---------|---------|
| `emed_app` | Node.js web application | emed_app |
| `emed_etl` | Python ETL scripts | emed_etl |

## MANDATORY: Permission Grants for New Objects

**Every new table, view, or stored procedure requires explicit GRANT statements** in the migration script. These users have NO default permissions.

### Migration template

```sql
-- migrations/2026-05-04_add_<domain>_<name>.sql

IF OBJECT_ID('dbo.<domain>_<name>', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.<domain>_<name> (
        id INT IDENTITY(1,1) PRIMARY KEY,
        -- table columns
        sql_user NVARCHAR(100) DEFAULT SUSER_SNAME(),
        date_created DATETIME DEFAULT GETDATE(),
        date_modified DATETIME DEFAULT GETDATE(),
        is_invalid BIT DEFAULT 0
    );
END
GO

GRANT SELECT ON dbo.<domain>_<name> TO emed_app;
GRANT INSERT ON dbo.<domain>_<name> TO emed_app;
GRANT UPDATE ON dbo.<domain>_<name> TO emed_app;
-- Only if ETL also accesses this table:
-- GRANT SELECT ON dbo.<domain>_<name> TO emed_etl;
-- GRANT INSERT ON dbo.<domain>_<name> TO emed_etl;
-- GRANT UPDATE ON dbo.<domain>_<name> TO emed_etl;
GO
```

### Permission Rules

- **Never grant DELETE to emed_app** — uses soft delete (`UPDATE is_invalid = 1`). Exception: `sessions` table.
- **Never grant DDL** (CREATE, ALTER, DROP) — explicitly DENYed for both users.
- **Grant DELETE to emed_etl** only for bulk delete-and-reload tables.
- **Grant EXECUTE** on stored procedures to emed_etl if ETL calls them.
- Temp tables (`#TempXxx`) don't need permissions.

### Quick Decision Matrix

| Scenario | emed_app | emed_etl |
|----------|----------|----------|
| Table used by Node.js routes | SELECT, INSERT, UPDATE | — |
| Table used by ETL scripts | — | SELECT, INSERT, UPDATE |
| Table used by both | SELECT, INSERT, UPDATE | SELECT, INSERT, UPDATE, (DELETE if bulk reload) |
| New view | SELECT | SELECT (if ETL queries it) |
| New stored procedure | — | EXECUTE |
