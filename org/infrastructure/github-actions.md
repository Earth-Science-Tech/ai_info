# GitHub Actions CI/CD

## Standard CI Checks

| Check | Tool | Blocks Merge |
|-------|------|-------------|
| Lint | ESLint (JS) / Ruff (Python) | Yes |
| Tests | Vitest or Jest | Yes |
| Build | `npm run build` | Yes |
| Format | Prettier (JS) / Ruff (Python) | Auto-fixes |

> Per-repo reality overrides this generic table. In **emed_app**, `ci.yml` runs lint + unit tests and
> ships **advisory** (not a required status check) — see "Branch Protection" below.

## Deployment Workflow

Tag-based deployment to Azure App Service:

```yaml
on:
  push:
    tags:
      - '[0-9]+.[0-9]+.[0-9]+'  # No 'v' prefix!
```

## Format Auto-Fix

The formatter runs on PRs and amends the dev's last commit automatically — no extra "format code" commits needed.

## GitHub Secrets Required

Each repo that deploys needs these secrets configured:
- `AZURE_WEBAPP_PUBLISH_PROFILE` — Azure deployment credentials
- Any API keys referenced in the workflow

## Branch Protection (for code repos)

Real configuration (canonical: [../rules/branch-and-database-gates.md](../rules/branch-and-database-gates.md)):

- **emed_app `main` (production):** push **restricted to the 3 gatekeepers** (identity gate) — **no**
  "require a pull request" toggle, so gatekeepers keep direct-push for `push prod` / hotfixes / the batch
  fast-forward while regular devs must open a `feat/* → main` PR a gatekeeper merges. Force-push + deletion
  blocked. A **tag ruleset** restricts `x.x.x` tags to admin+maintain roles + org owners (the real deploy
  gate).
- **emed_app `dev`:** open — all devs push directly, no PR, no required checks (deletion blocked).
- **emed_etl `main`:** PR + 1 approval (Nicholas & Carlos may push directly).
- **ai_info `main`:** no protection — direct push to `main` for all team members.

CI checks (`ci`, `migration-check`, `base-freshness`) ship **advisory** by default; make one required by
adding it as a required status check in the `main` branch protection / ruleset — with the gatekeepers as a
bypass actor so a flaky red never blocks a hotfix. `base-freshness` is deterministic (a git-ancestry check)
and is the safest to make blocking first.

## Workflows (emed_app)

| Workflow | Trigger | What it does |
|----------|---------|--------------|
| `deploy-azure.yml` | push tag `x.x.x` | Deploy to Azure **prod** (App Service "eMed") |
| `deploy-azure-dev.yml` | push to `dev` | Deploy to the Azure **dev slot** |
| `ci.yml` | PR + push to `main`/`dev` | Lint + unit tests (advisory) |
| `migration-check.yml` | PR | Fail unless the PR declares "no schema change" or links a real `emed_sql/migrations/pending/*.sql` (advisory) |
| `base-freshness.yml` | PR → `main` | Fail a feature branch accidentally cut off `dev` instead of `main` |
| `sync-main-to-dev.yml` | push to `main` | Back-merge `main → dev` after any push that didn't come from a `dev → main` merge (keeps the preview current) |

Secrets used by these: `AZURE_WEBAPP_PUBLISH_PROFILE` / `AZURE_WEBAPP_PUBLISH_PROFILE_DEV`, `SYNC_PAT`
(hands-off `dev` back-merge), `EMED_SQL_READ_PAT` (cross-repo migration existence check).
