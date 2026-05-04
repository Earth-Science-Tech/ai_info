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

### Step 1.5 — SQL drift check (only when shipping schema changes)

Run only if the user mentioned schema, or there are unapplied scripts in `emed_sql/migrations/`, or the change touches `.sql` files. Skip entirely for routing/UI-only deploys.

```bash
cd ../emed_sql                                          # adjust path as needed
python python/extract_sql_files.py --db dev             # refresh dev/ snapshot first
diff -rq prod/ dev/                                     # show schema drift
ls migrations/                                          # list pending migration scripts
```

What to look for:
- **Files only in `dev/`** → new objects on dev that need migrating to prod
- **Differing files** → objects whose definition changed in dev (new column, view rewrite)
- **`migrations/` files not yet applied to prod** → cross-check each script against the dev/prod diff to verify it captures the full change

Reject the push if:
- Any dev/prod drift is **not** covered by a corresponding migration script
- Any migration script is non-idempotent (no `IF NOT EXISTS` / `IF OBJECT_ID IS NULL`)
- A new table/view/procedure exists in dev without a `migration_grant_permissions_*.sql` covering it

In Phase 2, the SQL changes must be applied to prod (`liberty_link_stage`) **before** the Node.js tag goes out. Spell out the exact run order in your Phase 1 report.

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

### Step 0 — Apply pending SQL migrations (only if Phase 1 found drift)

If Phase 1 identified pending `migrations/<...>.sql` scripts:

1. **Apply each script to BOTH databases** with one command per script:
   ```bash
   cd ../emed_sql
   python python/apply_migration.py migrations/<file>.sql --db both --confirm
   ```
   The `--db both` mode applies dev FIRST (so a buggy migration fails on dev, not prod), then prod. Migrations are idempotent so this is safe even when dev already has the change. Both `prod/` and `dev/` snapshot folders are regenerated automatically.
2. **Re-diff `prod/` vs `dev/`** — should now show only unrelated in-flight dev work, not the migration we just applied.
3. **Commit `emed_sql`** (separate commit from the Node.js code):
   ```
   git add migrations/ prod/ dev/
   git commit -m "chore(sql): apply <migration name> to prod and dev"
   git push origin main
   ```

Only proceed to Step 1 after the SQL changes are live and committed.

### Standard: "push prod" (auto-increment patch)

1. Stage and commit uncommitted changes with a descriptive commit message — informed by the Phase 1 investigation, not generic
2. Push to `main`
3. Increment the patch version of `git describe --tags --abbrev=0` (e.g., `1.0.3` → `1.0.4`)
4. Create an annotated tag with the new version (message summarizing release)
5. Push the tag to trigger CI/CD

### Explicit version: "push prod x.x.x"

Same flow but use the explicitly specified version (e.g., for a major / minor bump).

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
