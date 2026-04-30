# Gotcha: rxcs/mmed ETL Partial-Data Window

## TL;DR

Liberty Pharmacy ETL inserts `rxcs_rxqFullOrder` / `mmed_rxqFullOrder` rows in **stages**. There is a window — sometimes hours long — where the row exists with `ScriptNumber`, `RefillNumber`, and `QuantityDispensed` populated, but `P_*`, `Dr_*`, `Dr_ClinicName`, and `Name` (drug name) are still NULL. Code that reads from these tables (or from views built on them) during that window gets an incomplete record back, not a missing one.

## How it manifests

The downstream views (`view_rxcs_full_order`, `view_mmed_full_order`, `view_emed_full_order`) compute display fields like this:

```sql
LTRIM(RTRIM(CONCAT(P_FirstName, ' ', P_LastName))) AS Patient
LTRIM(RTRIM(CONCAT(Dr_FirstName, ' ', Dr_LastName))) AS Doctor
COALESCE(Dr_ClinicName, '') AS Clinic
[Name] AS DrugName
```

When the underlying fields are NULL, the view returns:
- `Patient = ''`  (empty string, not NULL)
- `Doctor = ''`
- `Clinic = ''`
- `DrugName = NULL`

Empty strings are **truthy enough** to defeat naive `value || fallback` patterns and `if (rx) { use_rx_data() }` guards. Code thinks the record is good.

## Real incident

**Invoice INV-20260429-00029** (Rx Compound Store, 2 line items, $379.16) was created with `patient_name=""`, `drug_name=null`, `prescriber_name=""`, `clinic_name=""` displayed as "Unknown" / "Various" on the invoice page.

Timeline:
- `14:50 UTC` — `rxcs_rxqFullOrder` rows inserted with skeleton data (ScriptNumber, Quantity, but no patient/drug/prescriber)
- `15:15 UTC` — User created invoice; partial data flowed into `emed_invoice_line_item`
- `05:10 UTC next day` — ETL backfilled the patient/drug/prescriber fields

The 14-hour gap between initial insert and backfill caught the user.

## Where this matters

Any code that reads from these tables (or the views over them) and trusts non-null/non-empty as a completeness signal:

- `emed_app/server/invoice.js` — invoice creation (fixed; uses hybrid merge + guard)
- Any future feature that joins to `view_emed_full_order` for display data
- Reporting/analytics queries that aggregate by Patient or Doctor

## Defensive patterns

When reading these views/tables in code that produces persisted output:

1. **Don't trust the row hit alone** — also check that critical fields are non-empty:
   ```js
   const isComplete = rx && rx.Patient && rx.DrugName;
   ```
2. **Merge with a secondary source if available** — the Liberty API generally has full data even when our DB row is mid-ETL. Prefer non-empty values from either source:
   ```js
   const pickNonEmpty = (...vals) => vals.find(v => v != null && v !== '') ?? null;
   ```
3. **Block writes on incomplete data** — fail loudly with a "refresh and retry" message rather than persisting empty strings.

## Why the ETL works this way

(Context — confirm before refactoring.) The Liberty data model splits prescription, patient, prescriber, drug, and clinic into separate entities. The ETL appears to insert the prescription record first and backfill related entities on subsequent runs. Switching to atomic full-row inserts would require coordinating across multiple Liberty API calls per script.

## See also

- `etl-overview.md` — pipeline schedule and orchestration
- `database-schema.md` — view definitions
- `emed-app/context.md` — invoice creation flow
