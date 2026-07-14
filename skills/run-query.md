# Skill: Run a Read-Only SQL Query

## Trigger

Any time you need to **read** from the eMed Azure DB — inspect a table, count
rows, check a value, debug data, explore the schema. Phrasings like "check the
DB", "how many X", "what's in table Y", "look up visit N", "run this query".

## Use the tool, not an ad-hoc `node -e`

There is a hardened read-only runner at **`emed_app/scripts/run_query.js`**.
Prefer it over hand-writing a `node -e "...require('mssql')..."` one-liner.

```bash
# from emed_app/
node scripts/run_query.js "SELECT TOP 5 * FROM moct_visit ORDER BY id DESC"

# from the eMed parent dir (works too — it loads emed_app/.env by absolute path)
node emed_app/scripts/run_query.js "SELECT COUNT(*) AS n FROM emed_user WHERE is_invalid=0"

# pretty table instead of JSON
node scripts/run_query.js --table "SELECT id, status FROM moct_visit WHERE id=123"

# multi-line query via stdin
echo "SELECT DB_NAME() AS db" | node scripts/run_query.js
```

### Why this exists (the important part)

`node -e "..."` runs **arbitrary code**, so it can never be added to a Claude
Code permission allowlist — every SQL read prompts the user for approval, which
is the single biggest source of "press Yes" fatigue in this project. `run_query.js`
is **hard-locked to read-only**, so its exact invocation *can* be allowlisted and
runs without a prompt.

Add these to `.claude/settings.json` → `permissions.allow` (repo where you run it):

```
Bash(node scripts/run_query.js:*)
Bash(node emed_app/scripts/run_query.js:*)
```

## What it guarantees (defense-in-depth)

Two independent layers — either one alone blocks a write; both must fail for a
mutation to persist:

1. **Statement gate.** The query must start with `SELECT` / `WITH` / `(`, and
   must not contain any write/DDL/exec/transaction keyword (`INSERT`, `UPDATE`,
   `DELETE`, `MERGE`, `DROP`, `ALTER`, `CREATE`, `TRUNCATE`, `GRANT`, `EXEC`,
   `sp_*`, `xp_*`, `BACKUP`, `INTO`, `BEGIN/COMMIT/ROLLBACK/TRAN`, …). Keyword
   matching strips string literals, `[bracketed]`/`"quoted"` identifiers, and
   comments first, so a column named `created_by` or a literal `'%update%'` does
   **not** false-trip it.
2. **Rollback.** The query runs inside a transaction that is **always rolled
   back**. Nothing it does can ever commit, even if the gate were bypassed.

A rejected query exits non-zero with `REJECTED (...)` and never touches the DB.

## Which database?

`emed_app/.env` `DB_NAME` is toggled between `liberty_link_stage` (prod) and
`liberty_link_dev` (dev) **by hand**, so you can't assume which one you're on.
The tool **always prints the connected DB + server to stderr first**, e.g.:

```
Connected to DB: liberty_link_dev  (server: liberty-link)  [READ-ONLY, will rollback]
```

Read that line before trusting results. To query the *other* DB, change
`DB_NAME` in `emed_app/.env` (this is the sanctioned mechanism — the tool has no
prod/dev switch, on purpose).

## When NOT to use it

- **Writes / DDL / schema changes** → not this tool. Follow `create-table.md`
  (write a migration in `emed_sql/migrations/pending/`, apply with
  `apply_migration.py`). Never mutate the DB from an ad-hoc script.
- **Calling a stored procedure** (`EXEC`) → blocked by design; use the proper
  ETL/app path or a migration.
- **Reading the live app's connection pool state** → this opens its own pool;
  it doesn't inspect the running server.

## Applies To

- **emed_app** — script lives at `emed_app/scripts/run_query.js`
- Requires `emed_app/.env` (DB_USER / DB_PASSWORD / DB_SERVER / DB_NAME)
- Imported by `emed_app/CLAUDE.md`
