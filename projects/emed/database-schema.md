# eMed Database Schema Overview

## Database: liberty_link_stage @ liberty-link.database.windows.net

## Table Prefixes (82+ tables)

| Prefix | Count | Domain | Key Tables |
|--------|-------|--------|------------|
| `moct_*` | 25 | Core medical office | `moct_visit`, `moct_person`, `moct_drug_rx`, `moct_questionnaire`, `moct_order_tracking` |
| `rxcs_*` | 19 | Rx Compound Store | Pharmacy data + pricing |
| `emed_*` | 15 | eMed platform | Users, email, SMS, billing, pricing, invoicing |
| `mmed_*` | 13 | Mister Meds | Pharmacy data |
| `woo_*` | 4 | WooCommerce | Order staging from WordPress |
| `wpforms_*` | 2 | WPForms | Patient questionnaire staging |
| Other | 4+ | System | `sessions`, `etl_metadata`, `sql_log`, `blaze_patients` |

## Core Tables

### moct_visit (main visit/order table)
The central table — represents a patient consultation/order. Links to moct_person (patient), moct_drug_rx (prescriptions), moct_questionnaire (intake forms).

### moct_person (patient info)
Patient demographics. Linked from moct_visit.

### moct_drug_rx (prescriptions)
Prescription records tied to visits.

### moct_order_tracking (shipment tracking)
Advanced Shipment Tracking data for orders.

## Views (19)

Prefixed by domain: `view_emed_*`, `view_mmed_*`, `view_moct_*`, `view_rxcs_*`, `view_peaks_*`, `view_woo_*`

## Stored Procedures (18)

- `usp_etl_*` — ETL merge/transform operations
- `usp_insert_*` — Data insertion helpers
- `usp_normalize_*` — Data normalization
- `usp_refresh_*` — View/cache refresh

## Detailed Schema

For complete column-level schema (all tables, views, procedures with SQL source):
- Run: `python python/extract_schema.py` from emed_app root
- Read: `emed_app/sql/info.claude`
