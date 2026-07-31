# Liberty / RxQ Pharmacy Database — Schema Reference

A structured, greppable map of the **Liberty (RxQ) pharmacy-management database** that the eMed platform integrates with. The goal: let engineers and Claude instances understand what data Liberty holds — tables, columns, keys, relationships, coded value domains — **without re-querying the live database every time**.

## What this is

The Liberty database (`RXQRXCOMPOUNDSTORE`) is the operational data store of the Liberty pharmacy-management software. It has **360 tables / 5,828 columns**, holding patients, prescriptions, dispensing/fill events, drugs & compounding, prescribers, e-prescriptions, insurance claims, shipping, clinical safety data, and audit logs. The eMed Liberty ETL mirrors a small slice of it into Azure `liberty_link_stage`; this reference documents the **whole** source so future features know what else is available.

> **This schema is shared across all three pharmacy tenants** — Rx Compound Store (`rxcs`), Mister Meds (`mmed`), and Meduvo (`mdvo`) — because they all run the same Liberty software. **Table / column / key structure is tenant-independent.** Only the **row counts** and **sampled enum values** in this reference are from the **RXCS** instance (the only one reachable from the office network) and are point-in-time.

## How it was produced

A strictly **read-only** extraction from the RXCS Liberty SQL Server (`libertyserver.localdomain`, SQL Server 2022), reachable only from the office LAN using the `SRC_*` credentials in `emed_etl/.env`. Structure came from the `sys.*` / `INFORMATION_SCHEMA` catalog views; relationships were inferred from column naming and then **data-validated** against real key values (aggregate counts only — no patient rows were ever read). See the Regeneration section at the bottom.

## Key facts & caveats

