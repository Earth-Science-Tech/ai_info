# eMed ETL Overview

## Two ETL Pipelines

### 1. Peaks Curative ETL
- **Source:** peakscurative.com WordPress (WooCommerce + WPForms)
- **Target:** Azure SQL → eMed API
- **Schedule:** Every 30 minutes
- **Purpose:** Convert e-commerce orders + patient questionnaires into medical visits

**Flow:**
1. Fetch WooCommerce orders (last 2 days)
2. Fetch WPForms questionnaires with field mappings (last 2 days)
3. Match orders to questionnaires by email/order ID
4. Call eMed API (`POST /api/public/moct-visit`) to create visits
5. Update Advanced Shipment Tracking

**Key scripts:**
- `etl/peaks/peaks_etl_woo_orders.py` — Fetch WooCommerce orders
- `etl/peaks/peaks_etl_wpforms_entries.py` — Fetch questionnaires
- `etl/peaks/peaks_update_moct.py` — Transform and create visits
- `etl/peaks/peaks_update_ast.py` — Shipment tracking

### 2. Liberty Pharmacy ETL
- **Source:** Liberty RX pharmacy database
- **Target:** Azure SQL
- **Schedule:** Every 30 minutes
- **Purpose:** Transfer pharmacy operational data
- **Multi-tenant:** Supports `rxcs` (Rx Compound Store) and `mmed` (Mister Meds) via table_prefix

**Key scripts:**
- `etl/liberty/run_etl.py` — Transfer single table
- `etl/liberty/etl_config.json` — Table transfer configuration

## Orchestration

### Prefect (current)
- `prefect/flows/peaks_flow.py` — Peaks ETL as Prefect flow
- `prefect/flows/liberty_flow.py` — Liberty ETL as Prefect flow
- `prefect/flows/combined_flow.py` — Both pipelines

### Legacy (pre-Prefect)
- `legacy/run_all_etl.py` — Combined orchestrator
- `legacy/peaks_etl_orchestrator.py` — Peaks-only orchestrator

## SMS Integration
- `etl/sms/sms_fetch_message_history.py` — RingCentral message history
- `etl/sms/sms_send_pending.py` — Send pending SMS messages

## Job Servers
- **Rx Compound Store server** (table_prefix='rxcs')
- **Mister Meds server** (table_prefix='mmed')
