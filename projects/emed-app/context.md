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

## Authentication & Roles

**MFA:** Required for every role except those in `MFA_EXEMPT_ROLES` in `server/mfa.js` (currently only `API`). Lockout after 5 failed attempts for 15 minutes; window auto-clears on next attempt past expiry. Disabled on localhost.

**Roles** (`server/permissions.js`): `Admin`, `SuperUser`, `MOCT`, `Peaks`, `Prescriber`, `Clarifications`, `ExternalRep`, `Billing`, `BillingPeaks`, `API`, `ClinicUser`, `Shipping`, `API_POP`, `ITSupport`.

**ITSupport / Helpdesk role** — narrow recovery-only role for non-Admin support staff:
- Single permission: `Manage_User_Auth` (no business-data access)
- Endpoints under `/api/it-support/*` — `reset-password`, `reset-mfa`, `unlock`, `users`
- `reset-password` supports two modes: `send_email=true` (server generates 16-char temp password and emails it via `email_azure`) or `new_password=<str>` (manual). Both modes set `password_change_required=1`.
- **Privilege-escalation guard** in `route_api.js → load_helpdesk_target`: ITSupport actors blocked from operating on Admin/SuperUser/ITSupport targets, AND the attempt is audit-logged as `HELPDESK_PRIVILEGE_ESCALATION_BLOCKED`. Privileged users are also filtered from the list endpoint so they're invisible to ITSupport.
- UI at `/it-support` (sidebar gated on `View_Menu_IT_Support`)

**MFA phone number capture (`emed_user.mfa_phone`):**
- SECURITY-CRITICAL: phone numbers can ONLY be written in trusted contexts. An earlier bug let `/api/auth/mfa/magic-link/send` save a phone from the request body during the pending-MFA window, which let an attacker with a stolen password supply their own phone and bypass MFA. Closed 2026-05-01.
- Trusted-write contexts:
  1. `POST /api/auth/mfa/setup/verify` — during initial TOTP enrollment (user has proved possession of authenticator app)
  2. `POST /api/auth/change-password` — after current-password verification
- `/api/auth/mfa/magic-link/send` rejects SMS delivery with 400 if no `mfa_phone` is on file (audit logged as `MFA_SMS_UNAVAILABLE`). The login page's "no phone" screen is info-only — no input.
- UI: phone field shown on MFA-setup screen (`login.ejs`) and on `views/auth/change-password.ejs` when the user has no phone on file.

**Forced password change** (column `emed_user.password_change_required` BIT NOT NULL DEFAULT 0):
- Set to `1` by any helpdesk reset (manual or email)
- `auth.login` middleware redirects authenticated requests to `/change-password` while flag is set; exempt paths: `/change-password`, `/api/auth/change-password`, `/logout`, `/api/auth/logout`
- `POST /api/auth/change-password` verifies current password → updates hash → clears flag → updates session
- View: `views/auth/change-password.ejs` (auth-style page outside the main layout)
- Migration: `emed_sql/migration_add_password_change_required.sql`
