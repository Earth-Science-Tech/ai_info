# Skill: Push Prod

## Trigger

When the user says **"push prod"** or similar.

## Two-Phase Flow

This skill has two phases. **Always run Phase 1 first and wait for explicit user confirmation before running Phase 2.** The only exception is the emergency bypass below.

- **Phase 1 — Pre-flight investigation:** read-only sanity check on the changes about to ship.
- **Phase 2 — Push steps:** the actual commit / push / tag operations.

### Emergency bypass

If the user says **"push prod yolo"**, **"push prod skip checks"**, or **"push prod no review"**, skip Phase 1 entirely and go straight to Phase 2. Use only for hotfixes when the change is already known to be safe.

## Phase 1: Pre-Flight Investigation

### Step 1 — Snapshot the change set

Run in parallel (read-only, no commits yet):

```bash
git status                                  # uncommitted/untracked
git diff                                    # unstaged changes
git diff --cached                           # staged changes
git describe --tags --abbrev=0              # last released tag
git log <last_tag>..HEAD --oneline          # commits since last release
git diff <last_tag>..HEAD --stat            # file-level summary since last release
git diff <last_tag>..HEAD                   # full diff since last release (large — sample if huge)
```

If `git diff <last_tag>..HEAD` exceeds ~2000 lines, read the `--stat` output, identify the highest-risk files (auth, billing, prescriptions, SQL migrations, ETL writes), and read those file diffs in full while sampling the rest.

### Step 1.5 — SQL drift check (always run if `emed_sql/` exists)

Detect pending schema changes automatically — **against the live databases**, which is authoritative. Run the drift checker: it diffs live `liberty_link_dev` vs `liberty_link_stage` and classifies every dev-ahead object/column as covered by `pending/` (ships), parked in `wip/` (held on purpose), or **UNCOVERED** (no migration exists anywhere — the failure this step must catch).

```bash
cd ../emed_sql                                # adjust path as needed
python python/check_migration_drift.py        # exits non-zero if any UNCOVERED drift
ls migrations/pending/*.sql 2>/dev/null       # list what will ship
```

Why the tool and not just `diff -rq prod/ dev/`: the snapshot-folder diff only compares the committed `prod/`/`dev/` files, so it is blind whenever someone changed the dev DB but never regenerated/committed the `dev/` snapshot — which is exactly the situation that leaves a migration missing. `check_migration_drift.py` reads the live catalogs, so a stale snapshot can't hide drift from it.

**Only `pending/` ships.** `migrations/wip/` is a holding area for on-hold / not-ready features and is intentionally **never** applied by push prod — do not scan it, do not apply it. Expect the `prod/` ↔ `dev/` diff to show dev-ahead objects whose migrations live in `wip/` (or that are documented in `wip/STATUS.md`); those are **known, intentional drift**, not an out-of-band change. Only treat dev/prod drift as a problem when it's covered by neither `pending/` nor `wip/`.

Read each pending migration file to confirm it:
- Has idempotent guards (`IF OBJECT_ID IS NULL`, `IF NOT EXISTS`, `CREATE OR ALTER`)
- Includes `GRANT` statements for any new object
- Doesn't touch `liberty_link_stage` directly outside of the migration framework

If `migrations/pending/` is empty AND `diff prod/ dev/` is empty, there are no SQL changes — set the SQL Drift finding to `[PASS] N/A` and move on.

If `migrations/pending/` has files, list them in the Phase 1 report under "SQL changes" so the user knows exactly what will be applied. Phase 2 will run them automatically — the user just confirms the report.

Reject the push if:
- A pending migration is non-idempotent (will fail on re-run)
- A new table/view/procedure exists without a corresponding `GRANT`
- `check_migration_drift.py` reports **UNCOVERED** drift (dev-ahead schema that no `pending/` or `wip/` migration covers — it exits non-zero). This is the "missing migration" case. **HARD STOP: do not proceed, and do NOT reverse-engineer the DDL by hand.** Recover it deterministically instead: run `python python/check_migration_drift.py --scaffold`, review each generated draft in `migrations/pending/`, confirm it's idempotent by applying to dev (`python python/apply_migration.py migrations/pending/<file>.sql`), commit the migration to emed_sql, then re-run push prod. (Drift the tool classifies as `wip`-parked or prod-ahead is NOT a reject — that's intentional on-hold work / a prod change not yet backported to dev.)

### Step 1.6 — Per-page permission registry check (always run if `emed_app/` changed)

eMed is **fully modular by permission**: every sidebar page has its own `View_Page_*` (Read) and, unless read-only, `Write_Page_*` (Write) flag, all defined in `emed_app/server/page_catalog.js`. A page that ships in the sidebar **without** being registered is invisible to the role system and makes custom roles 500 / "no permission" on it. This check is the safety net that catches exactly that.

