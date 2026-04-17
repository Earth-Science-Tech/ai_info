# emed_etl - Python ETL Context

## Overview
- **Tech:** Python / Prefect / pyodbc / Azure SQL
- **Repo:** https://github.com/Earth-Science-Tech/emed_etl
- **Branch:** `main`
- **SQL Schemas:** Git submodule `sql/` → emed_sql

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
├── scripts/            # Debugging and utility scripts
└── sql/                # Git submodule → emed_sql
```

## Key Integration Points

- **eMed API:** `POST /api/public/moct-visit` — creates visits from ETL data
- **Database:** Azure SQL (liberty_link_stage) — shared with emed_app
- **Database user:** `emed_etl` (least-privilege)

## Environment

Credentials in `.env` (manually synced with emed_app):
- Azure SQL credentials
- WooCommerce API keys
- SSH/SFTP credentials (Cloudways)
- eMed API credentials
- RingCentral SDK config

## Job Servers

- Rx Compound Store (table_prefix='rxcs')
- Mister Meds (table_prefix='mmed')
- Schedule: every 30 minutes
