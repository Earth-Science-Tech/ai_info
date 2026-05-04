# Skill: Claude Onboarding

## Trigger

When a new engineer (or their Claude instance) is setting up the eMed platform on a fresh machine. Common phrases:

- "claude onboarding" / "onboard me"
- "set up eMed locally" / "first-time setup" / "new machine"
- "clone the repos" / "where do I start"
- "set up my dev environment"

## Goal

Walk the engineer through cloning all four eMed repositories as siblings, configuring credentials, installing dependencies, and verifying the dev-first schema workflow works end-to-end before they touch real code.

## The four repositories

| Repo | Role | Required? |
|------|------|-----------|
| **ai_info** | Shared AI knowledge base — every project's CLAUDE.md `@imports` files from here. Without it, Claude won't know the team's conventions or skills. | Yes (clone first) |
| **emed_sql** | Canonical schema (prod/, dev/, migrations/) + Python tooling for both databases. | Yes |
| **emed_app** | Node.js / Express web application. Production-deployed via Azure App Service. | If working on the app |
| **emed_etl** | Python / Prefect ETL scripts (Peaks, Liberty, SMS). | If working on ETL |

**CRITICAL: All four must be cloned as siblings under one parent directory.** The `@../ai_info/...` imports in every project's CLAUDE.md are relative paths — if ai_info is somewhere else, none of the team's skills/rules load.

## Prerequisites

Verify these are installed before starting:
- **Git** (`git --version`)
- **Python 3.10+** (`python --version`)
- **Node.js 22+** (`node --version`) — only if working on emed_app
- **ODBC Driver 17 for SQL Server** — required by `pyodbc`. On Windows, install from Microsoft. On macOS/Linux, install via package manager.

If any are missing, install before continuing.

## Step 1 — Choose a parent directory

```bash
mkdir -p ~/dev/eMed
cd ~/dev/eMed
```

The directory name doesn't matter, but the four repos must live directly inside it.

## Step 2 — Clone all four repos

```bash
git clone https://github.com/Earth-Science-Tech/ai_info.git
git clone https://github.com/Earth-Science-Tech/emed_sql.git
git clone https://github.com/Earth-Science-Tech/eMed.git emed_app          # note: GH name is "eMed", local dir is emed_app
git clone https://github.com/Earth-Science-Tech/emed_etl.git
```

After cloning, verify the layout:

```bash
ls
# Expected: ai_info  emed_app  emed_etl  emed_sql
```

If a project's CLAUDE.md says "Clone ai_info if missing", the engineer's Claude will spot it but `@imports` will silently render nothing — re-clone if you see broken imports.

## Step 3 — Configure credentials

### emed_sql/.env (required for schema work)

```bash
cd emed_sql
cp .env.example .env
# Edit .env and fill in:
#   DB_SERVER          (liberty-link.database.windows.net)
#   DB_DATABASE        (liberty_link_stage)
#   DB_DATABASE_DEV    (liberty_link_dev)
#   DB_USERNAME        (Azure SQL admin user)
#   DB_PASSWORD        (Azure SQL admin password)
```

Get credentials from the team lead. The admin account is shared and used only by Python schema tooling; application code uses the least-privilege `emed_app` and `emed_etl` users created by the bootstrap scripts.

### emed_app/.env (required to run the Node.js app)

`emed_app/.env` has its own variables for the application's runtime DB connection (using `emed_app` user, not admin), Azure email, WordPress integration, etc. Get the canonical example from the team lead — the keys differ from emed_sql's.

### emed_etl/.env (required to run ETL)

Same pattern — separate `.env` for ETL runtime credentials. Has the same DB vars plus WooCommerce, SSH, and RingCentral creds.

**`DB_DATABASE_DEV` only lives in `emed_sql/.env`.** Application/ETL code doesn't need it because runtime always targets prod (`DB_DATABASE=liberty_link_stage`).

## Step 4 — Install dependencies

```bash
# emed_sql Python tooling
cd ../emed_sql
pip install pyodbc python-dotenv

# emed_app Node.js
cd ../emed_app
npm install

# emed_etl Python ETL
cd ../emed_etl
pip install -r requirements.txt
```

