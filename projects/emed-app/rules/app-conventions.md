# emed_app Conventions

## Auto-Update Protocol

When making significant changes to emed_app, automatically update the relevant documentation:

| Change | Update |
|--------|--------|
| New route or API endpoint | `./info.claude` |
| Database table change | `./info.claude` + run `extract_schema.py` |
| ETL script change | `./python/info.claude` |
| Architectural change | `CLAUDE.md` |
| Environment variable added | Relevant `info.claude` + `.env.example` |

## Database Connection

Uses `server/sql.js` — mssql package with connection pooling. User: `emed_app` (least-privilege).

## Authentication

Session-based with magic link MFA. All roles require MFA. See `server/auth.js`.

## Deployment

Tag-based: push a numeric tag (e.g., `1.0.4`) to trigger Azure deployment. See `skills/push-prod.md`.
