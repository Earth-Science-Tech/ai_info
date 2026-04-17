# Azure App Service Deployment

## eMed App Service

- **Name:** eMed
- **URL:** emed.azurewebsites.net
- **Runtime:** Node.js 22.x
- **Source:** emed_app repository

## CI/CD Pipeline

- **Workflow:** `.github/workflows/deploy-azure.yml`
- **Trigger:** Push a git tag matching `[0-9]+.[0-9]+.[0-9]+`
- **IMPORTANT:** Tags must NOT have a `v` prefix. `v1.0.3` will NOT trigger the pipeline. Use `1.0.3`.

### What the pipeline does:
1. Checks out code at the tagged commit
2. Sets up Node.js 22.x
3. Updates package.json version to match the tag
4. Installs dependencies (`npm install`)
5. Deploys to Azure Web App "eMed"

## Release Strategy

- Code merges to `main`/`master` — CI runs lint/test/build
- Ready to release → push a semver tag (`1.2.0`)
- Tag triggers deploy workflow → deploys to production
- Rollback = redeploy a previous tag

## Versioning

- `MAJOR` — breaking changes
- `MINOR` — new features, backwards compatible
- `PATCH` — bug fixes

## "push prod" Shortcut

See `skills/push-prod.md` for the automated deployment skill that handles committing, tagging, and pushing in one step.
