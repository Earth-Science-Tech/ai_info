# Rx Compound Store (RXCS)

## Overview

Compounding pharmacy subsidiary of Earth Science Tech. Operates its own pharmacy database (Liberty RX) and job server for ETL processes.

## Database Tables

- **Prefix:** `rxcs_*` (19 tables in liberty_link_stage)
- **Data:** Pharmacy operational data — prescriptions, patients, orders, pricing
- **Source:** Liberty RX pharmacy management system

## ETL Integration

- **Job Server:** Rx Compound Store server
- **Table Prefix:** `rxcs` (used in multi-tenant ETL configuration)
- **Schedule:** Every 30 minutes via Windows Task Scheduler / Prefect
- **Script:** `etl/liberty/run_etl.py` with `table_prefix='rxcs'`

## Pricing Tables

- `rxcs_price_plan` — Pricing plans
- `rxcs_price_*` — Various pricing tables

## Key Views

- `view_rxcs_*` — Rx Compound Store specific views
