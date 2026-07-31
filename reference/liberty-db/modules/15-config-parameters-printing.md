# Liberty schema — Config, Parameters & Printing

System- and store-level parameters, print options and templates, UI data-view layouts, key/settings tables, and miscellaneous configuration.

> Part of the [Liberty/RxQ schema reference](../README.md). Liberty declares **no foreign-key constraints** (verified via `sys.foreign_keys`), so all relationships shown are **inferred from column naming and then data-validated** by referential match rate — each is tagged high / medium / low / no-data / unvalidated confidence. Row counts and sampled enum values are from the RXCS instance (point-in-time); the schema itself is identical across the rxcs / mmed / mdvo tenants.

**Tables in this module (8):** [`rxqParameterGeneral`](#rxqparametergeneral) · [`rxqParameterStore`](#rxqparameterstore) · [`rxqParameterImage`](#rxqparameterimage) · [`rxqStorePrintOptions`](#rxqstoreprintoptions) · [`rxqPrintingTemplate`](#rxqprintingtemplate) · [`rxqDataViewLayout`](#rxqdataviewlayout) · [`rxqPif`](#rxqpif) · [`rxqSettings`](#rxqsettings)

---

## `rxqParameterGeneral`

Rows (RXCS): 1 · Columns: 26 · PK: `cParameterGeneralId` · ETL-mirrored into liberty_link_stage: no

**Purpose**

A singleton (1-row) system/store configuration table holding pharmacy-wide operating parameters: finance-charge tiers (`MinFinanceCharge1`-`10`), an `AllowDecimalQuantities` dispensing flag, `OperatingSystem`/`StoreNumber`/`AccountNumber` identifiers, and a handful of loosely-typed "current context" pointer columns (`PatientId`, `DrugKey`, `DoctorKey`, `AccountId`, `PendingScriptId`, `PackingListKey`, `TransferOrderKey`). (inferred) The pointer columns look like leftover/last-used-value fields from the Liberty desktop client's global settings screen rather than true relational links, consistent with the single row and the near-total absence of validated referential matches below.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cParameterGeneralId | int | NO | PK | identity |
| PatientId | varchar(50) | YES | → rxqPatient (weak, see Relationships) | |
| MinFinanceCharge1 | float | YES | | finance-charge tier 1 |
| MinFinanceCharge2 | float | YES | | finance-charge tier 2 |
| MinFinanceCharge3 | float | YES | | finance-charge tier 3 |
| MinFinanceCharge4 | float | YES | | finance-charge tier 4 |
| MinFinanceCharge5 | float | YES | | finance-charge tier 5 |
| MinFinanceCharge6 | float | YES | | finance-charge tier 6 |
| MinFinanceCharge7 | float | YES | | finance-charge tier 7 |
| MinFinanceCharge8 | float | YES | | finance-charge tier 8 |
| MinFinanceCharge9 | float | YES | | finance-charge tier 9 |
| MinFinanceCharge10 | float | YES | | finance-charge tier 10 |
| DrugKey | varchar(50) | YES | → rxqDrug (weak, see Relationships) | |
| MsUpdateCount | int | YES | | |
| AccountNumber | int | YES | | |
| OperatingSystem | varchar(50) | YES | | |
| StoreNumber | varchar(50) | YES | | |
| LastModified | datetime | YES | | |
| IsValid | bit | YES | | sampled value: `true` (count 1) |
| AllowDecimalQuantities | bit | YES | | dispensing config flag |
| DoctorKey | varchar(50) | YES | | no implicit_ref detected |
| AccountId | varchar(50) | YES | | no implicit_ref detected |
| PendingScriptId | varchar(50) | YES | | no implicit_ref detected |
| LibertyId | bigint | YES | | |
| PackingListKey | int | YES | | no implicit_ref detected |
| TransferOrderKey | int | YES | | no implicit_ref detected |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**:
  - `PatientId` → `rxqPatient` (join `PatientId`) — inferred, **low** confidence (0.0% referential match; 1 non-null value checked, 1 orphan; not sampled).
  - `DrugKey` → `rxqDrug` (join `DrugId`) — inferred, **low** confidence (0.0% referential match; 1 non-null value checked, 1 orphan; not sampled).
- **Inbound (inferred)**: none.

These edges are named-column guesses data-validated against a single-row table, and both failed to resolve (0% match) — treat as unconfirmed/likely-stale pointer values, not real links.

**Indexes**

None reported.

**Gotchas**

- Only 1 row exists (singleton config table) — any join against it is effectively a constant lookup, not a real relational join.
- Despite naming suggesting FKs, `PatientId` and `DrugKey` both show 0% match against their apparent parent tables (`rxqPatient`, `rxqDrug`) — likely stale/orphaned or last-session values rather than active references.
- `DoctorKey`, `AccountId`, `PendingScriptId`, `PackingListKey`, `TransferOrderKey` look like implicit references by name (Doctor/Account/Script/PackingList/TransferOrder) but had no implicit_ref inferred/validated in the metadata — do not assume they resolve to other rxq* tables without independent verification.
- Not mirrored by ETL into liberty_link_stage — not available to eMed app/reporting; any consumer needing this config must query Liberty directly.

---

## `rxqParameterStore`

Rows (RXCS): 1 · Columns: 72 · PK: `cParameterStoreId` · ETL-mirrored into liberty_link_stage: no

**Purpose**

Single-row (per-tenant) store-configuration table holding pharmacy identity/licensing (NABP, DEA, DPS, NPI, Federal ID, e-prescribing credentials), storefront contact/location data (address, phone, fax, lat/long, timezone, hours), label/printing preferences, tax and finance-charge/AR defaults, service fees (`DefaultServiceFee`, `ImmunizationFee`), messaging toggles (text/voice), auto-bin assignment settings, and versioning/serial info (`LastRXQVersion`, `SerialNumber`, `RxqSerialNumber`). The unique index on `StoreNumber` and the single sampled row confirm this is a one-row-per-store settings/config table, not a transactional table (inferred). It functions as the pharmacy's global settings singleton read by the Liberty/RxQ application at runtime (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cParameterStoreId | int | NO | PK | identity |
| LabelAddress | varchar(50) | YES | | |
| PointOfSale | varchar(50) | YES | | |
| AlternateCityDisplay | varchar(50) | YES | | |
| WorkInvoiceNumber | int | YES | | |
| PharmacyName | varchar(50) | YES | | |
| PharmacyStreet | varchar(50) | YES | | |
| PharmacyCity | varchar(50) | YES | | |
| PharmacyState | varchar(50) | YES | | |
| PharmacyZipA | varchar(50) | YES | | |
| PharmacyZipB | varchar(50) | YES | | |
| PharmacyPhone | varchar(50) | YES | | |
| FederalIdNumber | varchar(50) | YES | | |
| ContainerChargeA | decimal(9,2) | YES | | |
| ContainerChargeB | decimal(9,2) | YES | | |
| SalesTaxMedical | decimal(9,4) | YES | | |
| SalesTaxNonMedical | decimal(9,4) | YES | | |
| DaysSuppliedRequired | varchar(50) | YES | | |
| FormulaPriority | varchar(50) | YES | | |
| FinanceCharge | decimal(9,3) | YES | | |
| AR_DefaultCode | varchar(50) | YES | | |
| AR_FinanceChargeCode | int | YES | | sampled value: `0` (count 1) |
| AR_CreditLimit | int | YES | | |
| PrintRph | varchar(50) | YES | | |
| PrintRefilsRemaining | varchar(50) | YES | | |
| PrintExpirationDate | varchar(50) | YES | | |
| PrintLabel | varchar(50) | YES | | |
| ExtendDailyLog | varchar(50) | YES | | |
| RoundUpToAmount | varchar(50) | YES | | |
| PercentGenericSp | int | YES | | |
| PharmacyNabp | int | YES | | pharmacy NABP number |
| LabelHeadingsSwitch | varchar(50) | YES | | |
| DFlag | varchar(50) | YES | | |
| PharmacyFax | varchar(50) | YES | | |
| PrivatePhoneNumber | varchar(50) | YES | | |
| EmailAddress | varchar(50) | YES | | |
| DeaNumber | varchar(50) | YES | | pharmacy DEA registration |
| DpsNumber | varchar(50) | YES | | |
| NationalProviderId | varchar(50) | YES | | NPI |
| ePrescribingCode | varchar(50) | YES | | |
| ePrescribingPassword | varchar(50) | YES | | stored credential (plaintext column name — sensitive) |
| StoreNumber | varchar(50) | YES | | unique index `IX_rxqParameterStore_StoreNumber` |
| LastModified | datetime | YES | | |
| IsValid | bit | YES | | sampled value: `true` (count 1) |
| EnableTextMessaging | char(1) | YES | | |
| ShowReleaseNotesAfter | varchar(50) | YES | | |
| DefaultServiceFee | decimal(9,2) | YES | | |
| NcpdpPharmacyServiceType | char(2) | YES | | sampled value: `01` (count 1) — NCPDP pharmacy service type code |
| LastRXQVersion | varchar(50) | YES | | |
| BZQDatabase | varchar(max) | YES | | |
| BZQServer | varchar(max) | YES | | |
| SerialNumber | varchar(50) | YES | | |
| FlatTaxAmount | decimal(9,2) | NO | | |
| EnableVoiceMessaging | bit | YES | | |
| EnableStoreCustomWrkFlw | bit | YES | | |
| LastAutoBinAssigned | varchar(50) | YES | | |
| LastAutoBinAssignedDate | datetime | YES | | |
| AutoBinCycleDays | int | YES | | |
| UseAutoBinAssign | bit | YES | | |
| NotificationEmail | varchar(50) | YES | | |
| RxqSerialNumber | varchar(200) | YES | | |
| ImmunizationFee | decimal(9,2) | YES | | |
| PharmacyHours | varchar(max) | YES | | |
| BillImmunizationCash | int | YES | | |
| ChargeSalesTaxCashRx | bit | YES | | |
| cAccountReceivablePrintCodeId | int | YES | → `rxqAccountReceivablePrintCode` | sampled value: `0` (count 1) |
| PharmacySuite | varchar(50) | YES | | |
| Latitude | decimal(12,9) | YES | | |
| Longitude | decimal(12,9) | YES | | |
| Timezone_StandardName | varchar(50) | YES | | |
| Timezone_DisplayName | varchar(50) | YES | | |
| Timezone_BaseUtcOffset | varchar(50) | YES | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**:
  - `cAccountReceivablePrintCodeId` → `rxqAccountReceivablePrintCode` (join col `cAccountReceivablePrintCodeId`) — inferred, **unvalidated** (parent table empty, no match rate computable; not sampled).
- **Inbound (inferred)**: none.

These edges are inferred purely from column naming, then attempted-validated against actual data — not enforced database constraints. The one outbound edge is unconfirmed/weak (parent table has no rows to validate against).

**Indexes**

- `IX_rxqParameterStore_StoreNumber` (UNIQUE, NONCLUSTERED) on `StoreNumber` — enforces one config row per store; likely the app's lookup key for resolving store settings.

**Gotchas**

- Single-row table (RXCS instance) — treat as a settings singleton, not a per-record entity; row_count will differ only if the tenant has multiple physical store locations under one Liberty DB.
- `ePrescribingPassword` stores an e-prescribing credential directly in this table — sensitive value, handle with care in any extract/mirror.
- Not mirrored by ETL into liberty_link_stage — eMed has no visibility into pharmacy-level config (tax rates, fees, DEA/NPI, hours) via the standard mirror; anything needing this data must query Liberty directly or be added to the ETL.
- The only inferred FK-like edge (`cAccountReceivablePrintCodeId` → `rxqAccountReceivablePrintCode`) could not be data-validated because the parent table is empty — do not treat as confirmed.

---

## `rxqParameterImage`

Rows (RXCS): 1 · Columns: 3 · PK: `StoreNumber`, `ImageKey` · ETL-mirrored into liberty_link_stage: no

**Purpose** — A tiny keyed binary-blob store: composite key (`StoreNumber`, `ImageKey`) maps to a single `varbinary(max)` `Image` column. (Inferred) Given the "Parameter" naming and the store-scoped key, this most likely holds a small number of configuration/branding images referenced by store-level parameters (e.g., a logo or signature image used on printed labels/receipts) rather than per-patient or per-prescription clinical images — but the metadata contains no `lookups` or relationships to confirm what `ImageKey` values mean or what consumes them. Only 1 row exists in the RXCS instance, consistent with a sparsely-used, per-store configuration image table rather than a high-volume operational one.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| StoreNumber | varchar(50) | NO | PK | part of composite key |
| ImageKey | varchar(50) | NO | PK | part of composite key |
| Image | varbinary(max) | YES | | binary blob payload |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

No naming-based relationships were inferred for this table (in either direction) — `StoreNumber`/`ImageKey` were not data-matched against any other table's key in this pass.

**Indexes** — none reported.

**Gotchas**
- Composite varchar(50) key (`StoreNumber`+`ImageKey`) with no declared or inferred FK — any join to a store table or a parameter-definition table would be a guess, not evidenced.
- Not ETL-mirrored to liberty_link_stage — this data is invisible to eMed/ETL-side reporting and joins.
- With only 1 row and zero relationships/lookups, table purpose is largely inferred from naming conventions alone; treat interpretation as low-confidence.

---

## `rxqStorePrintOptions`

Rows (RXCS): 2 · Columns: 15 · PK: `StoreNumber`, `WorkflowStage` · ETL-mirrored into `liberty_link_stage`: no

**Purpose** — Per-store, per-workflow-stage configuration of what documents auto-print (label, IPM reports, refill variants, compound formula worksheets) and whether the user is prompted before printing (inferred, from `PrntLabel`/`PrntIPMReports`/`Prompt`/`PrntLabelRefill`/`PrntIPMReportsRefill`/`CompoundFormulaWorksheetsWithLabel` naming). The composite PK (`StoreNumber`+`WorkflowStage`) indicates one settings row per store per pipeline stage (e.g., fill, verify, refill), consistent with the inbound reference from `rxqWorkflowStages`/`rxqWorkflowOptions` (inferred). Standard audit trail columns (`CreatedDate/By`, `LastModifiedDate/By`, `IsValid`) track row lifecycle; `ChangeMode` likely flags how the row was last changed (inferred — no documented enum, only raw sampled ints).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cStorePrintId | int | NO | | identity |
| StoreNumber | varchar(50) | NO | PK | part of composite key |
| WorkflowStage | varchar(50) | NO | PK | part of composite key; referenced by `rxqWorkflowOptions`/`rxqWorkflowStages` (inbound, inferred) |
| PrntLabel | bit | YES | | auto-print label flag (inferred) |
| PrntIPMReports | bit | YES | | auto-print IPM report flag (inferred) |
| CreatedDate | datetime | YES | | audit timestamp |
| CreatedBy | varchar(50) | YES | | audit user |
| LastModifiedDate | datetime | YES | | audit timestamp |
| LastModifiedBy | varchar(50) | YES | | audit user |
| IsValid | bit | YES | | sampled values: `true` (count 2) — only value observed, no `false` rows sampled |
| Prompt | bit | YES | | whether to prompt user before printing (inferred) |
| PrntLabelRefill | bit | YES | | auto-print label flag for refills (inferred) |
| PrntIPMReportsRefill | bit | YES | | auto-print IPM report flag for refills (inferred) |
| ChangeMode | int | YES | | sampled values: `2` (count 1), `0` (count 1) — no documented enum, raw ints only |
| CompoundFormulaWorksheetsWithLabel | bit | YES | | sampled values: `true` (count 1), `null` (count 1) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):**
  - `rxqWorkflowOptions.WorkflowStage` → this table — inferred, **unvalidated** confidence (parent empty or type mismatch; no match rate computed)
  - `rxqWorkflowStages.WorkflowStage` → this table — inferred, **low** confidence (0.0% referential match)

