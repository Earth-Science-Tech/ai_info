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

eMed uses a **feature-promotion model with an open preview branch** (canonical definition + gates in
[branch-and-database-gates.md](../rules/branch-and-database-gates.md)):
- A long-lived **open `dev`** integration/preview branch is intentional — all devs push to it freely
  (no PR) and it auto-deploys to the Azure dev slot.
- **Shippable feature branches are cut from `main`** (not `dev`), and also merged into `dev` for combined
  preview while open.
- **`main` (production) is identity-gated**, not PR-approval-gated: only the three gatekeepers can
  merge/push it. A regular dev's `feat/* → main` PR is merged by a gatekeeper, who then cuts the `x.x.x`
  deploy tag.
- **Subset a release by promoting a feature branch**, never by branch surgery on `dev`; a gatekeeper may
  batch several ready feature PRs into one tag. (emed_etl `main` uses PR + 1 approval; ai_info commits
  straight to `main`.)

## ai_info Commit Prefixes

For commits to the ai_info knowledge repo, use these prefixes instead:
- `knowledge:` — New facts, architecture, patterns
- `skill:` — New or updated skill instructions
- `update:` — Edits to existing content
- `fix:` — Corrections to inaccurate information
