# Skill: Open PR

## Trigger

When the user says **"open a PR"**, **"make a PR"**, **"create a pull request"**, **"PR this branch"**, **"open pull request"**, or similar phrasings about turning a pushed branch into a GitHub Pull Request.

## Why This Exists

Some Claude sessions have been observed to draft a PR title + body, then stop without actually running `gh pr create`. The user then thinks a PR exists when only the source branch is on origin. This skill exists to **enforce that the actual `gh pr create` command runs** and the PR URL is reported back.

A symptom of the failure mode: user says "I made a PR" → reviewer can't find it → investigation reveals the branch was pushed but no PR was opened.

## What to Do

### 1. Verify the branch is ready

```bash
git status -sb                            # confirm clean / what's uncommitted
git rev-parse --abbrev-ref HEAD            # current branch
git log -1 --oneline                       # latest commit
git ls-remote origin <current-branch>      # is the branch pushed to origin?
```

If the branch is not yet on origin, push it first:

```bash
git push -u origin <current-branch>
```

If there are uncommitted changes the user wants in the PR, commit them first (per the org commit-message convention: `type(scope): description`).

### 2. Pick the base branch

Default base by repo:

| Repo | Default base | When to override |
|------|--------------|------------------|
| `emed_app` | `dev` | Hotfix going straight to `main` |
| `emed_sql` | `main` | (no integration branch in this repo) |
| `emed_etl` | `main` | (no integration branch in this repo) |
| `ai_info` | `main` | always — knowledge updates commit directly to main, no PR |

If the user named a base explicitly ("PR this against main"), honor it.

### 3. Draft title and body

Read the commits the PR will contain:

```bash
git log <base>..HEAD --oneline
git diff <base>..HEAD --stat
```

**Title:** one line, follow `type(scope): description` (e.g. `feat(crm): bulk delete leads`). If the branch has a single commit, the commit subject usually works as the title.

**Body:** explain the WHY, not just the WHAT. Sections to include:

```markdown
## Summary
<1–3 bullet points of what changed and why>

## Dependencies & risk
<schema/prod prerequisites, behavioral changes, known limitations — or "none">

## Test plan
- [ ] <how a reviewer would verify this works>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

#### Mandatory disclosures (the reviewer/deployer cannot see these from the diff)

A correct, complete diff is not enough — the body must call out anything that affects how the PR is reviewed or deployed. **Omitting these has repeatedly caused near-misses where a code PR would have broken production on deploy.** Before you run `gh pr create`, walk this checklist and put anything that applies in a **Dependencies & risk** section:

1. **Schema / prod prerequisites — the #1 miss.** If the code reads or writes any table/column/view/proc that a migration introduces, say so explicitly: name the `emed_sql/migrations/...` file, link its emed_sql PR/commit, and state **where it's been applied** (dev only? dev + prod?). The migration must be in prod **before or with** the code merge — code that queries a table prod doesn't have yet throws at runtime. (See `org/rules/sql-safety.md` → "Cross-repo: code PRs that depend on a migration".) Never create the table by hand on dev without committing the migration — there'll be nothing to promote to prod.
2. **Behavioral changes the title doesn't imply.** If the PR is titled like a UI tweak but also changes routing/charging/permission logic, name that change. A reviewer who trusts the title will skim right past it. (Real case: a PR titled "add a summary table" also rewrote prescription-routing cleanup logic — invisible from the title.)
3. **Known limitations / security gaps / unverified paths.** Anything `UNVERIFIED end-to-end`, sandbox-only, missing a bound (e.g. an uncapped loop over public input), or a deliberately-deferred hardening step. Flagging it lets the deployer gate appropriately instead of discovering it live.
4. **New env vars / config** the deploy target needs (and whether prod already has them).

Rule of thumb: if shipping this PR safely requires someone to *do or know something that isn't in the diff*, it goes in the body. "Trust me, it's applied to dev" with no link is not a disclosure — give the file path and the apply-state so it's a 10-second verify, not an archaeology dig.

### 4. Run gh pr create — actually run it, don't just draft

This is the load-bearing step. Use a HEREDOC for the body so newlines are preserved:

```bash
gh pr create \
  --base <base-branch> \
  --head <current-branch> \
  --title "<title>" \
  --body "$(cat <<'EOF'
