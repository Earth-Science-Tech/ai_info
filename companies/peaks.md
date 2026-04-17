# Peaks Curative

## Overview

Curative e-commerce company and primary client of the eMed telemedicine platform. Sells compounded medications through a WordPress/WooCommerce storefront.

## Website

- **URL:** peakscurative.com
- **Platform:** WordPress on Cloudways hosting
- **E-commerce:** WooCommerce
- **Forms:** WPForms (patient questionnaires)

## Integration with eMed

### Data Flow
```
Customer places order on peakscurative.com
  → WooCommerce order created
  → Patient fills WPForms questionnaire
  → ETL fetches both (every 30 min)
  → Matches order ↔ questionnaire
  → Creates moct_visit via eMed API
  → Prescriber reviews and approves in eMed UI
  → Pharmacy fills and ships order
```

### Database Tables
- `woo_*` (4 tables) — WooCommerce order staging
- `wpforms_*` (2 tables) — Patient questionnaire staging
- `view_peaks_*` — Peaks-specific views
- `view_woo_*` — WooCommerce views

### ETL Scripts (in emed_etl)
- `etl/peaks/peaks_etl_woo_orders.py` — Fetch orders
- `etl/peaks/peaks_etl_wpforms_entries.py` — Fetch questionnaires
- `etl/peaks/peaks_update_moct.py` — Create visits
- `etl/peaks/peaks_update_ast.py` — Shipment tracking
- `etl/peaks/peaks_etl_sms_missing_intake_forms.py` — SMS reminders

### API Access
- WooCommerce REST API (consumer key/secret in `.env`)
- WordPress/WPForms via SSH/SFTP to Cloudways server
