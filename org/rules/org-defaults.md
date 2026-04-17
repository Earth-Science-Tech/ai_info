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