- **Scale:** 360 base tables — **173 populated**, **187 empty** (Liberty features RXCS doesn't use). 5,828 columns, 1 view, **0 stored procedures, 0 functions**. All business logic lives in the Liberty application tier, not the database.
- **⚠️ Zero foreign keys.** Liberty declares **no FK constraints anywhere** (verified via `sys.foreign_keys` across all 360 tables). All referential integrity is enforced by the application. Therefore **every relationship in this reference is _inferred_ from column naming** (`PatientId`, `ScriptNumber`, `DrugKey`, `DoctorId`, `GID`, …), never a declared constraint.
- **Relationships are tagged verified-vs-inferred, then graded by data.** Each inferred edge was validated by measuring its referential match rate — what fraction of child values actually exist in the parent key — and tagged:
  - **high** (≥95% match) — 87 edges, e.g. `PrescriptionRequests.PatientId → rxqPatient` (100%), `rxqAccountReceivable.ScriptNumber → rxqScriptBase` (99.9%)
  - **medium** (60–95%) — 5 · **low** (<60%) — 29 · **no-data** (empty child table) — 106 · **unvalidated** (empty parent / type mismatch) — 47
  Treat `high` as trustworthy join paths and `low`/`no-data`/`unvalidated` as weak guesses.
- **PHI policy.** This reference contains schema, row counts, and distinct values of **small non-PHI coded/status columns only**. It contains **no patient data**. Anyone extending it must preserve that — never dump patient/prescription rows into this repo.

## Core entity model

The prescription record **`rxqScriptBase`** (natural key **`ScriptNumber`** — a business key, not the surrogate identity) is the hub, referenced by ~66 tables. It links to **`rxqPatient`** (`PatientId`, referenced by ~50 tables) and **`rxqDrug`** (`GID`/`DrugId`, ~33 tables). Each dispense/fill event is a row in **`rxqScriptTransaction`** (155 columns — pricing, insurance adjudication, workflow state). Prescribers live in **`rxqDoctor`**; inbound electronic prescriptions in **`rxqEScript`**; outbound shipping in **`rxqShipment`** + **`rxqShipmentScriptNumber`**. Around this core sit compounding/batch, inventory, insurance/claims (NCPDP), clinical-safety (allergies/DUR/ICD), messaging, and audit modules.

## Domain modules

Deep per-table docs (purpose, full column tables with coded-value domains, confidence-tagged relationships, indexes, gotchas), grouped by domain:

| Module | Tables | Docs |
|---|---|---|
| Prescriptions & Dispensing | 20 | [01-prescriptions-dispensing.md](modules/01-prescriptions-dispensing.md) |
| Patients & Demographics | 10 | [02-patients-demographics.md](modules/02-patients-demographics.md) |
| Drugs & Formulary | 10 | [03-drugs-formulary.md](modules/03-drugs-formulary.md) |
| Compounding & Batches | 7 | [04-compounding-batches.md](modules/04-compounding-batches.md) |
| Inventory, Stock & Ordering | 12 | [05-inventory-stock-ordering.md](modules/05-inventory-stock-ordering.md) |
| Prescribers, eScript & SureScripts | 8 | [06-prescribers-escript-surescripts.md](modules/06-prescribers-escript-surescripts.md) |
| Insurance, Claims, NCPDP, AR & Billing | 17 | [07-insurance-claims-billing-pricing.md](modules/07-insurance-claims-billing-pricing.md) |
| Clinical Safety & Care | 16 | [08-clinical-safety-care.md](modules/08-clinical-safety-care.md) |
| Workflow, Queues & Tasks | 7 | [09-workflow-queues-tasks.md](modules/09-workflow-queues-tasks.md) |
| Shipping, Packaging & Delivery | 5 | [10-shipping-packaging-delivery.md](modules/10-shipping-packaging-delivery.md) |
| Notes, Messaging, SMS & Fax | 12 | [11-notes-messaging-fax.md](modules/11-notes-messaging-fax.md) |
| Scheduled-Drug Reporting & PMP | 7 | [12-scheduled-drug-reporting-pmp.md](modules/12-scheduled-drug-reporting-pmp.md) |
| Users, Security & Licensing | 11 | [13-users-security-licensing.md](modules/13-users-security-licensing.md) |
| Automation, Devices, Interfaces & Appointments | 10 | [14-automation-devices-interfaces.md](modules/14-automation-devices-interfaces.md) |
| Config, Parameters & Printing | 8 | [15-config-parameters-printing.md](modules/15-config-parameters-printing.md) |
| Audit, Change Logs & Sync | 13 | [16-audit-changelog-sync.md](modules/16-audit-changelog-sync.md) |

Plus [empty-tables.md](empty-tables.md) — the 187 present-but-unused tables.

## ETL mirror status

Only **11 of 360 tables** are currently mirrored into Azure `liberty_link_stage` by the emed_etl Liberty ETL:

`rxqScriptTransaction`, `rxqScriptBase`, `rxqNotes`, `rxqShipmentScriptNumber`, `rxqShipment`, `rxqPatient`, `rxqEScript`, `rxqDoctor`, `rxqDrug`, `rxqWorkflowLocation`, `rxqQueue`.

Everything else exists in Liberty but is **not** in `liberty_link_stage`. A feature that needs an un-mirrored table must extend the ETL — see `emed_etl/flows/emed_etl/liberty_etl_config.json`. Each per-table doc notes its mirror status.

## How to use

- **Looking for a specific field or table?** `grep` [catalog/liberty_catalog.json](catalog/liberty_catalog.json) — full machine-readable metadata for all 360 tables.
- **Need the exact DDL?** [ddl/&lt;Table&gt;.sql](ddl/) — synthesized `CREATE TABLE` + indexes per table.
- **Understanding a domain?** Read the relevant `modules/*.md`.
- **Row counts / relationship graph at a glance?** [catalog/catalog_summary.json](catalog/catalog_summary.json).

---

## Regeneration

This reference was generated by a strictly **read-only** extraction from the RXCS Liberty database (`RXQRXCOMPOUNDSTORE` on `libertyserver.localdomain`, reachable only from the office LAN) using the `SRC_*` credentials in `emed_etl/.env`, followed by a documentation pass.

- `catalog/liberty_catalog.json` — full machine-readable metadata for all 360 tables (columns, types, keys, indexes, inferred relationships, sampled non-PHI enum values). **Grep this first** when you need a fast, precise answer.
- `catalog/catalog_summary.json` — lightweight index (table, row count, column count, PK, inferred edges, referenced-by).
- `ddl/<Table>.sql` — synthesized `CREATE TABLE` + indexes for every table.
- `modules/*.md` — narrative per-table docs for the 173 populated tables, grouped by domain.
- `empty-tables.md` — the 187 present-but-unused tables.

**PHI rule for anyone regenerating:** extract schema + row counts + distinct values of small non-PHI coded columns only. Never dump patient/prescription data rows into this repo.