These inbound edges are naming-based guesses, data-validated against actual column values — not enforced constraints. The `rxqWorkflowStages` edge shows a 0% match, so treat it as unconfirmed/likely spurious; the `rxqWorkflowOptions` edge could not be validated at all.

**Indexes** — none listed in metadata.

**Gotchas**
- Only 2 rows total in RXCS (one store configuration set, likely 2 workflow-stage rows) — too small a sample to trust any lookup-derived enum as exhaustive, especially `ChangeMode`.
- Both inbound relationship candidates on `WorkflowStage` are weak/unconfirmed (unvalidated or 0% match) — do not treat `WorkflowStage` as a validated foreign key into either `rxqWorkflowOptions` or `rxqWorkflowStages` without further investigation.
- No indexes defined beyond the implicit PK — any lookup by `StoreNumber` alone (without `WorkflowStage`) is an unindexed partial-key scan.
- Not ETL-mirrored to `liberty_link_stage` — this print-configuration data is not visible in eMed's downstream reporting/mirror layer.

---

## `rxqPrintingTemplate`

Rows (RXCS): 82 | Columns: 4 | PK: (`TemplateKey`, `StoreNumber`) | ETL-mirrored into liberty_link_stage: no

**Purpose** — Stores per-store print-template configuration: a template identifier (`TemplateKey`), a filesystem/network path to the template file (`TemplatePath`), and a secondary printer assignment (`SecondPagePrinter`), keyed compositely by template and store number. (inferred) This looks like a lookup table used by the pharmacy application to resolve which document template (e.g., label, receipt, or prescription printout) to render and which printer to route a second page (such as a patient information sheet) to, on a per-store basis. No columns or sample values indicate the specific document types covered — the composite key and column names are the only evidence for this interpretation.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| TemplateKey | varchar(50) | NO | PK | part of composite PK |
| TemplatePath | varchar(256) | YES | | file/network path to template |
| SecondPagePrinter | int | YES | | printer identifier/number for second page |
| StoreNumber | varchar(50) | NO | PK | part of composite PK; store-scoped config |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

