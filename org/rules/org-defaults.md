# ETST Organization Defaults

These conventions apply to all Earth Science Tech projects unless a project explicitly documents exceptions.

## Naming Conventions

| Context | Convention | Examples |
|---------|-----------|----------|
| Backend files | snake_case | `audit_logger.js`, `email_azure.js` |
| Route files | `route_` prefix + domain | `route_billing.js`, `route_auth.js` |
| Frontend files | kebab-case | `create-task-modal.js`, `invoice-detail.ejs` |
| Script files | `<domain>_<action>` prefix | `peaks_etl_woo_orders.py` |
| Shared utilities | `shared_` prefix | `shared_db.py`, `shared_email.py` |
| SQL files | `<type>_` prefix | `table_*.sql`, `migration_*.sql`, `procedure_*.sql` |
| DB tables | `<domain>_` prefix | `moct_visit`, `woo_orders`, `rxcs_price_plan` |
| Directories | kebab-case or single word | `billing/`, `partials/` |
| Config files | `<name>_config.json` | `etl_config.json` |
| Repos | snake_case | `emed_app`, `emed_etl`, `ai_info` |

## Project Structure Principles

1. **Flat over nested** — prefer flat directories with prefix naming over deep nesting
2. **Prefix-based grouping** — group by prefix (`route_*`, `table_*`, `shared_*`) rather than subdirectories
3. **One entry point** — a single clear entry file at root (`app.js`, `main.py`)
4. **Soft deletes** — use `is_invalid` flag, never hard `DELETE` from the app layer
5. **No default permissions** — each new DB object gets explicit permission grants

## Commit Messages

Format: `type(scope): description`

Types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`

Examples: `feat(auth): add OAuth login`, `fix(api): handle empty response`

## Branch & PR Lifecycle

1. **One branch → one PR → merge → done.** A feature branch's life ends when its PR merges.
2. **Never push to a branch after its PR has merged.** New commits on a merged branch do NOT reach `main`/`dev` — they silently go missing. This has caused real production gaps (commits added post-merge had to be recovered by a follow-up PR). For any follow-up work, **cut a fresh branch from the latest base and open a new PR.**
3. **Recovering stranded commits:** if work was lost this way, `git cherry-pick` the orphaned commits onto a new branch and PR that — don't reopen/re-push the merged branch.
4. **Delete merged branches** (locally and on origin) once their PR merges, so they can't be accidentally reused.
5. **Branch every PR off the current base, never off another open PR's branch.** Stacking a second branch on top of an unmerged feature branch makes the second PR *contain the first PR's commits* — the reviewer then can't tell the two changes apart, both PRs show the same commit, and merging them is ambiguous and conflict-prone (which one first? does merging one empty the other?). Always `git switch <base> && git pull && git switch -c <new-branch>` before starting new work. (Real case: PR #106 was cut from PR #105's branch, so #106 carried #105's commit plus its own — the reviewer had to untangle which PR owned what before either could merge.)
6. **One logical change per PR.** Keep PRs focused — a single feature, fix, or refactor. Don't bundle an unrelated cleanup, a new feature, and an infra/engine swap into one PR; each makes the diff harder to review and raises the blast radius of a single merge. If a branch has grown to cover several unrelated things, split it into separate PRs off the base.
7. **If a PR genuinely depends on another, say so and sequence it.** When change B truly needs change A, don't stack the branches — note "Depends on #A" in B's description, merge A first, then rebase B onto the updated base and open it. Prefer combining into one PR only when the two are inseparable.

## Documentation Requirements

Every project must have:
1. **CLAUDE.md** — architecture, non-obvious patterns, gotchas (for AI)
2. **README.md** — setup instructions, dependencies, deployment (for humans)
3. **.env.example** — all required env vars with dummy values (no secrets)

## Code Style

| Language | Formatter | Linter | Indent |
|----------|-----------|--------|--------|
| JS/TS | Prettier | ESLint | 2 spaces |
| Python | Ruff | Ruff | 4 spaces |
| SQL | — | — | 4 spaces |
