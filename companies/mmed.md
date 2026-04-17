# Mister Meds (MMed)

## Overview

Pharmacy services subsidiary of Earth Science Tech. Operates its own pharmacy database (Liberty RX) and job server for ETL processes.

## Database Tables

- **Prefix:** `mmed_*` (13 tables in liberty_link_stage)
- **Data:** Pharmacy operational data
- **Source:** Liberty RX pharmacy management system

## ETL Integration

- **Job Server:** Mister Meds server
- **Table Prefix:** `mmed` (used in multi-tenant ETL configuration)
- **Schedule:** Every 30 minutes via Windows Task Scheduler / Prefect
- **Script:** `etl/liberty/run_etl.py` with `table_prefix='mmed'`

## Key Views

- `view_mmed_*` — Mister Meds specific views