No naming-based candidate edges were detected for this table (e.g., no `StoreId`/store-master reference resolved), so it has no inferred outbound or inbound relationships in this pass — these would need to be established manually if a store-master table exists elsewhere in the schema.

**Indexes** — none reported.

**Gotchas**

- Composite varchar PK (`TemplateKey` + `StoreNumber`) rather than a surrogate/int key — typical of Liberty's legacy schema conventions.
- `SecondPagePrinter` is a bare `int` with no declared/inferred reference to a printer or device table — its target domain is unconfirmed.
- Not ETL-mirrored, so this configuration is invisible to liberty_link_stage/downstream eMed reporting; it is purely operational/local to the Liberty install.

---

## `rxqDataViewLayout`

Rows (RXCS): 77 | Columns: 6 | PK: `cDataViewLayoutId` | ETL-mirrored into liberty_link_stage: no

**Purpose** — Stores named, saved UI grid/view layouts for the Liberty pharmacy application: each row has a `ViewName`, a `Layout` blob (varchar(max) — likely serialized column/sort/filter configuration for a data grid, inferred), a validity flag `IsValid`, a `DataViewType` code classifying which screen/view the layout applies to, and an `IconIndex` for UI display. This is an application-configuration table (client UI state), not a clinical/operational record — it has no inferred relationships to any patient, order, or Rx table. (inferred)

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cDataViewLayoutId | int | NO | PK | identity |
| ViewName | varchar(50) | YES | | |
| Layout | varchar(max) | YES | | |
| IsValid | bit | YES | | sampled values: `null` (77) — all 77 sampled rows are NULL |
| DataViewType | int | YES | | sampled values: 1 (67), 4 (6), 3 (3), 5 (1) — coded view-type domain |
| IconIndex | int | YES | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

