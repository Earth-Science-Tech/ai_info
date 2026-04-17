# Environment Variable Handling

## Rules

1. **Never commit `.env` files** — always in `.gitignore`
2. **Always maintain `.env.example`** — source of truth for what variables exist
3. **No secrets in code** — API keys, passwords, connection strings go in `.env` only

## .env.example Format

```env
# Azure SQL Server
DB_SERVER=your-server.database.windows.net
DB_NAME=your_database
DB_USER=
DB_PASSWORD=

# WordPress/WooCommerce API
WOO_URL=https://example.com
WOO_CONSUMER_KEY=
WOO_CONSUMER_SECRET=

# Application
PORT=3000
NODE_ENV=development
SESSION_SECRET=
```

## Distribution Protocol

1. `.env.example` documents all required variables (committed to git)
2. Real `.env` values: distribute as an encrypted zip file
3. Share the zip password through a separate channel (Signal, 1Password)
4. Never send the zip and the password together
5. CI/CD secrets go in GitHub Secrets

## Synchronization

The emed_app and emed_etl repos share database credentials. When updating `.env`:
- Update in both repos if the variable is shared (DB_SERVER, DB_USER, DB_PASSWORD, DB_NAME)
- Update `.env.example` in both repos to reflect any new variables