```bash
cd ../emed_app                          # adjust path as needed
node scripts/check_page_registry.js     # exits non-zero if the registry is incomplete or non-neutral
```

It is git-only + DB-free (uses code-defined roles), so it never blocks a deploy for infra reasons. It verifies: (1) every sidebar nav-link points at a registered page; (2) **write-gate neutrality** — no built-in role is newly denied a write it can do today; (3) no `WRITE_ROUTES` entry references a non-existent / read-only page; (4) every flag has a tooltip. The same invariants run in CI on every PR (`tests/unit/server/page_registry.test.js`), so this is normally already green — but re-run it here because push-prod can ship a `dev`-batch or hotfix that never went through a PR.

**If it FAILS:** a new page needs registering. Do **not** hand-wave it — follow the **add-page skill** (`ai_info/skills/add-page.md`): register the page in `page_catalog.js` (PAGES + REQUIRES + WRITE_CAP + WRITE_ROUTES) and gate its sidebar link on `pg('Key')`. If a flagged link is genuinely not a page (auth/self-service), add it to `SIDEBAR_EXCLUDE` in the checker with a one-line reason. Re-run until green. Set the Step 3 finding to `[FAIL]` and **do not push** until it passes. If `emed_app/` has no page/sidebar/permission changes, it still passes in ~1s — set the finding to `[PASS]`.

### Step 2 — Run the ETST checklist on the diff

Apply the same categories used in `skills/review-pr.md`, but to the local working state vs. last released tag.

#### Security
- No hardcoded secrets, API keys, passwords, connection strings
- No `.env` / `.env.local` files staged
- No credentials in `console.log` / `print` / debug output
- New routes have auth middleware; CSRF on state-changing endpoints
- Inputs validated; queries parameterized (no SQL injection vectors)
- No verbose stack traces leaked to clients

#### SQL Safety (only if `.sql` files changed)
- New tables include all 5 mandatory fields: `id`, `sql_user`, `date_created`, `date_modified`, `is_invalid`
- Permission grant migration script exists for every new table/view/procedure
- No `DELETE` granted to `emed_app` (soft delete only via `is_invalid`)
- No DDL granted to application users
- Domain prefix naming followed (`moct_*`, `emed_*`, `rxcs_*`, etc.)

#### Naming Conventions
- Backend files: snake_case; routes: `route_*.js`
- Frontend files: kebab-case
- Python scripts: `<domain>_<action>` prefix
- SQL files: `table_*`, `migration_*`, `procedure_*`

#### Code Quality
- No leftover `console.log`, `debugger`, `print(`, `// XXX`, `// REMOVE ME` markers
- No large blocks of commented-out code
- Error handling on new routes / DB calls
- New env vars added to `.env.example` (without secrets)

#### Documentation
- `CLAUDE.md` / `info.claude` updated if architecture, routes, schema, or endpoints changed
- New tables reflected in schema docs (run `extract-schema` if needed)
- Commit messages follow `type(scope): description`

#### Risk Assessment
Identify the blast radius. Flag any of these as **HIGH RISK**:
- Authentication / MFA / session handling changes
- Billing / invoicing / pricing logic changes
- Prescription writing / `moct_drug_rx` writes
- Database schema migrations (especially destructive: drops, alters, NOT NULL on existing columns)
- ETL writes to shared tables
- Changes to `route_public.js` (unauthenticated surface)
- Changes to permission grants or roles

### Step 3 — Output the report

Use exactly this format:

```
## Pre-flight check for production push

**Changes since <last_tag>:** <N> commits, <M> files (+<X> / -<Y> lines)
**Areas touched:** <auth | billing | moct | etl | sql | views | etc.>
**Proposed next tag:** <last_tag incremented by patch>

### Findings
- [PASS|WARN|FAIL] Security — <one-line note>
- [PASS|WARN|FAIL] SQL Safety — <note or "N/A — no SQL changes">
- [PASS|WARN|FAIL] SQL Drift — <files in dev/ not in prod/, pending migrations, or "N/A">
- [PASS|WARN|FAIL] Per-page perms — <registry check result: N pages/routes neutral, or "N/A — no page/sidebar/permission change">
- [PASS|WARN|FAIL] Naming — <note>
- [PASS|WARN|FAIL] Code Quality — <note>
- [PASS|WARN|FAIL] Documentation — <note>

### SQL changes (if any)
- Migrations to run on `liberty_link_stage`: <list filenames or "none">
- After migrations: regenerate `prod/` with `python python/extract_sql_files.py --db prod`

### Risk: <LOW | MEDIUM | HIGH>
<1–2 sentence reasoning naming specific risk vectors>

### Recommendation: <PROCEED | PROCEED WITH CAUTION | DO NOT PUSH>
```

