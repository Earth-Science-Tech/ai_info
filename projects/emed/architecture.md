# eMed Platform Architecture

## Overview

eMed is an electronic medical records and telemedicine consultation management system for compounding pharmacies. It integrates patient visits, prescriptions, billing, and e-commerce order processing.

**Client:** Peaks Curative (peakscurative.com)
**Live URL:** emed.azurewebsites.net

## Three-Repository Architecture

```
emed_app (Node.js)          emed_etl (Python)           emed_sql (SQL + tooling)
├── Express server          ├── Peaks ETL               ├── prod/  (liberty_link_stage snapshots)
├── EJS views               ├── Liberty ETL             ├── dev/   (liberty_link_dev snapshots)
├── API endpoints           ├── SMS integration         ├── migrations/  (hand-written, dev → prod)
├── Auth/permissions        ├── Prefect orchestration   └── python/  (extract_sql_files.py, extract_schema.py)
└── PDF generation          ├── Warehouse clone flow
                            └── dbt project (etst_warehouse)
         │                          │                         │
         └──────────────────────────┼─────────────────────────┘
                                    │
            ┌───────────────────────┼────────────────────────────┐
            │                       │                            │
  liberty_link_stage         liberty_link_dev              etst_warehouse
  (operational, prod)        (operational, dev)            (analytics / reporting)
       │                        │                                ▲
       └── mirrored to ─────► emed_sql/prod/ + dev/               │ nightly clone + dbt
                                                                  │
                            All three on Azure SQL: liberty-link.database.windows.net
```

Engineers work on `liberty_link_dev`, write a hand-rolled migration in `emed_sql/migrations/`, and the `push prod` skill applies it to `liberty_link_stage` and refreshes the `prod/` snapshot.

The warehouse (`etst_warehouse`) is owned by emed_etl: the nightly stage→warehouse clone loads `stg.*` raw tables, and the dbt project then builds `core.dim_*`/`fct_*` and `mart.*` on top. See [emed-etl/warehouse.md](../emed-etl/warehouse.md).

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
  ├── mmed_* tables (Mister Meds)
  └── mdvo_* tables (Meduvo)
         │
  Transfer to Azure SQL ──→ Stored procedures merge data
```

### Warehouse (nightly)
```
liberty_link_stage ──► etst_warehouse.stg.*         (Clone-Prod-to-Warehouse-Stage, 01:00 ET)
                              │
                              └──► stg.stg_*, core.dim_*, core.fct_*, mart.*
                                    via `dbt build`  (Warehouse-DBT-Build, 02:00 ET)
```

## Key Integration Points

1. **eMed API:** `POST /api/public/moct-visit` — creates medical visits from ETL data
2. **Operational Databases:** Azure SQL — `liberty_link_stage` (prod) and `liberty_link_dev` (dev), used by both app and ETL
3. **Warehouse Database:** Azure SQL `etst_warehouse` — analytics/reporting, loaded nightly by emed_etl, modeled with dbt
4. **SQL Schemas:** emed_sql repo — single source of truth for prod and dev, with auto-generated `.sql` snapshots and hand-written migrations

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
| Warehouse | Azure SQL (etst_warehouse) + dbt-sqlserver |
| Email | Nodemailer + MS Graph API |
| PDF | Puppeteer |
| Deployment | Azure App Service (tag-based CI/CD) |
| Auth | Session-based with magic link MFA |
