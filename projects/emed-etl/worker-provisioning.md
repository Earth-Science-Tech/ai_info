# Prefect Worker Host Provisioning Checklist

What a new Windows job-server worker host needs before joining a work queue.
Written 2026-08-11 after `rxcs-jobserver-worker2` went live missing several of
these and failed **every flow run it picked up for ~an hour** (23 crashed + 16
failed) while competing with the healthy worker on the same queue.

## Why this matters

A broken worker doesn't just fail its own runs — it **steals runs from healthy
workers** on the same queue and fails them. If you can't finish provisioning in
one sitting, don't leave the worker service running; stop it (NSSM) until the
host is complete.

## Checklist

1. **Python** (worker runs flows as subprocesses of the service account, e.g.
   `jobrunner`) with `requirements.txt` installed.
2. **git on PATH for the service account.** Every flow run starts with a
   `git_clone` pull step (see `prefect.yaml`). Missing git ⇒ every run
   **CRASHES** with `[WinError 2] The system cannot find the file specified`
   in `prefect.deployments.steps.core` before the flow even loads.
3. **Microsoft ODBC Driver 17 for SQL Server.** The ETL hardcodes this driver
   name (`flows/utilities/db.py:_ODBC_DRIVER`); Driver 18 alone does NOT
   match. Missing ⇒ flows load but fail with
   `IM002 ... no default driver specified`.
4. **Prefect profile / API auth** for the worker service (it must reach the
   Prefect server at `etst-prefect.eastus.cloudapp.azure.com`).
5. **NSSM service** running `prefect worker start` against `etst-work-pool`
   and the tenant's queue (see `emed_etl/INSTRUCTIONS.md`).
6. **Network reachability to that tenant's Liberty source DB** — a tenant's
   Liberty source is only reachable from that tenant's job server network,
   which is why deployments are pinned to per-tenant queues.
7. **No host env vars are needed for flow credentials.** As of 2026-08-11 the
   last env-var holdouts (the three SMS flows' `EMED_*` DB creds and the
   intake-form flow's `WOO_*` WooCommerce creds) were migrated to Prefect
   Secret blocks (emed_etl commits `11c42b3`, `7182cd5`). If a flow fails
   with ODBC `08001` / `SERVER=None` on one host only, suspect a regression
   to `os.getenv`-based credentials built at module import.

## Diagnosing a sick worker fast

Failure signature → missing piece:

| Symptom (flow-run state + error) | Cause |
|---|---|
| CRASHED, `WinError 2` in pull step | git not on PATH |
| FAILED, `IM002 no default driver` | ODBC Driver 17 missing |
| FAILED, `08001 Named Pipes ... Server not found` with other flows green | conn string built from env vars the host doesn't have (`SERVER=None`) |

Attribution tip: a flow run's logs contain the submitting worker's name
(`Worker 'ProcessWorker <name>' submitting flow run`), so you can split a
queue's runs by worker via `/logs/filter` even though the flow-run object
doesn't carry the worker name.
