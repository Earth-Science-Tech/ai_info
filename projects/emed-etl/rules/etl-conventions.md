# emed_etl Conventions

## Script Naming

- `peaks_*.py` — Peaks Curative ETL scripts
- `liberty_*.py` — Liberty Pharmacy ETL scripts
- `shared_*.py` — Shared utilities
- `sms_*.py` — SMS integration scripts

## Database User

Always use `emed_etl` user (least-privilege). Never use admin credentials in ETL code.

## Batch Processing

- Use `executemany()` for bulk inserts
- Commit every 500 records
- Always set processing flags before and after operations

## Error Handling

- Log errors to `etl_metadata` table
- Send email notifications on failure (via `shared/email_azure.py`)
- Never silently swallow exceptions

## Prefect Flows

New ETL work should use Prefect flows (`prefect/flows/`), not legacy orchestrators.
