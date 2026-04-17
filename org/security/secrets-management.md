# Secrets Management

## Where Secrets Live

| Context | Storage | Access |
|---------|---------|--------|
| Local development | `.env` files (gitignored) | Per developer |
| CI/CD pipelines | GitHub Secrets | Per repo, per environment |
| Production Azure | Azure App Service Configuration | Azure Portal |
| Shared team secrets | Encrypted zip + separate password channel | Manual distribution |

## GitHub Secrets

- Store CI/CD credentials in GitHub repo Settings > Secrets and variables > Actions
- Reference in workflows: `${{ secrets.SECRET_NAME }}`
- Never echo or log secret values in CI output

## Azure App Service

- Production environment variables are set in Azure Portal > App Service > Configuration
- These override `.env` values in production
- Connection strings have a separate section in Azure configuration

## Key Credentials to Track

| Credential | Used By | Storage |
|------------|---------|---------|
| Azure SQL DB credentials | emed_app, emed_etl | `.env`, Azure App Config, GitHub Secrets |
| WooCommerce API keys | emed_etl | `.env` |
| SSH/SFTP credentials (Cloudways) | emed_etl | `.env` |
| RingCentral API | emed_etl | Prefect Secret Blocks |
| ScriptSure API | emed_etl | `.env` |
| Session secret | emed_app | `.env`, Azure App Config |
| MS Graph API (email) | emed_app, emed_etl | `.env` |
