# eMed Deployment

## Production Deployment

**Platform:** Azure App Service
**URL:** emed.azurewebsites.net
**CI/CD:** GitHub Actions (`.github/workflows/deploy-azure.yml`)
**Trigger:** Git tag matching `[0-9]+.[0-9]+.[0-9]+` (NO `v` prefix)

## Quick Deploy ("push prod")

See `skills/push-prod.md` for the full workflow. Summary:
1. Commit changes
2. Push to `master`
3. Create tag (auto-increment patch or explicit version)
4. Push tag → triggers Azure deployment

## ETL Deployment

ETL scripts run on job servers (Windows Task Scheduler or Prefect):
- **Rx Compound Store server** — rxcs pharmacy data
- **Mister Meds server** — mmed pharmacy data
- **Meduvo server** — mdvo pharmacy data (pending provisioning)
- **Schedule:** Every 30 minutes

## Database Changes

Schema changes are deployed manually:
1. Create SQL scripts in emed_sql
2. Run scripts against Azure SQL using SSMS or Azure Data Studio
3. Include permission GRANTs for emed_app / emed_etl users
4. Run `extract_schema.py` to refresh documentation

## Rollback

- **App:** Redeploy a previous git tag
- **Database:** Schema changes should be additive; destructive changes need a migration plan
- **ETL:** Revert the Python script changes and redeploy to job servers
