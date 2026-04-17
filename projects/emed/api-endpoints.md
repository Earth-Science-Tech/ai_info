# eMed API Endpoints

## Public API (no auth required)

### POST /api/public/moct-visit
Creates a medical visit from external data (called by Peaks ETL).

**Used by:** emed_etl (peaks_update_moct.py)

## Authenticated API Routes

### Auth Routes (/api/auth/)
- Login, logout, session management
- Magic link MFA authentication

### MOCT Routes (/api/moct/)
- Visit CRUD operations
- Patient management
- Prescription management
- Questionnaire handling
- Order tracking

### Billing Routes (/api/billing/)
- Invoice management
- Payment tracking
- Pricing tiers

### Database Routes (/api/db/)
- Admin-only database browser
- Direct table queries (admin tool)

## Route Files

Located in `emed_app/server/routes/`:
- `route_auth.js` — Authentication
- `route_api.js` — General API
- `route_public.js` — Public (unauthenticated) endpoints
- `route_billing.js` — Billing operations
- `route_moct.js` — Medical office operations
- `route_db.js` — Database browser (admin)

## Server Modules

Located in `emed_app/server/`:
- `auth.js` — Authentication logic
- `sql.js` — Database connection/queries
- `permissions.js` — RBAC permission checks
- `users.js` — User management
- `emed.js` — Core eMed business logic
- `liberty.js` — Liberty pharmacy integration
- `email.js` / `email_azure.js` — Email sending
- `pdf_html.js` — PDF generation (Puppeteer)
- `print_html.js` — Print formatting
- `misc.js` — Utility functions
- `data_array.js` — Data transformation helpers
