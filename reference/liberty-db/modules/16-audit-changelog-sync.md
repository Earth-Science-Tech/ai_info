# Liberty schema — Audit, Change Logs & Sync

Cross-cutting change-tracking infrastructure — audit-log master/change tables, audit tracking, wide script change-log and script-transaction audit — and the Sync-Framework anchor/scope/config plus schema-version tables.

> Part of the [Liberty/RxQ schema reference](../README.md). Liberty declares **no foreign-key constraints** (verified via `sys.foreign_keys`), so all relationships shown are **inferred from column naming and then data-validated** by referential match rate — each is tagged high / medium / low / no-data / unvalidated confidence. Row counts and sampled enum values are from the RXCS instance (point-in-time); the schema itself is identical across the rxcs / mmed / mdvo tenants.

**Tables in this module (13):** [`rxqAuditLogMaster`](#rxqauditlogmaster) · [`rxqAuditLogChange`](#rxqauditlogchange) · [`rxqAuditLogMasterOperation`](#rxqauditlogmasteroperation) · [`rxqAuditTracking`](#rxqaudittracking) · [`rxqChangeLogEntry`](#rxqchangelogentry) · [`rxqScriptTransactionAudit`](#rxqscripttransactionaudit) · [`Anchor`](#anchor) · [`sync_ScopeTables`](#sync_scopetables) · [`sync_ScopeConfig`](#sync_scopeconfig) · [`sync_config`](#sync_config) · [`sync_ColumnUpdates`](#sync_columnupdates) · [`SYNC_ID`](#sync_id) · [`DB_VERSION`](#db_version)

---

## `rxqAuditLogMaster`

Rows (RXCS): 6,249,384 | Columns: 33 | PK: `id` | ETL-mirrored into liberty_link_stage: no

**Purpose** — A general-purpose audit/change log with one row per logged operation (`operation`, coded via `rxqAuditLogMasterOperation`), timestamped by `modified_date` and attributed to `user_id`. Rather than a single subject-entity column, it carries ~25 optional "which entity was touched" foreign-key-shaped columns (PatientId, doctor_id, drug_id, OrderId, ShipmentId, BatchId, cAddressId, cPhoneNumberId, etc.) plus a free-text `summary` — i.e. it's a wide, sparse polymorphic audit trail where only the columns relevant to a given operation are populated (inferred). At 6.2M rows it is one of the largest tables in the schema, consistent with a per-event log accumulating across the whole pharmacy workflow (dispensing, shipping, patient record edits, compounding, HIPAA acknowledgements, etc.).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| id | int | NOT NULL | PK | identity |
| user_id | varchar(50) | NOT NULL | | |
| operation | smallint | NOT NULL | → rxqAuditLogMasterOperation | coded operation type (validation failed — see Relationships) |
| PatientId | varchar(50) | NULL | → rxqPatient | |
| doctor_id | varchar(50) | NULL | | no implicit_ref detected despite name |
| drug_id | varchar(50) | NULL | | no implicit_ref detected despite name |
| summary | nvarchar(500) | NULL | | free-text description of the logged event |
| modified_date | datetime | NOT NULL | | event timestamp |
| WorkflowItemId | varchar(50) | NULL | | indexed (workflowIdIndexAuditLog) |
| StoreNumber | varchar(50) | NULL | | tenant/store scoping column, appears in 3 composite indexes |
| PriceFormulaId | varchar(50) | NULL | | |
| OrderId | varchar(50) | NULL | | |
| SettingsId | varchar(200) | NULL | | |
| PendingScriptId | varchar(50) | NULL | | |
| cAddressId | varchar(50) | NULL | → rxqAddress | |
| ShipmentId | varchar(50) | NULL | → rxqShipment | |
| ShipmentScriptNumberId | varchar(50) | NULL | | |
| NotesId | varchar(255) | NULL | | |
| AgencyId | nvarchar(max) | NULL | | |
| BatchId | varchar(50) | NULL | → rxqDrugBatch | |
| CompoundIngredientId | varchar(50) | NULL | | |
| DrugCompoundPendingId | int | NULL | | |
| PatientAliasId | int | NULL | | |
| cPhoneNumberId | int | NULL | → rxqPhoneNumber | |
| cPatientHipaaAcknowledgeId | int | NULL | → rxqPatientHipaaAcknowledge | |
| cPatientThirdPartyId | int | NULL | → rxqPatientThirdParty | |
| cPatientPreferencesId | int | NULL | → rxqPatientPreferences | |
| drugCompoundInstructionsID | int | NULL | → rxqDrugCompoundInstructions | |
| cRX365PatientLinkId | int | NULL | → RX365PatientLink | |
| PackageId | int | NULL | | |
| LtcMessageId | int | NULL | | |
| cVendorId | int | NULL | → rxqVendor | |
| cNHPatId | int | NULL | → rxqNHPat | |

No columns appear in `lookups` (no small coded-value domains were sampled for this table beyond `operation`, whose lookup table `rxqAuditLogMasterOperation` could not be validated here).

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)** — all inferred from column naming and then data-validated against the parent table's key:
  - `BatchId` → `rxqDrugBatch` — inferred, **high** confidence (100.0% referential match, sampled)
  - `cPhoneNumberId` → `rxqPhoneNumber` — inferred, **high** confidence (100.0% referential match, sampled)
  - `cPatientThirdPartyId` → `rxqPatientThirdParty` — inferred, **high** confidence (100.0% referential match, sampled)
  - `cNHPatId` → `rxqNHPat` — inferred, **high** confidence (100.0% referential match, sampled)
  - `ShipmentId` → `rxqShipment` (join col `id`) — inferred, **high** confidence (99.93% referential match, 141 orphans out of 200,000 sampled non-null, sampled)
  - `cAddressId` → `rxqAddress` — inferred, **high** confidence (99.83% referential match, 336 orphans out of 200,000 sampled non-null, sampled)
  - `PatientId` → `rxqPatient` — inferred, **high** confidence (97.22% referential match, 5,551 orphans out of 200,000 sampled non-null, sampled)
  - `cPatientHipaaAcknowledgeId` → `rxqPatientHipaaAcknowledge` — inferred, **high** confidence (97.06% referential match, 2,073 orphans out of 70,490 sampled non-null, sampled)
  - `drugCompoundInstructionsID` → `rxqDrugCompoundInstructions` — inferred, **low** confidence (only 4.21% referential match, 19,323 orphans out of 20,173 sampled non-null, sampled) — weak/unconfirmed, treat naming similarity as coincidental or the column as reused for another purpose
  - `cPatientPreferencesId` → `rxqPatientPreferences` — inferred, **low** confidence (0.0% referential match, 171,537 orphans out of 171,538 sampled non-null, sampled) — essentially unconfirmed; the values likely reference something other than `rxqPatientPreferences.cPatientPreferencesId`
  - `operation` → `rxqAuditLogMasterOperation` — inferred, **unvalidated** (validation query errored: "Conversion failed when converting the varchar value 'Changed' to data type small[int]" — suggests the lookup table's join column is typed/valued inconsistently with this table's `smallint`, or contains non-numeric labels)
  - `cRX365PatientLinkId` → `RX365PatientLink` — inferred, **unvalidated** (parent table empty, not sampled)
  - `cVendorId` → `rxqVendor` — inferred, **no-data** confidence (0 non-null values sampled in this table, sampled=true but nothing to validate)
  - `doctor_id`, `drug_id` — named like foreign keys but no `implicit_ref` was inferred for either; not data-validated, do not assume a link target.

