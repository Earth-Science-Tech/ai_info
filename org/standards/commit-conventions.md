# Commit Conventions

## Commit Message Format

```
type(scope): description
```

### Types

| Type | When to use |
|------|------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `chore` | Maintenance, deps, config |
| `docs` | Documentation only |
| `refactor` | Code restructuring (no behavior change) |
| `test` | Adding or updating tests |

### Examples

```
feat(auth): add OAuth login flow
fix(api): handle empty response from WooCommerce
chore(deps): update eslint to v9
docs(readme): add deployment instructions
refactor(etl): simplify peaks order matching logic
test(billing): add invoice generation tests
```

### Scope

The scope is optional but recommended. Use the module or feature area:
- `auth`, `api`, `billing`, `etl`, `sms`, `sql`, `ui`, `deps`

## Branch Strategy

Trunk-based development:
- Short-lived feature branches off `main`
- Pull request with 1 approval from an `admin` member
- Merge and deploy
- No long-lived develop/release branches unless specifically needed

## ai_info Commit Prefixes

For commits to the ai_info knowledge repo, use these prefixes instead:
- `knowledge:` — New facts, architecture, patterns
- `skill:` — New or updated skill instructions
- `update:` — Edits to existing content
- `fix:` — Corrections to inaccurate information
