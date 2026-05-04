# Skill: Create Table

## Trigger

When creating a new database table in the eMed platform.

## Where Schema Changes Happen

All schema changes start on `liberty_link_dev` (the dev database) and migrate to `liberty_link_stage` (production) via the `push prod` workflow. Never edit `liberty_link_stage` directly.

## What to Do

### Step 1: Write the migration script

Create `emed_sql/migrations/<YYYY-MM-DD>_<description>.sql` with the table creation, indexes, and grants — all idempotent so it can be re-run safely.

```sql
-- migrations/2026-05-04_add_<domain>_<name>.sql
-- Purpose: <one-line why>

IF OBJECT_ID('dbo.<domain>_<name>', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.<domain>_<name> (
        id INT IDENTITY(1,1) PRIMARY KEY,
        -- table-specific columns here
        sql_user NVARCHAR(100) DEFAULT SUSER_SNAME(),
        date_created DATETIME DEFAULT GETDATE(),
        date_modified DATETIME DEFAULT GETDATE(),
        is_invalid BIT DEFAULT 0
    );
END
GO

-- Permission grants (every new object needs these)
GRANT SELECT ON dbo.<domain>_<name> TO emed_app;
GRANT INSERT ON dbo.<domain>_<name> TO emed_app;
GRANT UPDATE ON dbo.<domain>_<name> TO emed_app;
-- Only if ETL also needs access:
-- GRANT SELECT ON dbo.<domain>_<name> TO emed_etl;
-- GRANT INSERT ON dbo.<domain>_<name> TO emed_etl;
-- GRANT UPDATE ON dbo.<domain>_<name> TO emed_etl;
GO

-- date_modified trigger (if the table will be UPDATEd)
-- See trigger_*.sql in prod/ for the standard template.
```

### Step 2: Apply the migration to liberty_link_dev

Run the migration script against `liberty_link_dev` using SSMS or sqlcmd.

### Step 3: Refresh the dev/ snapshot

```bash
cd emed_sql
python python/extract_sql_files.py --db dev
```

This regenerates `dev/table_<name>.sql`, `dev/migration_grant_permissions_<name>.sql`, and updates `dev/migration_fk_constraints.sql` if the table has FKs.

### Step 4: Verify with diff

```bash
diff -rq dev/ prod/ | grep <name>
```

Should show your new files only in `dev/`. The migration in `migrations/<...>.sql` should fully cover this drift.

### Step 5: When ready to deploy → "push prod"

The `push prod` skill (Phase 1.5) detects the pending migration and dev/prod drift, runs the migration on `liberty_link_stage`, regenerates `prod/`, and commits.

## Rules

- **Never grant DELETE to emed_app** — soft delete only via `UPDATE is_invalid = 1`. Exception: `sessions` table.
- **Never grant DDL** (CREATE/ALTER/DROP) to either user — explicitly DENYed.
- **Use domain prefix naming**: `moct_*`, `emed_*`, `rxcs_*`, etc.
- **Always include all 5 mandatory fields** (id, sql_user, date_created, date_modified, is_invalid).
- **Migrations must be idempotent** — guard with `IF OBJECT_ID IS NULL` for tables, `CREATE OR ALTER` for views/procs/triggers.
- **Never edit files in `prod/` or `dev/` by hand** — they're auto-generated from the live DB.

## Applies To

- **emed_sql** — the migration script and regenerated snapshot files
- **emed_app** — needs the new table available before any code referencing it deploys
- **emed_etl** — needs grants if ETL accesses the table