- **Inbound (inferred)** — none (no other table's columns were inferred to reference `rxqAuditLogMaster`).

**Indexes**
- `IX_AuditLogMaster_doctor_id_modified_date_storenumber` (doctor_id, modified_date, StoreNumber) — supports lookups of a doctor's audit history per store over time.
- `IX_AuditLogMaster_drug_id_modified_date_storenumber` (drug_id, modified_date, StoreNumber) — supports drug-scoped audit history per store over time.
- `IX_AuditLogMaster_PatientId_modifieddate_StoreNumber` (PatientId, modified_date, StoreNumber) — supports patient-scoped audit history per store over time; matches the validated `PatientId → rxqPatient` edge.
- `workflowIdIndexAuditLog` (WorkflowItemId) — supports pulling all audit events tied to a given workflow item.

**Gotchas**
- Extremely sparse/polymorphic: ~25 nullable "entity id" columns of which only a handful are populated per row depending on `operation`; do not assume any single column is consistently non-null.
- Nearly all key-shaped columns are `varchar(50)` rather than typed integers/GUIDs (Liberty convention), including `PatientId`, `OrderId`, `ShipmentId`, `BatchId`, etc. — joins require string comparison, and no DB-level constraint enforces referential integrity, so orphans are expected (confirmed non-zero for several high-confidence edges above).
- `operation` is `smallint` but the paired lookup table apparently stores/returns non-numeric text (e.g. `'Changed'`) causing a type-conversion failure during validation — treat the `operation` → `rxqAuditLogMasterOperation` link as unverified until the lookup table's schema is inspected directly.
- `drugCompoundInstructionsID` and `cPatientPreferencesId` have plausible FK-shaped names but very low actual referential match rates (4.2% and 0%) — despite the naming, they likely do NOT reference the tables their names suggest; don't treat these as reliable joins.
- Not mirrored into liberty_link_stage by ETL — any cross-tenant (rxcs/mmed/mdvo) audit analysis must query each Liberty source database directly rather than the eMed mirror.
- `doctor_id` and `drug_id` look like FKs by naming convention but had no inferred_relationship recorded at all — treat as unconfirmed even at the naming-inference stage.

---

## `rxqAuditLogChange`

Rows (RXCS): 18,125,646 | Columns: 8 | PK: `Id` | ETL-mirrored into liberty_link_stage: no

**Purpose** — A generic field-level change log: each row records one property change (`property`, `old_value` → `new_value`) tied to a `master_id` and an optional `parent_id`, plus a `specific_operation` code and a `summary` string (inferred: a human-readable description of the change event). The very large row count (18.1M) relative to column count (8) indicates a fine-grained, high-volume audit trail spanning many parent record types across the pharmacy system (inferred). No column naming pattern (e.g. `PatientId`, `rxNum`) ties `master_id`/`parent_id` to a specific parent table, so which entity each row audits cannot be determined from this table alone (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| Id | int | NO | PK | identity |
| master_id | int | NO | | clustered index key (`auditchangesmaster`); likely groups changes belonging to one audit "master" record (inferred) |
| property | varchar(256) | YES | | name of the field/property that changed (inferred) |
| specific_operation | int | NO | | coded operation type; part of composite index `IDX_AuditLogChange_SpecificOperationParentId_IdValues`; no lookup values sampled — domain unknown |
| old_value | varchar(256) | YES | | pre-change value, free text |
| new_value | varchar(256) | YES | | post-change value, free text |
| parent_id | int | YES | | indexed via `auditchangeparent`; likely FK to the parent entity being audited, but not resolvable to a specific table from naming alone (inferred) |
| summary | varchar(256) | YES | | free-text description of the change (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no inferred_relationships were detected/validated for this table's columns (`master_id`, `parent_id` did not match any naming/data pattern to a parent table).
- **Inbound (inferred):** none — no other table's columns were data-validated as referencing this table.

**Indexes**
- `auditchangesmaster` (CLUSTERED, `master_id`) — primary access path for pulling all change rows for a given master record.
- `auditchangeparent` (NONCLUSTERED, `parent_id`) — secondary access path by parent entity.
- `IDX_AuditLogChange_SpecificOperationParentId_IdValues` (NONCLUSTERED, `specific_operation, parent_id`, includes `Id, property, old_value, new_value`) — covering index for filtering by operation type + parent, suggesting this table is queried heavily by "show me changes of type X for parent Y" (inferred).

**Gotchas**
- `master_id` and `parent_id` have no discoverable inferred relationships (no naming/data match to any known table) — do not assume they map to a specific entity without further investigation (e.g. checking Liberty app code or a data dictionary).
- `specific_operation` is an unlabeled integer code with no sampled lookup values in this extract — treat its meaning as unknown rather than guessing.
- Not mirrored by ETL into liberty_link_stage, so this audit data is unavailable to eMed-side reporting/queries; any investigation needing this history must query the Liberty/RxQ source DB directly.
- Extremely high row count (18M+) — full-table scans should be avoided; always filter via `master_id`, `parent_id`, or the composite index columns.

---

## `rxqAuditLogMasterOperation`

Rows (RXCS): 6 | Columns: 2 | PK: `id`, `operation` (composite) | ETL-mirrored into `liberty_link_stage`: no

**Purpose**

A tiny lookup/reference table enumerating the set of valid "operation" codes used by Liberty's audit-logging subsystem (inferred, from table name and its role as the referenced side of several `Operation`-named columns in other tables). It appears to define the allowed operation values (e.g. insert/update/delete-type actions) that populate the `operation` column of `rxqAuditLogMaster` and similar log/rule tables (inferred — no data values were sampled to confirm the actual codes). Not mirrored by ETL, consistent with it being static reference metadata rather than transactional data.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `id` | int | NOT NULL | PK | part of composite key with `operation` |
| `operation` | varchar(20) | NOT NULL | PK | part of composite key with `id`; no sampled values available (lookups empty for this column) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none

- **Inbound (inferred):**
  - `rxqAuditLogMaster.operation` → this table — inferred, **unvalidated** confidence (parent/data not validated, no match rate available)
  - `rxqDrugInventoryLogMaster.Operation` → this table — inferred, **unvalidated** confidence (no match rate available)
  - `rxqDrugInventoryLogOperation.operation` → this table — inferred, **low** confidence (0.0% referential match)
  - `rxqRuleFilter.Operation` → this table — inferred, **unvalidated** confidence (no match rate available)

**Indexes**

None declared.

**Gotchas**

- Composite PK (`id` + `operation`) is unusual for a small code table — suggests `operation` values may repeat across different `id` groupings, or this is scoped/partitioned reference data rather than a flat enum.
- No lookup values were captured for `operation` despite it being a short varchar coded column, so its actual domain (e.g. specific operation-type strings) is unknown from this extract.
- The one validated inbound edge (`rxqDrugInventoryLogOperation.operation`) shows a 0% match rate (low confidence) — despite the naming similarity, that column's values do not actually reference this table's rows, indicating the relationship may be coincidental naming rather than a real join path.
- The other three inbound edges are unvalidated (parent/child data insufficient to check), so none of the apparent relationships to this table should be treated as confirmed.

---

## `rxqAuditTracking`

Rows (RXCS): 227,864 | Columns: 10 | PK: `id` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Generic before/after change-audit log: each row records an `originalValue` → `newValue` change against some entity, tagged by a `trackingType` code, an `origin`/`originId` pointer, `dateChanged`, and free-text `userInfo`/`description` (inferred). `itemId` is a varchar(15) rather than an int, suggesting it identifies the changed record by a business/formatted key (e.g. an Rx or item number) rather than a direct FK to a single table's identity column (inferred). No FK constraints or inferable naming-matched relationships were found — `originId`/`itemId` appear to be polymorphic pointers whose target table is determined by `origin`/`trackingType` rather than a fixed parent table (inferred). Not mirrored by ETL into eMed, so this audit trail is Liberty-internal only and not queryable from liberty_link_stage.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| id | int | NO | PK | identity |
| itemId | nvarchar(15) | YES | | indexed (non-clustered); likely a business key, not numeric identity |
| originalValue | nvarchar(max) | YES | | pre-change value (free text) |
| newValue | nvarchar(max) | YES | | post-change value (free text) |
| origin | nvarchar(max) | YES | | free-text source/module label (inferred) |
| dateChanged | datetime | YES | | indexed (non-clustered) |
| trackingType | int | YES | | indexed (non-clustered); coded domain — sampled values: 12 (81,304), 1 (77,741), 6 (58,452), 8 (8,695), 19 (1,592), 10 (66), 18 (12), 3 (2). Meaning of each code not documented in metadata. |
| userInfo | nvarchar(max) | YES | | free-text user/session identifier (inferred) |
| description | nvarchar(max) | YES | | free-text change description |
| originId | int | YES | | indexed (non-clustered); coded/pointer domain — sampled values dominated by 0 (146,560), then a run of IDs in the 8698-8735 range each with ~2,780-2,830 occurrences (sampled, not exhaustive) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no naming-matched, data-validated outbound edges were found for `itemId`, `originId`, or any other column.
- **Inbound (inferred):** none — no other table's columns were found to reference `rxqAuditTracking.id`.

Both `itemId` and `originId` look like they should reference something (a changed item / an originating record), but no inferred_relationships were detected or validated — treat any target table as unconfirmed until checked manually against `origin`/`trackingType` semantics.

**Indexes**

- `dateChanged` (NONCLUSTERED, key: dateChanged) — supports time-range audit queries.
- `itemId` (NONCLUSTERED, key: itemId) — supports lookup of all audit rows for a given item/business key.
- `NonClusteredIndex-originId` (NONCLUSTERED, key: originId) — supports lookup by origin pointer.
- `trackingType` (NONCLUSTERED, key: trackingType) — supports filtering by change-type code.

**Gotchas**

- `itemId` is a varchar(15), not an int — cannot be joined directly to most Liberty tables' int identity PKs; likely holds a formatted/business identifier.
- `originId` and `trackingType` are opaque integer codes with no lookup/decode table found in this extract — their concentration of specific IDs (8698-8735 range) suggests a burst of changes tied to a narrow set of records, but the entity they belong to is unconfirmed.
- No declared or inferred relationships at all — this table is effectively an unlinked audit sink from a schema-analysis standpoint; correlating rows to source records requires out-of-band knowledge of `origin`/`trackingType` code meanings.
- Not ETL-mirrored, so none of this audit history is available in eMed/liberty_link_stage today.

---

## `rxqChangeLogEntry`

Rows (RXCS): 1,471,629 | Columns: 127 | PK: `(ScriptNumber, RefillNumber, ChangeDate)` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Append-only audit/change log for prescription (script) records — one row per logged change event against a `ScriptNumber`/`RefillNumber` combination, timestamped by `ChangeDate` and attributed to a `PharmacistInitials`/`LoggedInUser` (inferred). The `Base*` column family (`BaseDrugKey`, `BaseDoctorId`, `BaseScriptStatus`, `BaseRefillsAuthorized`, etc.) appears to snapshot the script/refill state at the moment of change, while the `Trans*` column family (`TransCost`, `TransCopay`, `TransDaysSupply`, `TransNCPDC*`, `TransDispenseAsWritten`, etc.) captures a full NCPDC-style third-party claim/billing transaction snapshot tied to that change (inferred, given the NCPDC-named fields mirror standard pharmacy claim segments). `TypeCode` and `ChangeDescription` likely classify the kind of change/event (inferred; no sampled values available to confirm the domain). `IsValid` suggests soft-invalidation of log entries rather than hard deletes (inferred). This table has no declared or inferred relationships pointing at it from elsewhere in the schema, consistent with it being a terminal audit trail rather than an operational parent table.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cChangeLogEntryId | int | NO | | identity |
| ScriptNumber | int | NO | PK, → rxqScriptBase | |
| RefillNumber | int | NO | PK | |
| ChangeDate | datetime | NO | PK | |
| PharmacistInitials | varchar(50) | YES | | |
| LoggedInUser | varchar(50) | YES | | |
| ChangeDescription | varchar(200) | YES | | |
| TypeCode | varchar(50) | YES | | |
| BaseScriptNumber | int | YES | | |
| BaseLastRefillNumber | int | YES | | |
| PatientId | varchar(50) | YES | → rxqPatient | |
| BaseDrugKey | varchar(50) | YES | | |
| BaseDrugSchedule | varchar(50) | YES | | |
| BaseDateWritten | date | YES | | |
| BaseDateLastFilled1 | date | YES | | |
| BaseDateLastFilled2 | date | YES | | |
| BaseDateLastFilled3 | date | YES | | |
| BaseDateLastFilled4 | date | YES | | |
| BaseDoctorId | varchar(50) | YES | | |
| BaseFullDispenseQuantity | varchar(50) | YES | | |
| BaseAuthorizedQuantity | varchar(50) | YES | | |
| BaseAvailableQuantity | varchar(50) | YES | | |
| BaseRefillsAuthorized | int | YES | | |
| BaseNumberOfLabels | int | YES | | |
| BaseScriptStatus | int | YES | | |
| BaseStoreNumber | varchar(50) | YES | | |
| BaseCvtFrom | int | YES | | |
| BaseInjuryDate | date | YES | | |
| BaseOnHold | varchar(50) | YES | | |
| BaseTransferSwitch | varchar(50) | YES | | |
| BaseRefillUntilDate | date | YES | | |
| BaseEScriptTransactionId | int | YES | | |
| TransAdministrativeCharge | varchar(50) | YES | | |
| TransAgency | varchar(50) | YES | | indexed (LibertyAuto_92_91) |
| TransAuthorizationNumber | varchar(50) | YES | | |
| TransAuthorizedBy | varchar(50) | YES | | |
| TransChargeCode | varchar(50) | YES | | |
| TransCopay | varchar(50) | YES | | |
| TransCost | varchar(50) | YES | | |
| TransCostBase | varchar(50) | YES | | |
| TransCountedByUser | varchar(50) | YES | | |
| TransCouponAmount | varchar(50) | YES | | |
| TransCouponNumber | varchar(50) | YES | | |
| TransCouponType | varchar(50) | YES | | |
| TransCpt1 | varchar(50) | YES | | |
| TransCpt2 | varchar(50) | YES | | |
| TransDateDispensed | date | YES | | |
| TransDaysSupply | varchar(50) | YES | | |
| TransDeliveryCharge | varchar(50) | YES | | |
| TransDenialClarification | varchar(50) | YES | | |
| TransDiagnosisCode | varchar(50) | YES | | |
| TransDiscount | varchar(50) | YES | | |
| TransDispenseAsWritten | varchar(50) | YES | | NCPDC DAW code (no sample values present) |
| TransDrugId | varchar(50) | YES | | |
| TransEmergencyCopayCode | varchar(50) | YES | | |
| TransExpirationDate | date | YES | | |
| TransFee | varchar(50) | YES | | |
| TransIcd9Code | varchar(50) | YES | | |
| TransLevelOfService | varchar(50) | YES | | |
| TransLoggedInUser | varchar(50) | YES | | |
| TransLotNumber | varchar(50) | YES | | |
| TransNCPDCAmountDue | varchar(50) | YES | | |
| TransNCPDCBasisOfCost | varchar(50) | YES | | |
| TransNCPDCCustomerLocation | varchar(50) | YES | | |
| TransNCPDCDenialClarification | varchar(50) | YES | | |
| TransNCPDCDispenseAsWritten | varchar(50) | YES | | |
| TransNCPDCDispensingFee | varchar(50) | YES | | |
| TransNCPDCEligabilityClarification | varchar(50) | YES | | |
| TransNCPDCGrossAmountDue | varchar(50) | YES | | |
| TransNCPDCIngredientCost | varchar(50) | YES | | |
| TransNCPDCLevelOfService | varchar(50) | YES | | |
| TransNCPDCOtherPayorAmount | varchar(50) | YES | | |
| TransNCPDCPatientPaidAmount | varchar(50) | YES | | |
| TransNCPDCPriorAuthorizationCode | varchar(50) | YES | | |
| TransNCPDCPriorAuthorizationNumber | varchar(50) | YES | | |
| TransNCPDCSalesTax | varchar(50) | YES | | |
| TransNCPDCUsualCustomaryCharge | varchar(50) | YES | | |
| TransNewDateDone | date | YES | | |
| TransNewScriptNumber | varchar(50) | YES | | |
| TransNursingHome | varchar(50) | YES | | |
| TransOtherCharge | varchar(50) | YES | | |
| TransOtherCoverageCode | varchar(50) | YES | | |
| TransPaidSwitch | varchar(50) | YES | | |
| TransPaid | date | YES | | |
| TransPcnNumber | varchar(50) | YES | | |
| TransPosScanFlag | varchar(50) | YES | | |
| TransPostageCharge | varchar(50) | YES | | |
| TransPrescriptionOrigin | varchar(50) | YES | | |
| TransPriceFormula | varchar(50) | YES | | |
| TransPriceFormulaOriginal | varchar(50) | YES | | |
| TransPrimaryPayorDenialDate | varchar(50) | YES | | stored as varchar despite date semantics |
| TransPrimaryRejectedFlag | varchar(50) | YES | | |
| TransQuantityDispensed | varchar(50) | YES | | |
| TransReferenceNumber | varchar(50) | YES | | |
| TransRefillNumber | varchar(50) | YES | | note: varchar duplicate of PK's int `RefillNumber` |
| TransRequestedACQ | varchar(50) | YES | | |
| TransRequestedAWP | varchar(50) | YES | | |
| TransRequestedCON | varchar(50) | YES | | |
| TransRequestedCopay | varchar(50) | YES | | |
| TransRequestedDiscount | varchar(50) | YES | | |
| TransRequestedFee | varchar(50) | YES | | |
| TransRequestedTax | varchar(50) | YES | | |
| TransRequestedTotal | varchar(50) | YES | | |
| TransRphInitials | varchar(50) | YES | | |
| TransRxFromNumber | varchar(50) | YES | | |
| TransRxpIndicator | varchar(50) | YES | | |
| TransScriptNumber | varchar(50) | YES | | varchar duplicate of PK's int `ScriptNumber` |
| TransShippingCharge | varchar(50) | YES | | |
| TransSigs | nvarchar(500) | YES | | |
| TransStoreNumber | varchar(50) | YES | | included in IDX_ChangeLog_TypeCodeChangeDate |
| TransTax | varchar(50) | YES | | |
| TransTimeStampComputerDate | datetime | YES | | |
| TransTotal | varchar(50) | YES | | |
| TransTriplicateSerialNumber | varchar(50) | YES | | |
| TransUnitDoseIndicator | varchar(50) | YES | | |
| TransUsualAndCustomary | varchar(50) | YES | | |
| TransUsualAndCustomarySwitch | varchar(50) | YES | | |
| TransWorkersCompFormType | varchar(50) | YES | | |
| TransWorkFlowStatus | varchar(50) | YES | | |
| LastModified | datetime | YES | | |
| IsValid | bit | YES | | |
| TransAgencySequence | int | NO | | indexed (LibertyAuto_94_93) |
| OverrideUser | varchar(50) | NO | | |
| TransStoreNumberInventory | varchar(50) | YES | | |
| QuestionnaireReviewedDate | datetime | YES | | |
| QuestionnaireReviewedBy | varchar(50) | YES | | |
| LinkScriptNumber | int | YES | | |

No columns appear in `lookups` for this table (no small coded columns were sampled/reported), so no enum domains can be listed.

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

These are all INFERRED from column naming and DATA-VALIDATED against actual key values — not declared constraints.

- **Outbound (inferred)**
  - `ScriptNumber` → `rxqScriptBase` (join on `ScriptNumber`) — inferred, **high** confidence (99.5% referential match, 913 orphans out of 200,000 sampled non-null values) (sampled)
  - `PatientId` → `rxqPatient` (join on `PatientId`) — inferred, **high** confidence (98.1% referential match, 3,865 orphans out of 200,000 sampled non-null values) (sampled)

- **Inbound (inferred)**
  - none

**Indexes**

- `IDX_ChangeLog_TypeCodeChangeDate` (nonclustered): key `(TypeCode, ChangeDate)`, includes `ScriptNumber, RefillNumber, TransStoreNumber` — supports change-type/time-range lookups.
- `IX_ScriptRefillChangeDateDescription` (nonclustered): key `(ScriptNumber, RefillNumber, ChangeDate, ChangeDescription)` — supports per-script/refill history retrieval, overlapping the PK order plus description.
- `RxqChangeLogEntry_FamilyIdentification` (nonclustered): key `(PatientId)` — supports patient-level change history lookups (aligns with the `PatientId` inferred relationship).
- `LibertyAuto_92_91_rxqChangeLogEntry` (key `TransAgency`) and `LibertyAuto_94_93_rxqChangeLogEntry` (key `TransAgencySequence`) are Liberty auto-generated single-column indexes supporting agency/claim-sequence lookups within the transaction snapshot fields.

**Gotchas**

- Nearly all `Trans*` financial/claim fields are typed `varchar(50)` rather than numeric/date, including amounts (`TransCost`, `TransCopay`, `TransTotal`) and at least one clearly date-semantic field (`TransPrimaryPayorDenialDate`) — expect string-formatted numbers/dates requiring casting.
- Redundant identifier duplication: `TransScriptNumber` and `TransRefillNumber` (both varchar) duplicate the int PK columns `ScriptNumber`/`RefillNumber` — likely a point-in-time string snapshot of the claim transaction rather than a live key; do not join on these varchar copies without validation.
- `PatientId` and `ScriptNumber` are both stored as varchar/int per Liberty convention elsewhere but referential match is not 100% (913 and 3,865 orphans respectively out of 200,000 sampled) — treat as high-confidence but not guaranteed-complete referential integrity, consistent with an audit log that can outlive or predate purged parent rows.
- No inbound references found — this table is a leaf/terminal audit table in the inferred relationship graph.
- Not mirrored by ETL into liberty_link_stage, so eMed-side reporting cannot join directly to this change-log detail; any audit investigation needs a direct Liberty/RxQ DB query.

---

## `rxqScriptTransactionAudit`

Rows (RXCS): 2,182,822 | Columns: 14 | PK: `cTranAuditId` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Audit trail of workflow-status and workflow-location transitions for individual script/refill transactions, keyed to `rxqScriptTransaction` (via `cScriptTransactionId`) and `rxqScriptBase` (via `ScriptNumber`, scoped to a specific `RefillNumber`). Each row records a single change event: old/new workflow status (`OldWorkFlowStatus`/`NewWorkFlowStatus`), old/new workflow location (`OldWorkFlowLocation`/`NewWorkFlowLocation`), boolean flags marking whether that event was a status change and/or a location change (`StatusChange`, `LocationChange`), plus `ModifiedBy`/`ModifiedDate` for who/when, and `Transition`/`PartialFill` codes describing the nature of the transition (inferred — no lookup values sampled to confirm exact meaning). This is the append-only audit log layer sitting behind the operational `rxqScriptTransaction` table, giving a time-ordered history of a script's movement through pharmacy workflow stations (inferred, consistent with typical Liberty/RxQ workflow-tracking design).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `cTranAuditId` | numeric(18,0) | NO | PK | identity |
| `cScriptTransactionId` | numeric(18,0) | NO | → `rxqScriptTransaction` | |
| `ScriptNumber` | int | NO | → `rxqScriptBase` | |
| `RefillNumber` | int | NO | | no lookup values sampled |
| `StatusChange` | bit | YES | | flag: whether this audit row represents a status change |
| `NewWorkFlowStatus` | varchar(50) | YES | | no lookup values sampled |
| `OldWorkFlowStatus` | varchar(50) | YES | | no lookup values sampled |
| `LocationChange` | bit | YES | | flag: whether this audit row represents a location change |
| `NewWorkFlowLocation` | int | YES | | no lookup values sampled |
| `OldWorkFlowLocation` | int | YES | | no lookup values sampled |
| `ModifiedBy` | varchar(50) | NO | | no lookup values sampled |
| `ModifiedDate` | datetime | NO | | |
| `Transition` | int | YES | | coded transition type (inferred); no lookup values sampled |
| `PartialFill` | int | YES | | coded partial-fill indicator (inferred); no lookup values sampled |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- Outbound (inferred):
  - `ScriptNumber` → `rxqScriptBase` — inferred, **high** confidence (99.93% referential match, sampled)
  - `cScriptTransactionId` → `rxqScriptTransaction` — inferred, **high** confidence (99.9% referential match, sampled)
- Inbound (inferred): none

These edges are inferred from column naming and then data-validated against actual parent-table values; they are not enforced database constraints, so orphaned references (e.g. the ~0.07-0.1% unmatched rows above) are possible and observed.

**Indexes**

- `IX_ScriptTransactionAudit_ScriptNmRefillNm` (NONCLUSTERED, non-unique) on (`ScriptNumber`, `RefillNumber`) — supports lookup of a script/refill's full audit history.

**Gotchas**

- Not ETL-mirrored into liberty_link_stage — this audit history is only queryable directly against the Liberty/RxQ source database, not via eMed's mirrored tables.
- No lookup/enum values were sampled for any coded column (`Transition`, `PartialFill`, `NewWorkFlowStatus`, `OldWorkFlowStatus`, workflow-location ints) — their domains must be reverse-engineered from `rxqScriptTransaction`/workflow config tables or app code, not assumed from this metadata.
- `RefillNumber` scoping means a single `ScriptNumber` can have many audit rows across multiple refills; joins on `ScriptNumber` alone (without `RefillNumber`) will span refills.
- Both outbound relationships have a small but nonzero orphan rate (~149 and ~204 unmatched rows in the 200k sample) — consistent with audit rows surviving purges/edits to parent transaction or script records; don't assume 100% referential integrity when joining.

---

## `Anchor`

Rows (RXCS): 351 | Columns: 8 | PK: `anc_table` | ETL-mirrored into liberty_link_stage: no

**Purpose**
System/internal bookkeeping table, one row per named table (`anc_table` is the PK and holds a table name as its value, e.g. presumably each Liberty base table gets tracked here — inferred). Columns track sent/received/applied high-water marks (`anc_sent`, `anc_received`, `anc_server_applied`) plus insert/update/max-value-reached flags and an `InitialAnchor` baseline value. This shape is characteristic of a change-tracking / replication-sync anchor table used internally by the Liberty application (or its underlying sync/replication mechanism) to checkpoint per-table incremental sync progress (inferred — no FK or lookup data confirms this, but the column naming pattern strongly matches a watermark/cursor design). It is not part of the clinical/pharmacy data model itself (no patient, order, or Rx columns) and is not ETL-mirrored to eMed, consistent with it being pharmacy-software internal plumbing rather than business data.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| anc_table | nvarchar(128) | NO | PK | Presumably holds the name of the tracked table (inferred from name) |
| anc_sent | bigint | YES | | Likely last-sent watermark/cursor value (inferred) |
| anc_received | bigint | YES | | Likely last-received watermark/cursor value (inferred) |
| anc_server_applied | bigint | YES | | Likely last-applied-on-server watermark (inferred) |
| INITIAL_MAX_VALUE_REACHED | int | YES | | Flag/marker for initial max value reached (inferred from name) |
| UPDATE_MAX_VALUE_REACHED | bigint | YES | | Flag/marker for update max value reached (inferred from name) |
| INSERT_MAX_VALUE_REACHED | bigint | YES | | Flag/marker for insert max value reached (inferred from name) |
| InitialAnchor | bigint | YES | | Baseline/starting anchor value (inferred from name) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

No inferred_relationships or inferred_referenced_by edges were detected for this table — `anc_table` is a name/string key, not a typed reference to another table's numeric/GUID PK, so no naming-based join inference applies.

**Indexes**

None reported.

**Gotchas**
- No lookups data available (not a small coded/enum column set) — cannot confirm actual table-name values stored in `anc_table` without direct sampling.
- Mixed `int`/`bigint` types across the three "MAX_VALUE_REACHED" columns is inconsistent and may indicate ad hoc schema evolution rather than a designed watermark set.
- Entirely absent from declared/inferred relationships in both directions — this table is structurally isolated from the rest of the schema, reinforcing that it's internal sync/replication metadata rather than a joinable business entity.
- Not ETL-mirrored; irrelevant to eMed reporting/business logic — flag as out-of-scope for data-model documentation beyond noting its existence.

---

## `sync_ScopeTables`

Rows (RXCS): 349 | Columns: 5 | PK: `ScopeId`, `TableName` (composite) | ETL-mirrored into liberty_link_stage: no

**Purpose** — A control/registry table for Liberty's internal replication or change-tracking subsystem: one row per (scope, table) pair, flagging whether that table is currently valid for sync (`SyncValid`) and holding batching parameters (`BatchSize`, `BatchSizeInitial`) presumably used to size sync/replication batches per table (inferred). `TableName` values likely correspond to actual Liberty table names, and `ScopeId` likely identifies a sync scope/publication grouping (inferred — no lookup values sampled to confirm). This appears to be Liberty-internal plumbing (e.g., merge/transactional replication scope metadata) rather than pharmacy-domain data, and is not part of the ETL mirror into liberty_link_stage.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| ScopeId | int | NO | PK | Composite PK part 1 |
| TableName | varchar(200) | NO | PK | Composite PK part 2 |
| SyncValid | int | NO | | Coded domain (sampled): `1` (346 rows), `0` (3 rows) — likely boolean valid/invalid flag |
| BatchSize | int | YES | | |
| BatchSizeInitial | int | YES | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none.
- **Inbound (inferred):**
  - `sync_ColumnUpdates.tableName` → `sync_ScopeTables` — inferred, **unvalidated** confidence (parent empty or type mismatch prevented data validation; no match_rate available).

**Indexes** — none reported (only the implicit PK).

**Gotchas**
- Composite varchar+int PK (`TableName` up to 200 chars) — unusual for a lookup/registry table; watch for case-sensitivity/whitespace issues if joining by `TableName` string.
- `inferred_referenced_by` edge from `sync_ColumnUpdates.tableName` is unvalidated (not data-checked) — treat as a weak, unconfirmed guess, not a real join.
- No indexes beyond the PK were reported, and no ETL mirroring — this table is pure Liberty-internal sync metadata, not intended for downstream/BI consumption.

---

## `sync_ScopeConfig`

Rows (RXCS): 2 | Columns: 4 | PK: `ScopeId` | ETL-mirrored into liberty_link_stage: no

**Purpose** — A tiny internal configuration table, likely belonging to Liberty's own internal "sync" subsystem rather than pharmacy/clinical data: it names discrete "scopes" (`ScopeName`), a run-time/interval setting (`ScopeRunTime`), and the last time each scope executed (`LastSyncTime`) (inferred). With only 2 rows and no relationships to any patient/order/prescription tables, it reads as a control table for a background sync or scheduling job internal to the Liberty application (inferred). Not mirrored by ETL, consistent with it being an operational/config table rather than pharmacy business data.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| ScopeId | int | NOT NULL | PK | |
| ScopeName | varchar(200) | NULL | | no lookups sampled |
| ScopeRunTime | int | NULL | | no lookups sampled; likely an interval or scheduled-time value (inferred) |
| LastSyncTime | datetime | NULL | | timestamp of last sync execution (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

**Indexes** — none defined.

**Gotchas** — Extremely small (2 rows), no FK-style columns and no inferred relationships at all, so this table stands isolated from the rest of the schema; it is almost certainly Liberty-internal plumbing (a sync scheduler config) rather than a pharmacy-domain entity, and probably safe to exclude from any data-modeling of the pharmacy workflow.

---

## `sync_config`

Rows (RXCS): 2 | Columns: 6 | PK: none declared | ETL-mirrored into liberty_link_stage: no

**Purpose** — Stores a small set of database-connection/service endpoints (`DatabaseName`, `ConnectionString`, `ServiceURL`) plus validity/config flags (`IsValid`, `IgnoreMAC`), suggesting this is a system-level configuration table for Liberty's own sync/replication or service-discovery mechanism, not a pharmacy-workflow entity table (inferred). With only 2 rows, it most likely holds one row per environment/target (e.g., a primary and a secondary sync endpoint) (inferred). No columns reference patients, orders, or scripts, so it plays no direct role in the fill/dispense pipeline (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| RecordId | numeric(18,0) | NO | | identity |
| DatabaseName | varchar(130) | YES | | |
| ConnectionString | varchar(500) | YES | | |
| ServiceURL | varchar(300) | YES | | |
| IsValid | bit | YES | | sampled values: `true` (2) |
| IgnoreMAC | bit | YES | | |

No primary key is declared on this table (no column flagged `pk`); `RecordId` is an identity column but not marked PK.

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

No inferred relationships were detected in either direction — no column names in this table (or elsewhere) matched naming patterns tying `sync_config` to other tables.

**Indexes** — none defined (empty index list).

**Gotchas**
- No declared or inferred primary key — `RecordId` (identity) is the only unique-ish candidate, but this must be confirmed operationally before using it as a join/reference key.
- `ConnectionString` at varchar(500) may contain sensitive connection details (credentials/server names) — treat as sensitive config data despite not being PHI.
- Extremely low row count (2) and total isolation from the relationship graph confirm this is infrastructure/config metadata for the Liberty application itself, not clinical or transactional data.

---

## `sync_ColumnUpdates`

rows (RXCS): 1 | columns: 5 | PK: `updateId` | ETL-mirrored into liberty_link_stage: no

**Purpose**: Generic column-level change-tracking table storing a row's table name, primary-key value, changed column name, and new value (inferred — a per-column audit/sync-queue record, likely feeding Liberty's own internal sync/replication mechanism rather than a business entity). `RowPrimaryKey` and `columnValue` are both stored as `varchar(700)`, meaning they hold stringified values regardless of the source column's actual type (inferred). Only 1 row exists at extract time, so this appears to be a near-empty/transient queue table rather than a persistent audit log.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| updateId | int | NOT NULL | PK | |
| tableName | varchar(100) | NOT NULL | → sync_ScopeTables (unvalidated) | name of the source table whose column changed |
| RowPrimaryKey | varchar(700) | NOT NULL | | stringified PK value of the changed row (wide varchar suggests composite/arbitrary PK support) |
| columnName | varchar(100) | NOT NULL | | name of the column that changed |
| columnValue | varchar(700) | NOT NULL | | new/updated value, stored as string |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**:
  - `tableName` → `sync_ScopeTables` — inferred, **unvalidated** (reason: no matching parent key column found; not data-checked, treat as an unconfirmed guess).
- **Inbound (inferred)**: none.

**Indexes**: none reported.

**Gotchas**
- Only 1 row sampled — any relationship or value-domain conclusions here are point-in-time and low-confidence by nature of sparse data.
- `tableName`/`columnName` are free-text varchar rather than FK-constrained, so integrity of the "which table/column changed" reference depends entirely on application discipline, not the schema.
- `RowPrimaryKey` and `columnValue` genericize storage as strings — any typed comparison (numeric/date) requires consumer-side casting.
- Not ETL-mirrored, so this table's contents are invisible to eMed/liberty_link_stage entirely.

---

## `SYNC_ID`

Rows (RXCS): 1 | Columns: 1 | PK: `CLIENTID` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Single-row table holding one `uniqueidentifier` value (`CLIENTID`) that uniquely identifies this Liberty client/tenant instance (inferred). Given the row count is exactly 1 and the sole column is a non-nullable GUID primary key, this looks like a database-instance identity stamp — likely used by Liberty's own sync/replication tooling to distinguish this tenant's database from others of identical schema (rxcs/mmed/mdvo) (inferred). It is not mirrored by the eMed ETL, consistent with it being infrastructure/instance metadata rather than pharmacy operational data.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `CLIENTID` | uniqueidentifier | NOT NULL | PK | No default, not identity, not computed |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

**Indexes**

None recorded.

**Gotchas**

- Only one row expected/observed; any application logic assuming a single `CLIENTID` per database should treat additional rows as anomalous.
- No inferred or declared relationships to any other table — this table is isolated, so its GUID is presumably consumed by name/config elsewhere (e.g., app connection settings) rather than joined in SQL.
- Not mirrored by ETL, so it is invisible to liberty_link_stage/eMed reporting — do not expect to find it there.

---

## `DB_VERSION`

Rows (RXCS): 1 | Columns: 12 | PK: none | ETL-mirrored into liberty_link_stage: no

**Purpose**
Single-row (currently) system table holding the installed Liberty/RxQ software version (`MajorVersion`/`MinorVersion`/`Build`/`Revision`/`OneOff`) and installation/backup metadata (`DateInstalled`, `InstalledBy`, `Description`, `LastRestoreDate`, `LastGoodBackupDate`, `LastGoodBackupStatus`, `KillSwitch`). This is application/DBA-facing infrastructure metadata, not clinical or order data — it is used by the Liberty application to identify the schema/build it's running against and to gate functionality via `KillSwitch` (inferred). It has no primary key and no observed indexes, consistent with a singleton config-row table rather than a transactional entity table.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| MajorVersion | char(5) | yes | | version segment |
| MinorVersion | char(5) | yes | | version segment |
| Build | char(5) | yes | | version segment |
| Revision | char(5) | yes | | version segment |
| OneOff | char(5) | yes | | one-off patch identifier (inferred) |
| DateInstalled | datetime | yes | | install timestamp for this version |
| InstalledBy | varchar(50) | yes | | user/account that performed install |
| Description | varchar(255) | yes | | free-text install/version description |
| KillSwitch | bit | yes | | sampled value: `false` (count 1) — only value observed in the single row |
| LastRestoreDate | datetime | yes | | last DB restore timestamp |
| LastGoodBackupDate | datetime | yes | | last known-good backup timestamp |
| LastGoodBackupStatus | varchar(max) | yes | | free-text/status of last backup |

**Relationships**
Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none.
- **Inbound (inferred):** none.

No column naming in this table suggests a relationship to any other Liberty table (no `*Id`/`tag_*`-style keys); it is an isolated singleton config table.

**Indexes**
None defined.

**Gotchas**
- No primary key at all — table appears designed to hold exactly one row (current row_count = 1); do not assume upsert-by-key semantics without an application-level guard.
- `KillSwitch` is a `bit` with only `false` sampled from the sole row — true/on behavior (e.g., disabling app functionality) is unconfirmed/unobserved here.
- All version columns are fixed `char(5)` rather than integers — comparisons/sorting by version must treat them as strings (e.g., zero-padding or string-based semver logic), not numeric.
- Not ETL-mirrored into liberty_link_stage — this is pharmacy-software-internal metadata, out of scope for the eMed application/reporting layer.

---
