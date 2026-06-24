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
2. The `push prod` skill applying a reviewed migration — **run only by an authorized lead** (see "Database authority model" below)
3. A direct change made by Carlos Cueto (database engineer) when a migration-based flow isn't practical

## Database authority model (WHO may modify WHICH database)

The dev-first workflow above is *how* schema changes flow. This is *who* is allowed to apply them. **Default-deny: assume you may NOT write to `liberty_link_stage` (production) unless you can positively confirm you are operating as one of the two authorized leads below.** Check the operating user (their email / git identity) — if you can't confirm, treat prod as read-only.

| Person | Role | `liberty_link_dev` | `liberty_link_stage` (prod) |
|--------|------|--------------------|------------------------------|
| **Nicholas Cardell** (`nicholas.cardell@rxcs.net`) | Admin / engineering lead | ✅ | ✅ Owns prod promotion (`push prod`, `apply_migration.py --db prod` / `--db both`) |
| **Carlos Cueto** (git username `carcuet`) | Database engineer (DB expert) | ✅ | ✅ May modify **both** databases directly when needed |
| **Every other developer** | Engineer | ✅ dev only | ❌ Never — write the migration and hand it off |

### If you are a developer's Claude instance (anyone other than Nicholas or Carlos)

This is the common case. **Prioritize and restrict all schema work to `liberty_link_dev`:**

1. Apply migrations to **dev only**: `python python/apply_migration.py migrations/pending/<file>.sql` — no `--db` flag means dev. **Never** pass `--db prod` or `--db both`.
2. **Never** open a direct connection (mssql / REPL / SSMS / Node script) to `liberty_link_stage` to run `INSERT`/`UPDATE`/`DELETE`/DDL.
3. Your job ends at: change applied to dev → idempotent migration written in `migrations/pending/` → committed (PR'd if the repo uses PRs).
4. Then **stop and hand off.** Tell the user the migration is staged and ready for Nicholas (or Carlos) to ship to prod. Do **not** run the prod-applying step of `push prod` yourself.
5. Even if a prod change feels urgent, don't apply it — write the migration and explicitly flag it for Nicholas or Carlos. Urgency never overrides the authority model.

### If you are operating as Nicholas or Carlos

You may promote to prod (`push prod`, `--db prod`, `--db both`) per the `push-prod` and `create-table` skills. Carlos, as the DB expert, may additionally make direct changes to either database when the migration framework isn't practical — but prefer migrations so `emed_sql` stays the source of truth and the change is reproducible on dev.

## Cross-repo: code PRs that depend on a migration

Schema lives in `emed_sql`; the code that uses it lives in `emed_app` / `emed_etl`. When a code PR reads or writes a table/column/view that a migration introduces, the two live in **different repos and different PRs** — so the reviewer can't see the schema change from the code diff. Make that dependency explicit, or the reviewer will either miss it or have to go hunting (and a slightly stale `emed_sql` clone can make a perfectly good migration look like it doesn't exist).

In the code PR's description, **link the migration explicitly**:

- The migration **file path** (`emed_sql/migrations/pending/<date>_<desc>.sql`) and its **emed_sql PR/commit** — not just "migration added in emed_sql."
- **Where it's been applied**: dev only (the normal state — `migrations/pending/`), or dev + prod.
- **Deploy ordering**: the migration must be applied to prod **before or with** the code merge, never after. Code that queries a table prod doesn't have yet will throw at runtime.

Do **not** just write "already applied to dev" with no link — that reads as "trust me," and the reviewer has no way to verify the table's shape, its grants, or that prod will have it. A one-line `emed_sql` link turns a cross-repo guessing game into a 10-second check.

Corollary: **never apply schema straight to a database without committing the migration to `emed_sql` first.** Even when you've applied it to dev yourself, the committed `migrations/pending/` file (with grants + indexes) is what lets a lead ship the exact same change to prod. An un-committed dev change forces someone to reverse-engineer the DDL from the live DB — and they'll miss things like indexes and unique constraints that aren't obvious from the column list.

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

The platform uses three application-level database users. **Never use the admin account in application code.**

| User | Database(s) | Purpose | Used By |
|------|-------------|---------|---------|
| `emed_app` | `liberty_link_stage` | Node.js web application | emed_app |
| `emed_etl` | `liberty_link_stage`, `etst_warehouse` | Python ETL scripts; warehouse load + dbt build | emed_etl |
| `emed_reporting_user` | `etst_warehouse` — read-only on `core` + `mart`, plus SELECT on 6 `stg.emed_*` reporting tables (see [security/sql-permissions.md](../security/sql-permissions.md)) | BI / reporting / analytics tools | external reporting consumers |

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

| Scenario | emed_app | emed_etl | emed_reporting_user |
|----------|----------|----------|---------------------|
| Table in `liberty_link_stage` used by Node.js routes | SELECT, INSERT, UPDATE | — | — |
| Table in `liberty_link_stage` used by ETL scripts | — | SELECT, INSERT, UPDATE | — |
| Table in `liberty_link_stage` used by both | SELECT, INSERT, UPDATE | SELECT, INSERT, UPDATE, (DELETE if bulk reload) | — |
| New view in `liberty_link_stage` | SELECT | SELECT (if ETL queries it) | — |
| New stored procedure | — | EXECUTE | — |
| New dbt model in `etst_warehouse.core` or `mart` | — | (dbt-owned) | covered by schema-level GRANT — no per-object grant needed |
| New `etst_warehouse.stg` raw table | — | SELECT, INSERT, UPDATE, DELETE | — by default; object-level SELECT only if BI must read it directly (e.g. the `stg.emed_*` reporting tables) |