## Step 5 — Verify the schema workflow (read-only)

This proves credentials work and the dev/prod separation is real, without touching either database:

```bash
cd ../emed_sql

# Dry-run against prod (only counts objects, doesn't write files)
python python/extract_sql_files.py --db prod --dry-run

# Dry-run against dev
python python/extract_sql_files.py --db dev --dry-run
```

Expected output for each: `Tables: 100+`, `Views: ~20`, `Procedures: ~10`, etc., with no errors. If you get a "Login failed" error, your credentials are wrong. If you get "DB_DATABASE_DEV is not set", the env file is missing or in the wrong location.

## Step 6 — Verify the diff between prod and dev

```bash
ls migrations/pending/    # should list any unapplied migrations
diff -rq prod/ dev/ | head -20
```

If `prod/` and `dev/` are in sync, you'll see only `_GENERATED.md` differences. If `pending/` has files, those are queued migrations that the next `push prod` will apply.

## Step 7 — Read the key context files

In your project of choice, the most important files for getting oriented:

- `<project>/CLAUDE.md` — top-level architecture and conventions
- `ai_info/org/rules/sql-safety.md` — SQL workflow hard rules
- `ai_info/skills/create-table.md` — schema change workflow
- `ai_info/skills/push-prod.md` — production deploy workflow
- `emed_sql/RUNBOOK.md` — copy-paste recipes for common SQL operations
- `emed_sql/prod/info.claude` — markdown summary of the production schema

Tell the engineer: "Once you're in a project directory, your Claude instance will auto-read CLAUDE.md and its imports — the workflow rules and skills load automatically."

## Step 8 — Trigger phrases the engineer should know

After setup, common phrases automatically trigger the right skills:

| Phrase | What happens |
|--------|--------------|
| "create a new table for X" | `create-table.md` skill: writes migration in `emed_sql/migrations/pending/`, runs `apply_migration.py --db dev` |
| "add a column to <table>" | Same skill — handles all schema changes |
| "push prod" | `push-prod.md` skill: Phase 1 audit, applies pending migrations to both DBs, deploys |
| "push prod yolo" | Skip Phase 1 audit (hotfix only) |
| "review pr" | Cross-repo PR review against the ETST checklist |
| "claude title" | One-line summary card for this conversation |
| "claude reload" | Re-read CLAUDE.md and all `@imports` mid-session |

## Step 9 — Confirm setup is complete

After the engineer completes Step 5 successfully, output:

```
Setup complete. You're ready to:
- Make schema changes (start with "create a new table" or "add a column")
- Run the app or ETL locally
- Open and review PRs (start with "review pr")

Three rules to remember:
1. All schema changes go through emed_sql/migrations/pending/. Never edit prod/ or dev/ by hand.
2. Never write .sql files in emed_app or emed_etl. Schema lives in emed_sql.
3. The ai_info repo MUST be cloned as a sibling of the others — without it, none of these workflow rules load.
```

## Common pitfalls

| Symptom | Cause | Fix |
|---------|-------|-----|
| "Cannot resolve `@../ai_info/...`" | ai_info not cloned, or in wrong location | Clone it as a sibling: `cd <parent> && git clone https://github.com/Earth-Science-Tech/ai_info.git` |
| "Login failed for user" | Wrong creds, or wrong DB var | Test creds in SSMS first; ensure `DB_DATABASE_DEV` is set in `emed_sql/.env` (not in app/etl `.env`) |
| Hook blocks Edit on a `.sql` file in emed_app | Working as intended | Schema work goes in `emed_sql/migrations/pending/`, not in emed_app |
| Hook blocks Edit on `prod/<file>.sql` | Working as intended | Auto-generated. Write a migration instead. |
| `pyodbc` install fails | Missing ODBC Driver 17 | Install Microsoft ODBC Driver for SQL Server first |

## Applies To

- All projects, all engineers. Imported by every project's `CLAUDE.md`.
