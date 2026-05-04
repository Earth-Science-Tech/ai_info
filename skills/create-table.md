# Skill: Schema Change (Create Table / Add Column / Add View / Etc.)

## Trigger

Any time the user wants to change the database schema. This includes:

- "Create a new table for X"
- "Add a column to <table>"
- "Add a view that joins X and Y"
- "Create a stored procedure that does Z"
- "Add an index on <columns>"
- "Add a trigger that updates <something>"
- "Drop / rename / alter <something>"
- Any mention of creating, modifying, or removing a database object

## Hard Rules (Read These First)

1. **Schema changes go to `liberty_link_dev` first, NEVER directly to `liberty_link_stage` (production).**
2. **Never edit files inside `emed_sql/prod/` or `emed_sql/dev/` by hand.** They are auto-generated from the live database. Edits there will be silently overwritten.
3. **Always write a migration script in `emed_sql/migrations/`.** That is the only hand-written SQL file you should produce.
4. **Migrations must be idempotent** — `IF OBJECT_ID IS NULL` for new tables, `IF NOT EXISTS` for new columns/indexes, `CREATE OR ALTER` for views/procs/triggers. They will be re-run during `push prod` and must succeed without error each time.
5. **Every new object needs GRANT statements** in the same migration script (see `org/rules/sql-safety.md`).

## What to Do

### Step 1 — Write the migration script

Create `emed_sql/migrations/<YYYY-MM-DD>_<short_description>.sql`. Use today's date (the user's project memory has a `currentDate`; otherwise check via `date +%Y-%m-%d`).

The script must contain everything needed to bring `liberty_link_stage` into the desired state from its current state. Group related changes into one migration when they ship together.

#### Templates

**New table:**
```sql
-- migrations/2026-05-04_add_emed_widget.sql
-- Purpose: <one-line why>

IF OBJECT_ID('dbo.emed_widget', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.emed_widget (
        id INT IDENTITY(1,1) PRIMARY KEY,
        widget_name NVARCHAR(200) NOT NULL,
        widget_value NVARCHAR(MAX) NULL,
        sql_user NVARCHAR(100) DEFAULT SUSER_SNAME(),
        date_created DATETIME DEFAULT GETDATE(),
        date_modified DATETIME DEFAULT GETDATE(),
        is_invalid BIT DEFAULT 0
    );
END
GO

GRANT SELECT ON dbo.emed_widget TO emed_app;
GRANT INSERT ON dbo.emed_widget TO emed_app;
GRANT UPDATE ON dbo.emed_widget TO emed_app;
GO
```

**Add column to existing table:**
```sql
-- migrations/2026-05-04_add_moct_visit_priority_note.sql

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.moct_visit') AND name = 'priority_note'
)
BEGIN
    ALTER TABLE dbo.moct_visit ADD priority_note NVARCHAR(500) NULL;
END
GO
```

**New or updated view:**
```sql
-- migrations/2026-05-04_add_view_emed_active_prescribers.sql

CREATE OR ALTER VIEW dbo.view_emed_active_prescribers AS
    SELECT prescriber_id, full_name, license_state
    FROM dbo.emed_prescriber
    WHERE is_invalid = 0
      AND active_status = 'active';
GO

GRANT SELECT ON dbo.view_emed_active_prescribers TO emed_app;
GO
```

**New or updated stored procedure / trigger:** use `CREATE OR ALTER PROCEDURE` / `CREATE OR ALTER TRIGGER`.

### Step 2 — Apply to dev with one command

```bash
cd emed_sql
python python/apply_migration.py migrations/<your_file>.sql
```

This:
1. Connects to `liberty_link_dev` using `emed_sql/.env`
2. Splits the script on `GO` and executes each batch
3. Refreshes `emed_sql/dev/` by running `extract_sql_files.py --db dev`
4. Prints `diff prod/ dev/` so you can verify the migration captures the intended change

If a batch fails, the script stops and prints which one — fix the migration, re-run.

### Step 3 — Verify the diff

The output of step 2 should show your new files only in `dev/`, plus any modified files (e.g. for an added column, the `dev/table_<name>.sql` would differ). If the diff shows changes you didn't intend, your migration is doing more than expected — narrow it down.

### Step 4 — Commit emed_sql

```bash
cd emed_sql
git add migrations/<your_file>.sql dev/
git commit -m "feat(sql): <description>"
git push origin main
```

The `dev/` snapshot is part of the commit so other engineers see the intended end state.

### Step 5 — When ready to ship → "push prod"

The `push prod` skill (Phase 1.5) will detect the pending migration via the `prod/` ↔ `dev/` diff, apply it to `liberty_link_stage`, regenerate `prod/`, commit, and proceed with the deploy. You don't run apply_migration.py with `--db prod` manually — push prod handles it.

## Anti-Patterns to Avoid

- **Editing `prod/table_<name>.sql` to add a column.** The change won't survive — you need a migration.
- **Connecting directly to `liberty_link_stage` and running ALTER TABLE.** Bypasses the migration record. The next `push prod` will see drift it can't explain.
- **Migrations without `IF NOT EXISTS` / `IF OBJECT_ID IS NULL` guards.** They'll fail on re-run.
- **Forgetting GRANT statements.** The new object will exist but `emed_app` / `emed_etl` will get permission errors.
- **Migrations that mix unrelated changes.** Keep each migration focused on one logical change for clearer review and easier rollback.

## Applies To

- **emed_sql** — the migration script and regenerated snapshots
- **emed_app** — needs the new schema available before any code referencing it deploys
- **emed_etl** — needs grants if ETL accesses the object