### Step 4 — Confirmation gate

- **All PASS, risk LOW** → ask: "Looks clean. Proceed with push to prod?"
- **Any WARN** → list the warnings and ask: "Proceed despite warnings?"
- **Any FAIL** → list the failures, recommend fixing first, and **do NOT push** unless the user explicitly says "push anyway" / "override" / similar.

Wait for the user's reply before doing anything in Phase 2.

## Phase 2: Push Steps

Only run after Phase 1 confirmation (or emergency bypass).

Run on a **clean, up-to-date `main`** — normally right after the feature's `feat/* → main` promotion PR
has merged (feature-promotion lane), or after fast-forwarding `main` to a fully-ready `dev` SHA (batch
lane; valid only when *everything* on `dev` ahead of `main` is shipping). Do **not** run from `dev`, and
do **not** auto-commit unrelated working-tree changes onto `main` — the tag is cut on `main` HEAD.
(See `org/rules/branch-and-database-gates.md` → "Release model".)

### Step 0 — Apply pending SQL migrations (only if Phase 1 found drift)

Do NOT reach this step while `check_migration_drift.py` still reports **UNCOVERED** drift — Phase 1 must be clean first (every uncovered item either scaffolded + committed into `pending/`, or intentionally moved to `wip/`).

**Guard against strays first.** In the feature-promotion model, `migrations/pending/` should hold **only**
the migrations for the feature(s) in *this* release (each was moved `wip/ → pending/` when its promotion PR
opened). Compare `ls migrations/pending/*.sql` against the feature(s) being shipped. If `pending/` holds a
migration that is **not** part of this ship — a leftover from another feature — **STOP**: move it back to
`wip/` (or explicitly fold it into this release). This prevents eMed's recurring "an unrelated migration
stranded in `pending/` rides along on the next push prod" landmine.

Apply **only the migration file(s) confirmed in the Phase 1 report** (the ones belonging to the shipping
feature[s]) — not a blind `pending/*.sql` glob:

```bash
cd ../emed_sql
# PENDING=( the pending/ files confirmed in Phase 1 — one per feature being shipped )
for f in "${PENDING[@]}"; do
    python python/apply_migration.py "$f" --db both --confirm || exit 1
done
python python/check_migration_drift.py    # re-verify: should report no uncovered drift now
```

(When `pending/` legitimately contains exactly this release's migrations and nothing else — the normal
case — that set *is* every file under `pending/`.)

What this does for each file:
- Applies to `liberty_link_dev` first (catches bugs without touching prod)
- Applies to `liberty_link_stage`
- Regenerates `prod/` and `dev/` snapshot folders
- Auto-moves the migration from `pending/` → `applied/`

If any migration fails, stop the loop — do NOT continue, do NOT proceed to the Node.js push. Report the failure and let the user fix the migration.

After all migrations succeed, commit and push `emed_sql`:

```bash
cd ../emed_sql
git add migrations/ prod/ dev/
git commit -m "chore(sql): apply <count> migration(s) to prod and dev"
git push origin main
```

The commit message should briefly list the migrations applied. Then proceed to Step 1 of the Node.js push.

### Step 0.5 — Update the in-app Change Log (before committing)

eMed has an Admin-only **Change Log** page (`/admin/change-log`) backed by the version-controlled file
`emed_app/data/changelog.json`. Each production release gets one curated, PHI-safe entry. Because the
entry is committed **with** the release, write it now — before the Step 1 commit — so it ships inside
the tag.

