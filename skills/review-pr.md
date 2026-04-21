# Skill: Review PR

## Trigger

When the user says **"review pr"**, **"review pull requests"**, **"check open PRs"**, or similar.

## What to Do

### Step 1: Discover all open PRs

Fetch open PRs from all three repositories in parallel:

```bash
gh pr list --repo Earth-Science-Tech/eMed --state open --json number,title,author,headRefName,baseRefName,createdAt,url,additions,deletions,changedFiles
gh pr list --repo Earth-Science-Tech/emed_etl --state open --json number,title,author,headRefName,baseRefName,createdAt,url,additions,deletions,changedFiles
gh pr list --repo Earth-Science-Tech/emed_sql --state open --json number,title,author,headRefName,baseRefName,createdAt,url,additions,deletions,changedFiles
```

If no PRs found across all repos, report "No open Pull Requests" and stop.

### Step 2: Deep-dive each PR

For each PR, fetch:
1. **Full diff:** `gh pr diff <number> --repo Earth-Science-Tech/<repo>`
2. **PR metadata:** `gh pr view <number> --repo Earth-Science-Tech/<repo> --json body,commits,reviews,comments,labels,files`
3. **CI status:** `gh pr checks <number> --repo Earth-Science-Tech/<repo>`

### Step 3: Review against ETST checklist

#### Security
- No hardcoded secrets, API keys, passwords, or connection strings in the diff
- No .env files committed
- Auth middleware on new routes (all non-public routes need authentication)
- CSRF protection on state-changing endpoints (POST/PUT/DELETE)
- Input validation on user-supplied data
- No SQL injection vectors (parameterized queries required)
- No exposed stack traces or verbose error messages to clients

#### SQL Safety (PRs touching .sql files or database code)
- New tables include all 5 mandatory fields (id, sql_user, date_created, date_modified, is_invalid)
- Permission grant migration scripts exist for new tables/views/procedures
- No DELETE granted to emed_app (soft delete only via is_invalid)
- No DDL granted to application users
- Domain prefix naming (moct_*, emed_*, rxcs_*, etc.)
- Stored procedures use usp_ prefix, views use view_ prefix

#### Naming Conventions
- Backend files: snake_case (e.g., audit_logger.js)
- Route files: route_ prefix (e.g., route_billing.js)
- Frontend files: kebab-case (e.g., create-task-modal.js)
- Python scripts: domain_action prefix (e.g., peaks_etl_woo_orders.py)
- SQL files: type_ prefix (table_*, migration_*, procedure_*)

#### Commit & Branch Hygiene
- Commits follow type(scope): description format
- Branch name is descriptive
- PR description explains the "why"

#### Code Quality (emed_app — Node.js)
- Error handling present (try/catch, error middleware)
- Database queries use parameterized inputs via mssql
- New routes in route_*.js files (not inline in app.js)
- Middleware chain correct (auth before route logic)

#### Code Quality (emed_etl — Python)
- Uses emed_etl database user, not admin
- Batch processing with executemany() for bulk inserts
- Errors logged to etl_metadata table

#### Code Quality (emed_sql — SQL)
- Migrations are additive (no destructive schema changes without plan)
- Grant scripts created for every new object
- Trigger scripts update date_modified correctly

#### Documentation
- CLAUDE.md updated if architecture changed
- info.claude updated if routes/endpoints/schema changed
- .env.example updated if new env vars added

### Step 4: Generate per-PR report

For each PR, output:

```
## [repo] PR #N: <title>
**Author:** <author> | **Branch:** <head> -> <base> | **Age:** <days> days
**Changes:** +<additions> -<deletions> across <files> files

### Findings

#### [PASS/WARN/FAIL] Security
- <findings or "No issues found">

#### [PASS/WARN/FAIL] SQL Safety
- <findings or "N/A - no SQL changes">

#### [PASS/WARN/FAIL] Naming Conventions
- <findings or "All conventions followed">

#### [PASS/WARN/FAIL] Code Quality
- <findings>

#### [PASS/WARN/FAIL] Documentation
- <findings>

### Recommendation: [MERGE / REQUEST CHANGES / REJECT]
<reasoning - 1-3 sentences>
```

### Step 5: Summary table

After all individual reviews:

```
| Repo | PR | Title | Verdict | Key Issues |
|------|----|-------|---------|------------|
| ... | ... | ... | ... | ... |
```

## Critical Rules

- **Cross-repo:** Always check ALL three repos, not just the current project
- **gh CLI:** Use `--repo Earth-Science-Tech/<repo>` so this works from any directory
- **Read-only:** Only READ — never approve, merge, or comment on PRs automatically
- **Report only:** Present findings for the user to decide
- **Large diffs:** If a diff is too large, summarize by file and focus on highest-risk changes

## Applies To

- **emed_app** — Node.js application PRs
- **emed_etl** — Python ETL PRs
- **emed_sql** — SQL schema PRs
- Works from ANY project directory