**Indexes** — none declared.

**Gotchas**
- `IsValid` is entirely NULL across all sampled rows despite being a bit flag — likely unused/vestigial or always defaults to "valid" via application logic rather than the column value (inferred).
- `Layout` is unbounded varchar(max) holding what is presumably serialized layout markup/JSON/XML — content and format not verifiable from metadata alone.
- `DataViewType` has no lookup/reference table backing it (no FK, no inferred relationship) — its 4 observed codes (1/3/4/5) are meaningful only to application code; treat as an opaque enum.
- No indexes beyond the PK — table is small (77 rows) and read via `cDataViewLayoutId` or full scan by the app, not a join target.

---

## `rxqPif`

Rows: 60 (RXCS) | Columns: 6 | PK: `KeyName`, `KeySequence` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores a small generic key/value parameter buffer — one row per (`KeyName`, `KeySequence`) pair holding a single string `ValueBuffer` — consistent with a system-configuration or "Pharmacy Information File" (PIF) settings table (inferred). All 60 sampled rows have `IsValid = true`, suggesting an active/soft-delete flag rather than a status enum (inferred). No columns reference other tables (`implicit_ref` is null everywhere), and no relationships were inferred, consistent with this being a standalone settings store rather than a transactional/clinical table.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cPifId | int | NOT NULL | | identity |
| KeyName | varchar(50) | NOT NULL | PK | parameter name/category |
| KeySequence | varchar(50) | NOT NULL | PK | sub-key/ordinal within KeyName (varchar, not numeric — see Gotchas) |
| ValueBuffer | varchar(50) | NULL | | the stored parameter value |
| LastModified | datetime | NULL | | |
| IsValid | bit | NULL | | sampled values: `true` (count 60) — all sampled rows valid; no `false` observed |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none.
- **Inbound (inferred):** none.

