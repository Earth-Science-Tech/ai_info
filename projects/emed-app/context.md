# emed_app - Node.js Application Context

## Overview
- **Tech:** Node.js / Express / EJS / Azure SQL (mssql)
- **Entry point:** `app.js`
- **Repo:** https://github.com/Earth-Science-Tech/eMed
- **Branch:** `main` (default branch; `dev` is the integration branch for feature work)
- **Deploy:** Azure App Service via git tag CI/CD

## Server Architecture

### Modules (`server/*.js` — 12 files)
- `auth.js` — Authentication (session-based + magic link MFA)
- `sql.js` — Database connection pool and query helpers
- `permissions.js` — Role-based access control
- `users.js` — User management
- `emed.js` — Core business logic
- `liberty.js` — Liberty pharmacy integration
- `email.js` / `email_azure.js` — Email (Nodemailer + MS Graph)
- `pdf_html.js` — PDF generation (Puppeteer)
- `print_html.js` — Print formatting
- `misc.js` — Utilities
- `data_array.js` — Data transformation helpers

### Routes (`server/routes/*.js` — 6 files)
- `route_auth.js` — Login/logout/MFA
- `route_api.js` — General API
- `route_public.js` — Unauthenticated endpoints (ETL integration)
- `route_billing.js` — Billing/invoicing
- `route_moct.js` — Medical office operations
- `route_db.js` — Database browser (admin only)

### Views (`views/**/*.ejs` — 31 templates)
Organized by feature: `billing/`, `clinic/`, `admin/`, `partials/`

## Context Files (info.claude)

Claude auto-reads these when working in related areas:
- `./info.claude` — Main app (routes, views, auth, DB schema)
- `./sql/info.claude` — Auto-generated database schema (64 tables, 17 views, 18 procs)
- `./python/info.claude` — Remaining Python scripts (extract_schema, email_helper, claude_speech)
- `./python/email_helper/info.claude` — Outlook email sync tool
- `./python/claude_speech/info.claude` — Voice interface

## Python Scripts (remaining in emed_app)

ETL scripts moved to emed_etl. What remains:
- `python/extract_schema.py` — Generates `sql/info.claude`
- `python/email_helper/` — Outlook COM automation (7 scripts)
- `python/claude_speech/` — Voice-to-text interface (8 scripts)