The next version is already known here: for a standard "push prod" it's `git describe --tags
--abbrev=0` with the patch incremented; for "push prod x.x.x" it's the explicit version. Scaffold a
draft from the commits in range, then curate it:

```bash
cd ../emed_app   # must run from emed_app/ so the repo + roster paths resolve
node scripts/changelog.js scaffold <new-version>   # prepends a DRAFT entry to data/changelog.json
```

The script (git-only; no DB, no `.env`, never blocks a deploy):
- Fills `version`, `date` (today), and `pushed_by` (`git config user.name`, resolved to a real name via
  `ai_info/team/roster.md`).
- Drafts `changes[]` from the commit subjects in `<last-tag>..HEAD`, grouped by type
  (feat→feature, fix→bugfix, perf/refactor→enhancement, else other), each bullet pre-filled with its
  commit author(s) — resolved through the roster (GitHub handle → real name), plus any
  `Co-authored-by` trailers (bots filtered).

Then **hand-edit the drafted entry** in `data/changelog.json` using your Phase 1 diff understanding:
- Rewrite each bullet into plain, user-facing language (what changed and why it matters).
- Set a one-line `summary`.
- **Remove anything sensitive** — patient names/DOBs, patient↔drug links, SSNs, card/payment
  identifiers, secrets/keys/connection strings, and internal specifics that don't belong in a
  customer-safe log. Developer **names stay** (that's the point of the `authors` arrays — keep/merge
  them as you consolidate commits into features).

The entry is picked up by the normal Step 1 commit. (One-time history seed already done via
`node scripts/changelog.js backfill`; you don't re-run it.)

### Step 0.6 — Update the feature's shared plan record (if one exists)

If this release ships a feature tracked in [`ai_info/plans/`](../plans/README.md), set its
`ai_info/plans/<slug>.md` **status → `Completed in Production`**, add the release tag to `tags:`, append a
`Status & history` line, and update the index row (`plans/README.md`). Commit to `ai_info` `main`
(staging only those files). See [plan-tracking.md](plan-tracking.md). Skip if the release maps to no
tracked plan.

**This is ENFORCED, not optional.** The production deploy (`.github/workflows/deploy-azure.yml`) runs
`node scripts/check_changelog_entry.js <tag>` before it deploys and **hard-fails the deploy if
`data/changelog.json` has no entry for the version being released**. So a tag literally cannot reach
Azure without its Change Log entry — if you skip this step, the deploy for that tag fails and you must
add the entry, commit, and re-tag. Add the entry here (before the commit) and it ships cleanly.

### Standard: "push prod" (auto-increment patch)

1. Stage and commit uncommitted changes — **including the `data/changelog.json` entry from Step 0.5** — with a descriptive commit message informed by the Phase 1 investigation, not generic
2. Push to `main`
3. Increment the patch version of `git describe --tags --abbrev=0` (e.g., `1.0.3` → `1.0.4`)
4. Create an annotated tag with the new version (message summarizing release)
5. Push the tag to trigger CI/CD
6. **Auto-close resolved issues** (post-deploy bookkeeping, see Step 6 below)

### Explicit version: "push prod x.x.x"

Same flow but use the explicitly specified version (e.g., for a major / minor bump).

### Step 6 — Auto-close resolved in-app issues

After the tag is pushed (CI deploy is already underway and decoupled from this), scan the commits about to ship for `fixes emed-issue#N` markers and propagate the closure to both the SQL `emed_issue` table and the corresponding GitHub Issue.

```bash
cd ../emed_app   # adjust path; must run from emed_app/ to load .env
node scripts/close_resolved_issues.js <prev-tag>..HEAD
```

The script:
- Greps `git log <range>` for `(?:fixes|closes|resolves)\s+emed-issue#(\d+)` (case-insensitive)
- For each match: SQL `UPDATE emed_issue SET status='resolved', resolved_by_app_user=<committer>, resolved_at=NOW, resolution_commit_sha=<sha>` (skips rows already in a closed status — idempotent)
- If `github_issue_number` is populated and `GITHUB_TOKEN` is configured, posts a "resolved by commit X" comment on GitHub and closes the issue
- Prints a summary of what it did

This step is **non-fatal**. If the SQL update or GitHub close fails, the deploy is unaffected — surface the error so the user can re-run the script manually after fixing the issue.

For commits that resolve an issue without a `fixes` marker (or for non-code resolutions like `wontfix` / `duplicate`), use the `/resolve-issue` skill instead.

## Critical Rules

- **Tag format:** Always `x.x.x` — NO `v` prefix
  - `1.0.4` triggers the pipeline
  - `v1.0.4` does NOT trigger the pipeline (learned the hard way)
- **Annotated tags:** The tag message should briefly describe what's in the release
- **CI trigger:** GitHub Actions workflow (`.github/workflows/deploy-azure.yml`) triggers on tags matching `[0-9]+.[0-9]+.[0-9]+`
- **Never skip Phase 1** unless the user uses an emergency bypass phrase
- **Never `git push --force`** to main from this skill

## Example Commands

```bash
# Auto-increment patch (after Phase 1 passes and user confirms)
git add -A
git commit -m "feat(billing): add invoice PDF export"
git push origin main
git tag -a 1.0.4 -m "Add invoice PDF export"
git push origin 1.0.4

# Explicit version
git tag -a 2.0.0 -m "Major release: new billing system"
git push origin 2.0.0
```

## Applies To

- **emed_app** — primary project using this workflow
- Any future project with tag-based Azure deployment