No naming-based edges were inferred to or from `rxqPif`; it appears isolated from the rest of the schema in this extract.

**Indexes**

None reported (no indexes beyond the implicit PK constraint on `KeyName`, `KeySequence`).

**Gotchas**

- `KeySequence` is `varchar(50)` despite its name suggesting an ordinal/sequence number — likely stores composite or non-numeric sub-key identifiers (inferred); don't assume it sorts or increments numerically.
- Composite PK on two varchar columns with no surrogate uniqueness enforced elsewhere besides `cPifId` identity, which is not part of the PK — `cPifId` looks like a vestigial/legacy identity column.
- `IsValid` has only one observed value (`true`) across all 60 rows in this sample; its `false` semantics (if any) are unconfirmed.
- Not ETL-mirrored — this table is configuration/internal to the Liberty pharmacy system, not part of the eMed-facing data pipeline.

---

## `rxqSettings`

Rows (RXCS): 955 | Columns: 3 | PK: `SettingKey`, `UserId` (composite) | ETL-mirrored into liberty_link_stage: no

**Purpose** — A generic per-user key/value settings store: `SettingKey` + `UserId` form the composite primary key, and `Setting` (varchar(max)) holds an arbitrary value/blob for that key (inferred). This shape is typical of an application preferences/config table in a Liberty-style client — e.g. saved UI state, last-used filter, or workstation preference per user — but no column naming or FK evidence ties it to a specific feature area (inferred). `UserId` is varchar(50), not a numeric FK-style identifier, so it is not confirmed to reference a specific `rxqUser`-style table (no inferred_relationships were detected for this table).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| SettingKey | varchar(200) | NO | PK | Part of composite key; likely a namespaced setting name (inferred) |
| UserId | varchar(50) | NO | PK | Part of composite key; varchar, not a numeric FK — no implicit_ref detected |
| Setting | varchar(max) | YES | | Value payload for the key; no default, nullable |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no inferred_relationships were found for this table (UserId did not resolve to a validated parent-key match).
- **Inbound (inferred):** none — no other table's columns were inferred to reference `rxqSettings`.

**Indexes** — none reported beyond the primary key.

**Gotchas**
- `UserId` is a varchar(50), not an integer — inconsistent with typical numeric user-ID keys elsewhere in Liberty; combined with the absence of any inferred/declared relationship, its true parent table (if any) cannot be confirmed from metadata alone.
- `Setting` is untyped varchar(max) — the table's semantics are entirely determined by application code, not the schema; do not assume a single value format across rows.
- Not ETL-mirrored, so this table's contents are invisible to liberty_link_stage/eMed reporting — purely a Liberty client-side config store.

---
