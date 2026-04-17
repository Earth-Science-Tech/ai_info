# eMed Platform Architecture

## Overview

eMed is an electronic medical records and telemedicine consultation management system for compounding pharmacies. It integrates patient visits, prescriptions, billing, and e-commerce order processing.

**Client:** Peaks Curative (peakscurative.com)
**Live URL:** emed.azurewebsites.net

## Three-Repository Architecture

```
emed_app (Node.js)          emed_etl (Python)           emed_sql (SQL)
├── Express server          ├── Peaks ETL               ├── Table schemas
├── EJS views               ├── Liberty ETL             ├── Stored procedures
├── API endpoints           ├── SMS integration         ├── Migrations
├── Auth/permissions        ├── Prefect orchestration   └── Permission grants
└── PDF generation          └── Shared utilities
         │                          │                         │
         └──────────────────────────┴─────────────────────────┘
                                    │
                          Azure SQL Server
                        (liberty_link_stage)
```

## Data Flow

### Peaks Curative ETL (every 30 min)
```
WordPress (peakscurative.com)
  ├── WooCommerce orders ──→ woo_orders table
  └── WPForms questionnaires ──→ wpforms_entries table
                                        │
                              Match orders ↔ forms
                                        │
                              POST /api/public/moct-visit
                                        │
                              moct_visit + moct_person created
                                        │
                              Prescriber reviews in eMed UI
```

### Liberty Pharmacy ETL (every 30 min)
```
Liberty RX Database
  ├── rxcs_* tables (Rx Compound Store)
  └── mmed_* tables (Mister Meds)
         │
  Transfer to Azure SQL ──→ Stored procedures merge data
```

## Key Integration Points

1. **eMed API:** `POST /api/public/moct-visit` — creates medical visits from ETL data
2. **Shared Database:** Azure SQL (liberty_link_stage) — used by both app and ETL
3. **SQL Schemas:** emed_sql repo — submodule in emed_etl, docs copied to emed_app

## User Roles

| Role | Access |
|------|--------|
| Admin | Full access, user management, database browser |
| Pharmacist | Visit management, prescriptions, order tracking |
| Doctor/Prescriber | Visit approval, prescription writing |
| Biller | Billing, invoicing, payment tracking |

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Backend | Node.js / Express |
| Views | EJS templates |
| Database | Azure SQL Server (mssql package) |
| ETL | Python / Prefect |
| Email | Nodemailer + MS Graph API |
| PDF | Puppeteer |
| Deployment | Azure App Service (tag-based CI/CD) |
| Auth | Session-based with magic link MFA |
