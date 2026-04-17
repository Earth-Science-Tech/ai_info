# GitHub Actions CI/CD

## Standard CI Checks

| Check | Tool | Blocks Merge |
|-------|------|-------------|
| Lint | ESLint (JS) / Ruff (Python) | Yes |
| Tests | Vitest or Jest | Yes |
| Build | `npm run build` | Yes |
| Format | Prettier (JS) / Ruff (Python) | Auto-fixes |

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

Standard code repos (emed_app, emed_etl) use:
- Required PR reviews (1 approval from admin)
- Required status checks (lint, test, build)

**Exception:** The `ai_info` repo has NO branch protection — direct push to `main` for all team members.
