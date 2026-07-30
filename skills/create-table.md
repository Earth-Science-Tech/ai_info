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
3. **Always write a migration script by hand** — it is the only hand-written SQL file you should produce. **Default location is `emed_sql/migrations/wip/`** while the feature is still in flight (its `feat/*` branch is unmerged to `main`). Move it `wip/ → pending/` only when the feature's `feat/* → main` promotion PR opens — `pending/` means "applies on the *next* `push prod`", so it must hold only migrations for features shipping next. (After it ships to prod, `apply_migration.py` auto-moves it to `migrations/applied/`.) See "On-hold / in-flight features" below.
4. **Migrations must be idempotent** — `IF OBJECT_ID IS NULL` for new tables, `IF NOT EXISTS` for new columns/indexes, `CREATE OR ALTER` for views/procs/triggers. They will be re-run during `push prod` and must succeed without error each time.
5. **Every new object needs GRANT statements** in the same migration script (see `org/rules/sql-safety.md`).

## What to Do

### Step 1 — Write the migration script

Create `emed_sql/migrations/wip/<YYYY-MM-DD>_<short_description>.sql` — **`wip/` is the default drop-point for in-flight feature work**; it moves to `pending/` when the feature's `feat/* → main` promotion PR opens (see Hard Rule 3 and "On-hold / in-flight features" below). Use today's date (the user's project memory has a `currentDate`; otherwise check via `date +%Y-%m-%d`). *(The templates below show a `pending/` path in their header comment for brevity — write the file into `wip/` while the feature is unready.)*

The script must contain everything needed to bring `liberty_link_stage` into the desired state from its current state. Group related changes into one migration when they ship together.

#### Templates

**New table:**
```sql
-- migrations/pending/2026-05-04_add_emed_widget.sql
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
-- migrations/pending/2026-05-04_add_moct_visit_priority_note.sql

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
-- migrations/pending/2026-05-04_add_view_emed_active_prescribers.sql

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
python python/apply_migration.py migrations/pending/<your_file>.sql
```

This:
1. Connects to `liberty_link_dev` using `emed_sql/.env`
2. Splits the script on `GO` and executes each batch
3. Refreshes `emed_sql/dev/` by running `extract_sql_files.py --db dev`
4. Prints `diff prod/ dev/` so you can verify the migration captures the intended change

The migration file stays in `migrations/pending/` until push-prod ships it to prod and auto-moves it to `migrations/applied/`.

If a batch fails, the script stops and prints which one — fix the migration, re-run.

### Step 3 — Verify the diff

The output of step 2 should show your new files only in `dev/`, plus any modified files (e.g. for an added column, the `dev/table_<name>.sql` would differ). If the diff shows changes you didn't intend, your migration is doing more than expected — narrow it down.

Then run the drift checker to confirm your migration actually **covers** the dev change (it catches a *partial* migration — e.g. one that ships the table but forgot a new column):

```bash
python python/check_migration_drift.py
```

Your object must NOT appear under "UNCOVERED". If it does, your `pending/` migration doesn't reference everything you changed on dev — fix it. And if schema was built directly on dev with no migration at all, recover it in one command: `python python/check_migration_drift.py --scaffold` reverse-engineers a draft idempotent migration (with grants) into `pending/` from the live dev catalog for you to review.

### Step 4 — Commit emed_sql

```bash
cd emed_sql
git add migrations/pending/<your_file>.sql dev/
git commit -m "feat(sql): <description>"
git push origin main
```

The `dev/` snapshot is part of the commit so other engineers see the intended end state.

### Step 5 — When ready to ship → open the promotion PR, then "push prod"

When the feature is ready, move its migration `wip/ → pending/` (`git mv`) **at the moment you open the feature's `feat/* → main` PR**, and name the file in the PR's "Schema changes" section. The `push prod` skill (run by a gatekeeper after the PR merges) applies **only the migration file(s) that PR declared** to BOTH databases with `apply_migration.py --db both --confirm`, commits the regenerated snapshots, and proceeds with the deploy. You don't run that command manually — push prod handles it.

## On-hold / in-flight features → `migrations/wip/` (the default while unready)

**`migrations/pending/` means "apply to prod on the *next* `push prod`."** So a migration only belongs in `pending/` once its feature is finished and its `feat/* → main` promotion PR is opening — until then it lives in `wip/`.

**`migrations/wip/` is the default home for a feature's migration while its code is still in flight** (on the `feat/*` branch, not yet merged to `main`) — whether it is being actively built, on hold, deprioritized, or waiting on its PR. `push prod` does **not** scan `wip/`, so nothing there can ship by accident — but the schema stays captured, reproducible, and shippable on demand. This is the schema analog of "unready code stays on its feature branch, off `main`."

Rules of thumb:
- Still apply the migration to **dev** (`apply_migration.py migrations/wip/<file>.sql` works from any path) and still write it idempotent with GRANTs — `wip/` is a real migration, just parked.
- If you create a table directly on dev for a prototype, **write the migration anyway** and park it in `wip/`. Never leave dev-only schema with no migration — that schema becomes un-shippable (someone has to reverse-engineer the DDL later).
- Keep a one-line entry per parked feature in `migrations/wip/STATUS.md` (owner, tables, why it's on hold, where the code lives).
- **To ship a feature:** move its file(s) `wip/ → pending/` (`git mv`) when you open the feature's `feat/* → main` promotion PR, and name them in the PR's "Schema changes" section. `push prod` then applies only those declared files.

## Hotfix Flow (Authorized Leads Only)

**This flow is restricted to the two people authorized to write production — Nicholas Cardell (admin / engineering lead) or Carlos Cueto (database engineer).** See the "Database authority model" in `org/rules/sql-safety.md`. If you are operating as anyone else, do NOT use `--db both` or `--db prod` — stay on dev, write the migration, and hand it off.

For an authorized lead shipping a schema change directly to production, use `--db both` from the start. This applies the migration to dev AND prod in one step, keeping the two databases in sync so engineers' dev work doesn't fall behind.

### When to use this flow

- You have positively confirmed you are operating as Nicholas or Carlos, AND
- An urgent production fix that can't wait for dev review, or the user explicitly says "hotfix", "directly to prod", "I'll skip dev", or similar

### Steps

1. Write the migration (same templates as Step 1 above)
2. Apply to BOTH databases:
   ```bash
   cd emed_sql
   python python/apply_migration.py migrations/pending/<your_file>.sql --db both --confirm
   ```
   The script applies to **dev first** (so a buggy migration fails on dev, not prod), then to prod. Both snapshot folders are regenerated.
3. Verify the diff is clean (only unrelated in-flight dev work should differ):
   ```
   === Diff: prod/ vs dev/ ===
   Files prod/table_emed_widget.sql and dev/table_emed_widget.sql differ   ← unrelated dev work
   No schema differences for <hotfix table>.
   ```
4. Commit:
   ```bash
   git add migrations/ prod/ dev/
   git commit -m "feat(sql): <hotfix description>"
   git push origin main
   ```
5. Then `push prod` for the Node.js side. Phase 1.5 of push prod will see the migration is **already applied** (dev/prod already match for this object), so it won't re-run. Phase 2 just deploys the code.

### Why both databases?

Engineers' dev branches keep `liberty_link_dev` as their working schema. If you hotfix prod-only, dev falls behind, and the next engineer who runs `apply_migration.py` for unrelated work sees confusing drift. Applying to both keeps the two in lock-step.

### Engineers' in-flight work

If an engineer was actively working on the same table on dev (uncommon but possible), the migration might create a no-op on dev (idempotent guards) or a real change. Either way, `IF NOT EXISTS` / `CREATE OR ALTER` keeps things safe — the engineer's separate migration will continue to work.

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
