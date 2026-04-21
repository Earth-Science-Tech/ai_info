Review all open Pull Requests across ETST repositories and provide merge recommendations.

Instructions:
1. Fetch all open PRs across the three repos using gh CLI (run in parallel):
   - `gh pr list --repo Earth-Science-Tech/eMed --state open --json number,title,author,headRefName,baseRefName,createdAt,url,additions,deletions,changedFiles`
   - `gh pr list --repo Earth-Science-Tech/emed_etl --state open --json number,title,author,headRefName,baseRefName,createdAt,url,additions,deletions,changedFiles`
   - `gh pr list --repo Earth-Science-Tech/emed_sql --state open --json number,title,author,headRefName,baseRefName,createdAt,url,additions,deletions,changedFiles`

2. If no open PRs found across all repos, report "No open PRs" and stop.

3. For each open PR, perform a thorough review:
   a. Fetch the diff: `gh pr diff <number> --repo Earth-Science-Tech/<repo>`
   b. Fetch PR details: `gh pr view <number> --repo Earth-Science-Tech/<repo> --json body,commits,reviews,comments,labels,files`
   c. Fetch CI status: `gh pr checks <number> --repo Earth-Science-Tech/<repo>`

4. Review each PR against the ETST checklist (see skills/review-pr.md for full details):
   - Security: No secrets/credentials, auth checks, CSRF, parameterized SQL
   - SQL safety: Mandatory fields, permission grants, soft deletes, no DDL
   - Naming conventions: snake_case backends, kebab-case frontends, correct prefixes
   - Commit format: type(scope): description
   - Code quality: Error handling, proper patterns for the repo's language
   - Documentation: CLAUDE.md, info.claude updated if needed

5. Output a structured report for each PR with:
   - PR summary (repo, number, title, author, branch, age)
   - Changes overview (files changed, additions, deletions)
   - Review findings organized by category (PASS/WARN/FAIL)
   - Recommendation: MERGE / REQUEST CHANGES / REJECT with reasoning

6. After all individual reviews, provide a summary table.

Note: This command works from ANY project directory. It is read-only — never approve, merge, or comment on PRs automatically.
