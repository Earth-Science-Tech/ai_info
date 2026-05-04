# emed_etl - Python ETL Context

## Overview
- **Tech:** Python / Prefect / pyodbc / Azure SQL
- **Repo:** https://github.com/Earth-Science-Tech/emed_etl
- **Branch:** `main`
- **Schema:** lives in sibling `../emed_sql/` repo (no longer a submodule as of 2026-05-04)

## Schema Changes

ETL code lives here, but any **database schema change** (new table, new column, new grant) goes through `emed_sql` via the dev-first workflow. See `ai_info/skills/create-table.md`. Don't put `.sql` files in this repo.

## Directory Structure

```
emed_etl/
├── etl/
│   ├── peaks/          # Peaks Curative ETL (WooCommerce + WPForms → eMed API)
│   ├── liberty/        # Liberty Pharmacy ETL (Liberty RX → Azure SQL)
│   ├── shared/         # Shared utilities (db.py, email_azure.py)
│   └── sms/            # RingCentral SMS integration
├── prefect/
│   ├── flows/          # Prefect flow definitions
│   └── deployments/    # Deployment configs
├── legacy/             # Pre-Prefect orchestrators
└── scripts/            # Debugging and utility scripts
```

## Key Integration Points

- **eMed API:** `POST /api/public/moct-visit` — creates visits from ETL data
- **Database:** Azure SQL `liberty_link_stage` (production) — shared with emed_app
- **Database user:** `emed_etl` (least-privilege; never use admin in ETL code)

## Environment

Credentials in `.env`:
- Azure SQL credentials (runtime data writes only — schema tooling uses `../emed_sql/.env`)
- WooCommerce API keys
- SSH/SFTP credentials (Cloudways)
- eMed API credentials
- RingCentral SDK config

## Job Servers

- Rx Compound Store (table_prefix='rxcs')
- Mister Meds (table_prefix='mmed')
- Schedule: every 30 minutes