## Summary
- <bullet>
- <bullet>

## Test plan
- [ ] <step>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

The command prints the PR URL on success (e.g. `https://github.com/Earth-Science-Tech/eMed/pull/61`). Capture and report this URL — it's the proof that the PR exists.

### 5. Verify the PR exists

Always confirm with a fresh query, not trust-the-output:

```bash
gh pr view <number> --json number,title,state,url --jq '"#\(.number) \(.state) — \(.title)\n\(.url)"'
```

If this returns the PR, you're done. If it returns "no pull requests found", something went wrong — investigate before reporting success.

### 6. Report back to the user

Report exactly:
- The PR number and URL (e.g. `Opened PR #61 — https://github.com/.../pull/61`)
- Base → head branches
- Whether it's ready to merge (CI status, merge state) or needs review

## Critical Rules

- **MUST run `gh pr create`.** Drafting a title + body and stopping is the failure mode this skill exists to prevent. If you find yourself ending a response with "Here's the PR description I'd write..." — keep going and actually run the command.
- **MUST verify with `gh pr view` after** so the success message is grounded in reality, not in command output that could have failed silently.
- **NEVER push --force to the source branch** during PR creation. If the branch has unrelated commits that shouldn't ship, rebase or cherry-pick onto a fresh branch first, then PR that.
- **If `gh pr create` errors with "no commits between base and head"**, the branch is at the same commit as base — there's nothing to PR. Tell the user.
- **If `gh pr create` errors with "a pull request already exists"**, capture the existing PR URL from the error and report that — don't try to make a second one.
- **CSRF / branch protection bypass is NOT needed at PR creation time** — bypasses come into play at merge. Creating a PR works regardless of branch protection rules on the base.
- **NEVER keep pushing to a branch after its PR has merged.** Once a PR merges, that branch is done — any further commits pushed to it will NOT reach `main`/`dev` and will silently go missing. This has bitten the team more than once (commits added to `feat/crm-followup-order-tooltip` after PR #80 merged were lost until recovered by a separate PR). For follow-up work, **start a fresh branch off the latest base** and open a new PR. If you discover commits stranded on an already-merged branch, cherry-pick them onto a new branch and PR that. See "Branch & PR Lifecycle" in `org/rules/org-defaults.md`.

## Example

User: "open a PR for these changes"

Claude:
```bash
# 1. Verify branch state
git status -sb
# ## feat/crm-bulk-delete...origin/feat/crm-bulk-delete

# 2. Confirm pushed
git ls-remote origin feat/crm-bulk-delete
# 0a1b2c3... refs/heads/feat/crm-bulk-delete

# 3. Pick base (emed_app default = dev)
# 4. Draft and run
gh pr create \
  --base dev \
  --head feat/crm-bulk-delete \
  --title "feat(crm): bulk delete leads + case-insensitive CSV import" \
  --body "$(cat <<'EOF'
## Summary
- New POST /api/crm/bulk-delete (Write_CRM perm) with cascade soft-delete
  to child contacts and notes
- "Delete Leads" entry in the Bulk Update dropdown, double-confirm above 10
- CSV import column-mapping is now case-insensitive

## Test plan
- [ ] Bulk-select 3 leads in /crm/leads, choose Delete Leads, confirm — leads
      disappear from list, child rows soft-deleted
- [ ] Try to delete 15 leads — second confirmation should appear
- [ ] Upload a CSV with mixed-case headers — rows import correctly

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
# https://github.com/Earth-Science-Tech/eMed/pull/61

# 5. Verify
gh pr view 61 --json number,title,state,url \
  --jq '"#\(.number) \(.state) — \(.title)\n\(.url)"'
# #61 OPEN — feat(crm): bulk delete leads + case-insensitive CSV import
# https://github.com/Earth-Science-Tech/eMed/pull/61
```

Then report: "Opened PR #61 against dev — https://github.com/Earth-Science-Tech/eMed/pull/61"

## Applies To

- All eMed repos (`emed_app`, `emed_sql`, `emed_etl`)
- Any branch with at least one commit ahead of its intended base
