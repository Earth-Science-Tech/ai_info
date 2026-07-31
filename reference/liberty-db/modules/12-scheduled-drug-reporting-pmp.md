# Liberty schema — Scheduled-Drug Reporting & PMP

Controlled/scheduled-substance state reporting — report setup, segments, fields and NDC scope with run history and log — plus the PMP gateway submission audit.

> Part of the [Liberty/RxQ schema reference](../README.md). Liberty declares **no foreign-key constraints** (verified via `sys.foreign_keys`), so all relationships shown are **inferred from column naming and then data-validated** by referential match rate — each is tagged high / medium / low / no-data / unvalidated confidence. Row counts and sampled enum values are from the RXCS instance (point-in-time); the schema itself is identical across the rxcs / mmed / mdvo tenants.

**Tables in this module (7):** [`rxqScheduleDrugReportHistory`](#rxqscheduledrugreporthistory) · [`rxqScheduleDrugReportLog`](#rxqscheduledrugreportlog) · [`rxqScheduleDrugReportField`](#rxqscheduledrugreportfield) · [`rxqScheduleDrugReportSetup`](#rxqscheduledrugreportsetup) · [`rxqScheduleDrugReportSegment`](#rxqscheduledrugreportsegment) · [`rxqScheduleDrugReportNDC`](#rxqscheduledrugreportndc) · [`rxqPmpGatewayAudit`](#rxqpmpgatewayaudit)

---

## `rxqScheduleDrugReportHistory`

Rows (RXCS): 22,303 · Columns: 10 · PK: `Id` · ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores a historical log of generated scheduled/controlled-drug regulatory report submissions, one row per report run — with the report's coverage window (`DateStart`/`DateEnd`), the time it was processed (`DateProcessed`), a `Submitted` flag, and the report's full contents inline in `EntireFile` (inferred: likely a state PDMP/ARCOS-style controlled-substance reporting export, given "ScheduleDrug" naming and the presence of `State`/`StoreNumber` scoping). `IsZeroReport` suggests the report format supports submitting a "zero activity" report when no reportable schedule-drug transactions occurred in the window (inferred). No FK-shaped columns exist to link this back to individual dispense/prescription rows — it records report-level metadata only, not line-item detail.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| Id | int | NO | PK | identity |
| State | varchar(50) | YES | | state code the report was generated/submitted for (inferred; no sampled values available) |
| DateProcessed | datetime | YES | | timestamp the report was generated/run |
| DateStart | datetime | YES | | start of report's coverage window |
| DateEnd | datetime | YES | | end of report's coverage window |
| Submitted | bit | YES | | whether the report was submitted (to the state/regulator, inferred); no sampled values available |
| IsActive | bit | YES | | sampled values: `true` (22,303/22,303 — i.e. every row in the table has IsActive = true; no false rows observed) |
| EntireFile | nvarchar(max) | YES | | full report payload/content stored inline (large-object column) |
| StoreNumber | varchar(50) | YES | | store/location identifier the report pertains to |
| IsZeroReport | bit | YES | | flags a "no activity" report; no sampled values available |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no columns with an implicit reference were detected (naming-based inference found no candidate parent tables for `State`/`StoreNumber`/etc.).
- **Inbound (inferred):** none — no other table's columns were inferred to reference this table.

**Indexes**
- `NonClusteredIndex-20180404-160424` (non-unique) on (`State`, `DateStart`, `DateEnd`) — supports lookup of report history by state and coverage window, consistent with per-state periodic regulatory report retrieval.

**Gotchas**
- `EntireFile` is an unbounded `nvarchar(max)` blob column — full report content stored directly in the row; large-scan/export queries against this table should project it out unless the payload is actually needed.
- Every sampled row has `IsActive = true` (100% of 22,303 rows) — no observed `false` values, so it's unclear from data alone whether/how deactivation is used; treat as an unconfirmed enum domain of effectively one value.
- No inferred relationships in or out — this table appears isolated from the rest of the schema by naming convention; joins to patient/store/drug entities (if any) would have to go through `StoreNumber`/`State` values matched at the application layer, not a documented key.
- `Submitted` and `IsZeroReport` have no sampled values in this extract; their true value domains (bit flags, presumably 0/1) are unconfirmed here.

---

## `rxqScheduleDrugReportLog`

Rows (RXCS): 12,094 | Columns: 10 | PK: `id` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores a log of scheduled-drug (controlled-substance) reporting events tied to individual script fills, recording when and how a fill was reported (`SendDate`, `SendType`, `State`) along with the dispense date and a raw report payload (`ReportRecord`). This is consistent with state Prescription Drug Monitoring Program (PDMP) reporting infrastructure common to pharmacy systems, where every dispense of a scheduled/controlled substance must be transmitted to a state or third-party reporting service (inferred — grounded in the `SendDate`/`SendType`/`State`/`DateDispensed`/`ReportRecord` columns and the table name itself). `HistoryId` and `PartialFillNumber` suggest linkage to a specific dispense/fill history event and partial-fill tracking, respectively (inferred, no validated relationship data for `HistoryId`). Almost every row (99.64%) resolves back to a real `rxqScriptBase.ScriptNumber`, confirming this log is fill-level and script-scoped.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| id | nvarchar(50) | NO | PK | |
| ScriptNumber | int | YES | → rxqScriptBase | |
| RefillNumber | int | YES | | |
| SendDate | datetime | YES | | |
| SendType | int | YES | | Coded domain (sampled): `0` (7,803), `1` (2,891), `2` (1,400) |
| State | nvarchar(50) | YES | | |
| DateDispensed | datetime | YES | | |
| HistoryId | int | YES | | |
| ReportRecord | nvarchar(max) | YES | | Raw report payload/body |
| PartialFillNumber | int | YES | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**
  - `ScriptNumber` → `rxqScriptBase` — inferred, **high** confidence (99.64% referential match, 12,094 non-null values checked, 43 orphans, not sampled).
- **Inbound (inferred)**
  - none

These edges are inferred purely from column naming and then data-validated against actual parent-table values — they are not enforced database constraints, so orphan rows (here, 43 `ScriptNumber` values with no matching `rxqScriptBase` row) are possible and observed.

**Indexes**

- `NonClusteredIndex-20180404-153810` (non-unique) on (`ScriptNumber`, `RefillNumber`, `State`) — supports lookup of a script's report-log entries by refill and reporting state, consistent with re-checking/resending PDMP status per refill.

**Gotchas**

- PK `id` is `nvarchar(50)` rather than an integer identity — likely a GUID or composite string key, not a natural surrogate.
- `State` here is ambiguous: given no lookup values were sampled and its co-indexing with `ScriptNumber`/`RefillNumber`, it more plausibly denotes a *report/send status* (e.g., success/failure/pending) than a US state abbreviation — but this cannot be confirmed without sampled values (flag for follow-up).
- `HistoryId` has no validated inferred relationship (no candidate parent table matched), so its target is unknown despite the naming suggesting a link to a dispense-history table.
- Not ETL-mirrored into liberty_link_stage — any eMed-side reporting/compliance view must query Liberty directly rather than the mirror.

---

## `rxqScheduleDrugReportField`

Rows (RXCS): 986 | Columns: 10 | PK: `id` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores field-definition metadata for a "Schedule Drug Report" builder — one row per configurable report field/column, grouped by `SegmentId` and ordered by `Position` (inferred). `Description` is a human-readable label, `Formula` (varchar(max)) holds the field's computation/expression, `DefaultValue` and `FormulaOptions` capture configurable options for that field, and `UserEditable`/`Enabled` flags govern whether the field is shown/editable in the UI (inferred). `SelectedFormulaOption` is almost universally `0` across sampled rows, suggesting most fields use a single default formula variant with only rare overrides. Likely powers a scheduled-drug (controlled-substance) reporting screen where pharmacy admins configure which fields/columns appear on the report and how each is calculated (inferred — no direct evidence of "scheduled/controlled substance" beyond the table name).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| id | int | NO | PK | identity |
| SegmentId | int | YES | | groups fields into a report segment/section (inferred); no validated FK target |
| Position | int | YES | | display/sort order within segment (inferred) |
| Description | varchar(50) | YES | | human-readable field label |
| Enabled | bit | YES | | whether the field is active/shown (inferred) |
| Formula | varchar(max) | YES | | computation/expression definition for the field |
| DefaultValue | varchar(50) | YES | | default value applied if no formula/user override |
| FormulaOptions | varchar(max) | YES | | serialized options/parameters for the formula |
| UserEditable | bit | YES | | whether end users can edit this field (inferred) |
| SelectedFormulaOption | int | YES | | sampled values: `0` (985 rows), `-1` (1 row) — coded index into `FormulaOptions`; `-1` likely means "none selected" (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

No naming-based candidate relationships were detected for this table (e.g. `SegmentId` did not resolve to a validated parent key), so all relational context above (segment grouping, report ownership) is inferred from column semantics only, not from cross-table evidence.

**Indexes**

None defined (empty index list).

**Gotchas**

- Zero declared and zero inferred relationships — `SegmentId` looks like it should reference a parent "report segment/definition" table, but no such edge was detected/validated in this extract; treat any segment-to-report linkage as unconfirmed.
- Not ETL-mirrored to liberty_link_stage — this table is configuration/metadata for Liberty's own reporting UI, not operational pharmacy data, and is invisible to eMed's downstream systems.
- `SelectedFormulaOption` is near-constant (985/986 rows = `0`); the single `-1` outlier is the only signal that the column is meaningfully used at all — don't assume it's dead/unused just because it's low-cardinality.

---

## `rxqScheduleDrugReportSetup`

Rows (RXCS): 88 | Columns: 114 | PK: `id` | ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores per-state (and per-submission-profile) configuration for ASAP/PDMP (Prescription Drug Monitoring Program) controlled-substance reporting — one row per state/jurisdiction reporting setup (`StateName`, `StateAbbreviation`, `StateGovernmentBody`, `StateIdentifier`, `StateBin`, `StateVersionNumber`). Columns capture the ASAP transaction format version (`ASAPFormat`), submission transport (`SubmissionType`, `SFTPAddress`/`SFTPUsername`/`SFTPPassword`/`SFTPDirectory`/`SFTPEncryptionType`/`SFTPPrivateKeyFile`/`SFTPPrivateKeyPassword`/`SFTPUseTempfile`, `PortNumberOverride`), file/export mechanics (`DefaultFilenameFormat`, `DefaultFilenameExtension`, `DefaultFilePath`, `ZipSubmissionFile`, `ZipFilePassword`, `CustomFormat`, `TemplateType`, `ZeroReportTemplate`), a large bank of per-field include/require toggles controlling exactly which ASAP segments/fields get populated in the outbound report (store NPI/DEA/NABP/State ID, doctor NPI/DEA/State ID/DEA-suffix, patient DL/SSN/military ID/telephone/gender/passport/unique-system-ID, RPh initials, compound ingredient/NDC handling, etc.), and which drug schedules to include (`SubmitSchedule2`-`5`, `SubmitSelectedNonscheduled`, `SubmitAllNonscheduled`, `ExcludeOTCDrugs`). This is pharmacy-side configuration for state PDMP / controlled-substance reporting jobs, most likely driving a scheduled/AutoRun (`AutoRun`, `SendAutorunSuccessNotificationEmail`) export process (inferred — no direct table/job reference present in this table's columns).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| id | int | NO | PK | identity |
| StateName | nvarchar(50) | YES | | |
| StateAbbreviation | nvarchar(2) | YES | | |
| StateGovernmentBody | nvarchar(50) | YES | | |
| ASAPFormat | int | YES | | sampled values: 4 (65), 0 (16), 5 (7) |
| SubmissionType | nvarchar(50) | YES | | |
| SFTPAddress | nvarchar(50) | YES | | |
| SFTPUsername | nvarchar(50) | YES | | |
| SFTPPassword | nvarchar(50) | YES | | plaintext-looking credential column |
| RegKey | nvarchar(50) | YES | | |
| SubmissionCount | int | YES | | |
| PortNumberOverride | int | YES | | |
| IncludeNursingHomes | bit | YES | | |
| SubmitStoreNPI | bit | YES | | |
| SubmitStoreDEA | bit | YES | | |
| SubmitStoreNABP | bit | YES | | |
| SubmitStoreStateID | bit | YES | | sampled: false (83), true (5) |
| SubmitDoctorNPI | bit | YES | | |
| SubmitDoctorDEA | bit | YES | | |
| SubmitDoctorStateID | bit | YES | | sampled: false (56), true (32) |
| SubmitPatientDL | bit | YES | | |
| SubmitPatientSSN | bit | YES | | |
| SubmitPatientMilitaryID | bit | YES | | |
| SubmitPatientTelephone | bit | YES | | |
| SubmitPatientGenderAsMF | bit | YES | | |
| SubmitScriptTriplicate | bit | YES | | |
| SubmitAIRSegment | bit | YES | | |
| SubmitRPHInitials | bit | YES | | |
| SubmitNinesForCompoundMainNDC | bit | YES | | |
| SubmitMainIngredientForCompoundNDC | bit | YES | | |
| SubmitIngredientsForCompound | bit | YES | | |
| SubmitScriptPartialFill | bit | YES | | |
| DefaultFilenameFormat | nvarchar(50) | YES | | |
| DefaultFilenameExtension | nvarchar(50) | YES | | |
| DefaultFilePath | nvarchar(50) | YES | | |
| RequirePatientID | bit | YES | | |
| RequirePatientAddress | bit | YES | | |
| RequirePatientBirthDate | bit | YES | | |
| RequirePatientTelephoneNumber | bit | YES | | |
| RequirePatientGender | bit | YES | | |
| RequireDoctorDEA | bit | YES | | |
| RequireDoctorNPI | bit | YES | | |
| RequireDoctorStateID | bit | YES | | sampled: false (87), true (1) |
| StateIdentifier | nvarchar(50) | YES | | |
| StateBin | nvarchar(50) | YES | | |
| StateVersionNumber | nvarchar(50) | YES | | |
| CustomFormat | bit | YES | | sampled: true (71), false (17) |
| SFTPDirectory | varchar(50) | YES | | |
| SubmitStoreUsernameIS01 | bit | YES | | |
| SubmitStoreTelephoneIS01 | bit | YES | | |
| SubmitStoreTelephoneIS03 | bit | YES | | |
| SubmitCompound06Qualifier | bit | YES | | |
| SubmitPatientIDInfoInAIR | bit | YES | | |
| SubmitDeliveryForPatientIDInAIR | bit | YES | | |
| SubmitRxOrigin | bit | YES | | sampled: true (75), false (13) |
| SubmitSchedule2 | bit | YES | | sampled: true (88) — always true in sample |
| SubmitSchedule3 | bit | YES | | sampled: true (87), false (1) |
| SubmitSchedule4 | bit | YES | | sampled: true (86), false (2) |
| SubmitSchedule5 | bit | YES | | sampled: true (73), false (15) |
| SubmitSelectedNonscheduled | bit | YES | | sampled: true (86), false (2) |
| ZeroReportTemplate | varchar(max) | YES | | |
| SubmitTriplicateAIR02 | bit | YES | | |
| SubmitBlankTriplicateOverride | varchar(50) | YES | | |
| SubmitAIR02 | varchar(50) | YES | | |
| SubmitBlankDSP01 | bit | YES | | |
| SubmitPAT01 | bit | YES | | |
| SFTPUseTempfile | bit | YES | | |
| SubmitPatientPassport | bit | YES | | |
| UseAdjustedSegmentCount | bit | YES | | |
| LargeUniqueField | bit | YES | | |
| SubmitDateSold | bit | YES | | |
| OverridePHA11 | bit | YES | | |
| OverridePHA11Value | nvarchar(max) | YES | | |
| SubmitPharmacistNPI | bit | YES | | |
| SubmitRxReferenceNumberDSP20 | bit | YES | | |
| SubmitRxOrderNumberDSP21 | bit | YES | | |
| OverrideOriginC2Escript | bit | YES | | sampled: false (48), true (40) |
| ZipSubmissionFile | bit | YES | | |
| ZipFilePassword | nvarchar(max) | YES | | plaintext-looking credential column |
| SubmitChangeRecords | bit | YES | | |
| SubmitOfficeUseOnlyScripts | bit | YES | | |
| RequireSchedule2Triplicate | bit | YES | | sampled: false (87), true (1) |
| RequireSchedule3Triplicate | bit | YES | | sampled: false (87), true (1) |
| RequireSchedule4Triplicate | bit | YES | | sampled: false (87), true (1) |
| RequireSchedule5Triplicate | bit | YES | | sampled: false (87), true (1) |
| SubmitPharmacistStateId | bit | YES | | sampled: false (70), true (18) |
| SubmitIS01Override | nvarchar(max) | YES | | |
| SubmitPharmacistPhone | bit | YES | | |
| SendAutorunSuccessNotificationEmail | bit | YES | | |
| SubmitAllNonscheduled | bit | YES | | sampled: false (85), true (3) |
| ExcludeOTCDrugs | bit | YES | | |
| SendVoidRecordWhenDateDispenseChanges | bit | YES | | |
| SFTPEncryptionType | int | YES | | sampled: 1 (81), 0 (7) |
| AutoRun | bit | YES | | |
| ReportSubmissionType | int | YES | | sampled: 0 (86), 1 (2) |
| SubmitPatientUniqueSystemID | bit | YES | | |
| PartialMode | int | YES | | sampled: 0 (86), 3 (2) |
| RequireOpoidTreatmentType | bit | YES | | sampled: false (85), true (3) |
| SubmitDoctorDEASuffix | bit | YES | | |
| SubmitNonOpioidsAsOther | bit | YES | | |
| UniqueSystemIDType | int | YES | | sampled: 1 (50), 0 (38) |
| SFTPPrivateKeyFile | varchar(max) | YES | | |
| SFTPPrivateKeyPassword | varchar(50) | YES | | plaintext-looking credential column |
| TemplateType | int | YES | | sampled: 1 (54), 0 (34) |
| SqlVersionMajor | int | YES | | |
| SqlVersionMinor | int | YES | | |
| ExcludeScriptsNotScanned | bit | YES | | |
| SwapDoctorDEAXDEA | bit | YES | | |
| GUIDUniqueField | bit | YES | | |
| OverrideOriginC35Escript | bit | YES | | sampled: false (49), true (39) |
| SubmitLTCAIR0708 | bit | YES | | |
| CustomWinscpServerSetting | varchar(max) | YES | | |
| UniqueSystemIdJurisdictionPAT01 | int | YES | | |
| OverrideOriginCode05To06 | bit | YES | | sampled: false (56), null (32) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**: none — no `inferred_relationships` entries were detected for this table. `StateAbbreviation`/`StateIdentifier`/`StateBin` look naming-wise like they could relate to a state/jurisdiction reference table, but no such inferred edge was surfaced (unconfirmed by naming-inference alone; treat as unvalidated).
- **Inbound (inferred)**: none — no `inferred_referenced_by` entries were detected pointing at this table.

**Indexes**

None reported (no indexes beyond the implicit PK on `id`).

**Gotchas**
- Several columns store what look like plaintext credentials/secrets (`SFTPPassword`, `SFTPPrivateKeyPassword`, `ZipFilePassword`) directly in the table — sensitive if this table is ever replicated or queried broadly.
- `SubmitSchedule2` is `true` for all 88 sampled rows, suggesting Schedule II reporting is effectively mandatory/always-on in practice, unlike Schedule 3-5 which have a handful of `false` outliers.
- `OverrideOriginCode05To06` mixes `false` and `null` (32 rows) rather than `false`/`true` — nulls here likely mean "not configured" rather than a real boolean state, so don't treat this as a clean binary flag.
- Despite `col_count: 114` in the source metadata, only ~110 columns were enumerated in the `columns` array — some columns may be undocumented/truncated in the extract.
- This table is not ETL-mirrored into liberty_link_stage, so eMed-side reporting/analytics has no visibility into pharmacy PDMP-submission configuration.

---

## `rxqScheduleDrugReportSegment`

Rows (RXCS): 68 | Columns: 12 | PK: `id` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores segment/field definitions for scheduled-drug (controlled-substance) report layouts — each row is one field within a report's output format, referencing a parent report setup via `ScheduleDrugReportSetupId` (inferred). Columns like `Segment`, `Position`, `Parent`, `Terminator`, `FieldSeperator`, and `FieldCount` describe how to slice/order/delimit fields when generating a flat-file or fixed-format extract (inferred) — consistent with state PDMP / DEA ARCOS-style scheduled-drug reporting, where pharmacies must submit controlled-substance dispensing data in a state-specified field layout (inferred, general NCPDP/PDMP-reporting knowledge). `Enabled` toggles whether a segment is active; `VisibilityFormula` (varchar(max)) suggests a conditional-inclusion expression evaluated per report generation (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| id | int | NO | PK | identity |
| ScheduleDrugReportSetupId | int | YES | (likely → parent report-setup table, unconfirmed — no inferred_relationships recorded) | sampled values: 71, 67, 60, 5, 83, 73, 52 (counts 9-10 each; coded/grouping domain, not enum) |
| Name | varchar(50) | YES | | |
| Segment | int | YES | | |
| Position | int | YES | | |
| Parent | int | YES | | possible self-referential hierarchy pointer (inferred) |
| Enabled | bit | YES | | |
| Terminator | varchar(50) | YES | | likely field/record terminator string (inferred) |
| FieldSeperator | varchar(50) | YES | | likely delimiter string (inferred); note source spelling "Seperator" |
| FieldCount | int | YES | | |
| Description | varchar(50) | YES | | |
| VisibilityFormula | varchar(max) | YES | | likely conditional-display expression (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none recorded by the extraction (no inferred_relationships entries were captured for this table, despite `ScheduleDrugReportSetupId` being a strong naming candidate for a parent report-setup table — treat as an unconfirmed/weak guess since it was not data-validated).
- **Inbound (inferred):** none.

**Indexes**

None defined on this table.

**Gotchas**

- No indexes at all, including none on `ScheduleDrugReportSetupId` — despite it appearing to be the join key back to a parent report-setup table, there's no supporting index or validated relationship record.
- `ScheduleDrugReportSetupId` values in the lookup sample (71, 67, 60, 5, 83, 73, 52) look like row IDs from another table but the parent table name/relationship was not resolved/validated by extraction — do not assume confidence here.
- `Parent` column name suggests a self-referential tree (segment nesting) but this was also not validated against `id`.
- Not ETL-mirrored — this is report-configuration metadata, not transactional/dispensing data, so it's out of scope for the standard eMed mirror.

---

## `rxqScheduleDrugReportNDC`

Rows (RXCS): 7 | Columns: 6 | PK: `Id` | ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores a small, state-scoped lookup/reference list of NDCs (National Drug Codes) tied to a `LookupType`/`TemplateType`/`ParticipationType` classification, most plausibly used to drive controlled-substance ("scheduled drug") reporting rules per state (inferred — table name and `State` column suggest this feeds state PDMP/scheduled-drug reporting logic, but no relationships or documentation confirm the exact consumer). All 7 sampled rows share `LookupType`=1 and `ParticipationType`=0, with `State` populated for only 2 of 7 rows (OR, KS) and blank for the rest — consistent with a small seed/config table rather than a transactional one (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `Id` | int | NO | PK | identity |
| `NDC` | nvarchar(11) | NO | | drug NDC code, no relationships detected to a drug master table |
| `LookupType` | int | YES | | sampled values: 1 (count 7) |
| `State` | varchar(20) | YES | | sampled values: "" (blank, count 5), "OR" (count 1), "KS" (count 1) |
| `TemplateType` | int | YES | | sampled values: 0 (count 5), 1 (count 2) |
| `ParticipationType` | int | YES | | sampled values: 0 (count 7) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

No naming-based relationships were inferred or data-validated for this table; `NDC` is not linked to any drug master table in the extracted metadata.

**Indexes**
None reported (no indexes beyond the implicit PK).

**Gotchas**
- Extremely small table (7 rows) — likely a static/seed configuration list rather than an operationally-growing table; treat sampled lookup values as close to the full enum domain for this tenant at extraction time, not a statistically representative sample.
- `State` is blank for the majority of rows (5 of 7), so its role as a scoping filter is only partially exercised in this data — unclear if blank means "all states" or "not yet configured" (inferred, unconfirmed).
- No FK-like columns or naming conventions link this table to any other table in the schema (e.g., no `PatientId`, `DrugId`, etc.) — it appears to be a standalone reference table.

---

## `rxqPmpGatewayAudit`

Rows (RXCS): 3,148 | Columns: 9 | PK: `Id` | ETL-mirrored into `liberty_link_stage`: no

**Purpose**

Audit log of PMP (Prescription Monitoring Program) gateway interactions per script/refill — each row captures a `StoreNumber`, `UserId`, `Mode`, `PatientId`, `ScriptNumber`/`RefillNumber`, and `Pharmacist` at a `Datestamp` (inferred: this records controlled-substance state PDMP checks/submissions performed by pharmacy staff, e.g. NCPDP/SureScripts PMP gateway calls, for regulatory compliance). `Mode` (inferred: likely distinguishes query vs. report/submit actions against the PMP gateway, though no sampled values are available to confirm). No lookup values were sampled for any column, so no coded domains can be documented from data.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| Id | bigint | NOT NULL | PK | identity |
| StoreNumber | varchar(2) | NOT NULL | | |
| Datestamp | datetime | NOT NULL | | |
| UserId | varchar(50) | NOT NULL | | |
| Mode | varchar(50) | NOT NULL | | |
| PatientId | varchar(50) | NOT NULL | → rxqPatient | |
| ScriptNumber | int | NULL | → rxqScriptBase | |
| RefillNumber | int | NULL | | |
| Pharmacist | varchar(50) | NULL | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**
  - `PatientId` → `rxqPatient` — inferred, **high** confidence (100.0% referential match, 3,148 non-null values checked, 0 orphans).
  - `ScriptNumber` → `rxqScriptBase` — inferred, **high** confidence (99.9% referential match, 3,110 non-null values checked, 3 orphans).
- **Inbound (inferred)**
  - none

These edges are inferred purely from column naming and then data-validated against the actual parent-table key values (not declared database constraints); treat any low/no-data/unvalidated confidence as an unconfirmed guess (not applicable here — both edges are high confidence).

**Indexes**

- `IX_rxqPmpGateway_ScriptFillDate` (NONCLUSTERED, non-unique) on (`Datestamp`, `ScriptNumber`, `RefillNumber`) — supports lookup of PMP audit activity by fill date and script/refill.
- A duplicate `_dta_`-named tuning index on (`ScriptNumber`, `RefillNumber`, `Datestamp`) mirrors the same access path (auto-generated, same key columns in different order).

**Gotchas**

- `PatientId` and `ScriptNumber` are stored as varchar/int without FK constraints, per the general Liberty schema pattern — referential integrity is enforced only by application logic, not the database.
- 3 of 3,110 non-null `ScriptNumber` values have no match in `rxqScriptBase` (orphaned references) — likely deleted/renumbered scripts or data older than the current `rxqScriptBase` retention.
- No `lookups` data was sampled for `Mode`, so its enum domain (e.g. query type/PMP action type) is undocumented here and should be confirmed by direct query before relying on it in ETL or reporting.
- Not mirrored by ETL into `liberty_link_stage` — this audit trail is not currently available in the downstream eMed data warehouse.

---
