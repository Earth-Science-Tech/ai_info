# emed_etl - Python ETL Context

## Overview
- **Tech:** Python / Prefect / pyodbc / Azure SQL / dbt-sqlserver
- **Repo:** https://github.com/Earth-Science-Tech/emed_etl
- **Branch:** `main`
- **Schema:** lives in sibling `../emed_sql/` repo (no longer a submodule as of 2026-05-04)

## Schema Changes

ETL code lives here, but any **database schema change** (new table, new column, new grant) goes through `emed_sql` via the dev-first workflow. See `ai_info/skills/create-table.md`. Don't put `.sql` files in this repo.

**Exception:** dbt model `.sql` files under `dbt/` are transformations (not schema migrations) and *do* live in this repo. The `block_sql_creation` hook carves out `dbt/` specifically.

## Directory Structure

```
emed_etl/
├── flows/
│   ├── emed_etl/       # Liberty + Peaks ETL flows, warehouse clone, dbt build
│   ├── sms/            # RingCentral SMS flows
│   └── utilities/      # Shared helpers (db.py, db_clone.py, email, SSL checks)
├── dbt/                # etst_warehouse dbt project (staging / core / marts)
├── scripts/            # Debugging and one-off utility scripts
└── prefect.yaml        # Prefect deployment manifest
```

## Pipelines

1. **Liberty Pharmacy ETL** — Liberty RX → `liberty_link_stage` (Azure SQL). Multi-tenant by `table_prefix` (`rxcs`, `mmed`, `mdvo`). Driven by `flows/emed_etl/liberty_run_etl_flow.py` + `liberty_etl_config.json`.
2. **Peaks Curative ETL** — WooCommerce + WPForms → `liberty_link_stage` → eMed API (`POST /api/public/moct-visit`). Driven by the `peaks_*_flow.py` flows. Shipment tracking back to the Peaks WordPress site (AST Pro plugin) runs as a subflow of the Liberty `run_all_etl` orchestrator — see [ast-shipment-tracking.md](ast-shipment-tracking.md) for the pipeline, the silent-failure gotcha, and the manual backfill tool.
3. **Stage → Warehouse clone** — `flows/emed_etl/clone_prod_to_warehouse_stage.py` reloads `etst_warehouse.stg` nightly from `liberty_link_stage` via Azure SQL elastic query.
4. **Warehouse dbt build** — `flows/emed_etl/dbt_warehouse_build.py` runs `dbt deps && dbt build` against the `etst_warehouse` project after the stage clone finishes.

See [warehouse.md](warehouse.md) for the warehouse layer in detail.

## Key Integration Points

- **eMed API:** `POST /api/public/moct-visit` — creates visits from ETL data
- **Operational DB:** Azure SQL `liberty_link_stage` (shared with emed_app)
- **Warehouse DB:** Azure SQL `etst_warehouse` (reporting / analytics, owned by emed_etl)
- **Database user:** `emed_etl` (least-privilege) on both DBs; never use admin in ETL code

## Environment

Credentials in `.env` and Prefect Secret blocks (manually synced with emed_app):
- Azure SQL credentials (`emed-database-*`, `etst-warehouse-etl-*`) — runtime data writes only; schema tooling uses `../emed_sql/.env`
- WooCommerce API keys
- SSH/SFTP credentials (Cloudways)
- eMed API credentials
- RingCentral SDK config

## Job Servers

- Rx Compound Store (table_prefix='rxcs')
- Mister Meds (table_prefix='mmed')
- Meduvo (table_prefix='mdvo') — pending job-server provisioning
- Liberty ETL: every 15–60 minutes per table (see `prefect.yaml`)
- Warehouse clone: nightly 01:00 ET, dbt build at 02:00 ET
