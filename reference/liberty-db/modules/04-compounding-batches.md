# Liberty schema — Compounding & Batches

Compounding formulas and mixtures, compound batches with their ingredients, pending compounds, store-specific compound codes, and the batch-to-script link for dispensed compounded preparations.

> Part of the [Liberty/RxQ schema reference](../README.md). Liberty declares **no foreign-key constraints** (verified via `sys.foreign_keys`), so all relationships shown are **inferred from column naming and then data-validated** by referential match rate — each is tagged high / medium / low / no-data / unvalidated confidence. Row counts and sampled enum values are from the RXCS instance (point-in-time); the schema itself is identical across the rxcs / mmed / mdvo tenants.

**Tables in this module (7):** [`rxqDrugBatch`](#rxqdrugbatch) · [`rxqDrugBatchCompoundIngredient`](#rxqdrugbatchcompoundingredient) · [`rxqDrugCompoundIngredient`](#rxqdrugcompoundingredient) · [`rxqDrugCompoundPending`](#rxqdrugcompoundpending) · [`rxqDrugCompoundInstructions`](#rxqdrugcompoundinstructions) · [`RxCompoundStoreCode`](#rxcompoundstorecode) · [`rxqScriptDrugBatch`](#rxqscriptdrugbatch)

---

## `rxqDrugBatch`

Rows (RXCS): 17,379 · Columns: 15 · PK: `BatchId` · ETL-mirrored into `liberty_link_stage`: no

**Purpose**

Stores drug inventory batches/lots for a pharmacy's stock — one row per lot of a given `DrugId` (→ `rxqDrug`), tracking lot number, expiration date, original vs. current quantity on hand, wastage, and a validity flag. It underpins lot-level inventory tracking and traceability: `LastDateDispensed` and `IsValid` suggest batches are consumed down over time and eventually retired/invalidated (12,386 of 17,379 rows are `IsValid = false`, i.e. the large majority of batches are exhausted or deactivated) (inferred). It is a hub for compounding and dispensing: it is referenced by `rxqDrugBatchCompoundIngredient` (batches used as compound ingredients), `rxqDrugCompoundPending` (pending compounds sourcing from a batch), `rxqScriptDrugBatch` (script-to-batch dispensing linkage), and `rxqAuditLogMaster` (audit trail of batch changes) (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| BatchId | nvarchar(50) | NO | PK | Varchar surrogate key |
| DrugId | nvarchar(50) | YES | → `rxqDrug` | Inferred FK, 99.97% referential match (6 orphans) |
| StoreNumber | nvarchar(50) | YES | | Likely store/location scoping (inferred) |
| LotNumber | nvarchar(max) | YES | | Manufacturer lot number (inferred) |
| ExpirationDate | datetime | YES | | Lot expiration date |
| QtyInStock | decimal(12,3) | YES | | Current remaining quantity |
| LastModified | datetime | YES | | Audit timestamp |
| IsValid | bit | YES | | Coded domain sampled: `false` = 12,386; `true` = 4,993 — batch active/usable flag (inferred) |
| CreatedOn | datetime | YES | | Audit timestamp |
| CreatedBy | nvarchar(max) | YES | | Audit user |
| LastDateDispensed | datetime | YES | | Last date stock was dispensed from this batch (inferred) |
| AuditTracking | nvarchar(max) | YES | | Free-form audit/change note (inferred) |
| QtyOriginal | decimal(9,3) | YES | | Original received/created quantity, compare to `QtyInStock` for consumption (inferred) |
| VerifiedBy | varchar(200) | YES | | User who verified the batch (inferred) |
| Wastage | decimal(18,8) | YES | | High-precision wastage/loss quantity (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

These edges are inferred from column naming and data-validated against actual key values — not enforced constraints.

- **Outbound (inferred)**
  - `DrugId` → `rxqDrug` — inferred, **high** confidence (99.97% referential match)

- **Inbound (inferred)**
  - `rxqAuditLogMaster.BatchId` → this table — inferred, **high** confidence (100.0% referential match)
  - `rxqDrugBatchCompoundIngredient.BatchId` → this table — inferred, **high** confidence (100.0% referential match)
  - `rxqDrugCompoundPending.BatchId` → this table — inferred, **high** confidence (100.0% referential match)
  - `rxqScriptDrugBatch.BatchId` → this table — inferred, **high** confidence (100.0% referential match)

**Indexes**

- `Batch-DrugIdIndex` (nonclustered, non-unique) on `DrugId` — supports the drug→batch lookup path (e.g. finding all lots for a drug).

**Gotchas**

- `BatchId` and `DrugId` are both varchar surrogate keys (nvarchar(50)), not integers — join carefully on exact string match.
- `QtyInStock`, `QtyOriginal`, and `Wastage` use inconsistent decimal precisions (12,3 / 9,3 / 18,8) — no shared unit-scale convention evident.
- Not ETL-mirrored into `liberty_link_stage`, so eMed-side reporting cannot join to this table without a direct Liberty DB query.
- 6 `DrugId` values (of 17,379) do not resolve to `rxqDrug` — small but nonzero orphan set to be aware of when joining.

---

## `rxqDrugBatchCompoundIngredient`

Rows (RXCS): 54,314 · Columns: 18 · PK: `id` · ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores one row per ingredient used in a compounded-drug production batch (`BatchId` → `rxqDrugBatch`), recording the ingredient's identity (`IngredientDrugKey`, `DrugName`, `NDCNumber`), the quantity actually weighed/measured vs. the formula target (`MetricDecimalQuantity` vs `MetricDecimalQuantityActual`), lot/expiration tracking (`IngredientLotNumber`, `IngredientExpirationDate`), and costing/billing flags (`Cost`, `BasisOfCost`, `BillIngredient`, `Wastage`). `MixtureSequence` links each row back to the ingredient's position/definition in the compound formula (`rxqDrugCompoundIngredient`), i.e. this table is the batch-execution instance of that formula's ingredient list (inferred). `ActiveIngredient` and `ActiveIngredientRatio` distinguish active pharmaceutical ingredients from excipients/vehicles, supporting potency/ratio calculations for the finished compound (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| id | nvarchar(50) | NO | PK | |
| BatchId | nvarchar(50) | YES | → rxqDrugBatch | |
| MixtureSequence | int | YES | → rxqDrugCompoundIngredient | |
| IngredientDrugKey | nvarchar(50) | YES | | no validated ref; likely internal drug key (inferred) |
| MetricDecimalQuantity | decimal(15,8) | YES | | target/formula quantity (inferred) |
| BasisOfCost | nvarchar(50) | YES | | |
| IngredientLotNumber | nvarchar(50) | YES | | |
| IngredientExpirationDate | datetime | YES | | |
| ActiveIngredient | bit | YES | | sampled: false=29,886, true=24,428 |
| ActiveIngredientRatio | decimal(12,5) | YES | | |
| Cost | decimal(9,2) | YES | | |
| DrugName | varchar(100) | YES | | |
| NDCNumber | nvarchar(50) | YES | → rxqClinicalLookup | |
| MetricDecimalQuantityActual | decimal(15,8) | YES | | actual/weighed quantity (inferred) |
| InputType | int | YES | | sampled: 0=53,719, null=595 (domain meaning not documented) |
| WeightType | int | YES | | no sampled values present in lookups |
| Wastage | bit | YES | | |
| BillIngredient | bit | YES | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

These are all INFERRED from column naming and then DATA-VALIDATED by checking whether this table's actual values exist in the candidate parent key — not enforced constraints.

- **Outbound (inferred)**
  - `BatchId` → `rxqDrugBatch` (join on `BatchId`) — inferred, **high** confidence (100.0% referential match, 54,314/54,314 non-null resolve, not sampled)
  - `MixtureSequence` → `rxqDrugCompoundIngredient` (join on `MixtureSequence`) — inferred, **high** confidence (100.0% referential match, 54,314/54,314 non-null resolve, not sampled)
  - `NDCNumber` → `rxqClinicalLookup` (join on `NdcNumber`) — inferred, **low** confidence (57.8% referential match, 22,898/54,314 values are orphans, not sampled) — treat as a weak/unconfirmed guess; likely NDCs not present (or not yet loaded) in the clinical lookup table

- **Inbound (inferred)**
  - none

**Indexes**
- `Batch-DrugCompoundIdIndex` (nonclustered, non-unique) on `BatchId` — supports the primary batch → ingredients join path.

**Gotchas**
- All key-like columns (`id`, `BatchId`, `IngredientDrugKey`, `NDCNumber`) are `nvarchar`, not integer surrogate keys — standard Liberty pattern, no numeric identity columns here.
- `MixtureSequence` is typed `int` but is being used as a join key into `rxqDrugCompoundIngredient` rather than as a plain ordinal — despite the 100% match rate, confirm it isn't coincidentally also acting as a true sequence/order number within the batch before treating it purely as an FK.
- `NDCNumber`'s low (57.8%) match against `rxqClinicalLookup.NdcNumber` means nearly 43% of ingredient NDCs can't be resolved to a clinical/drug lookup row — don't assume this join is safe for reporting without handling orphans.
- `IngredientDrugKey` has no inferred/validated reference at all despite the "Key" suffix in its name — its parent table is unknown/unconfirmed.
- `WeightType` and `BasisOfCost` have no sampled lookup values in this extract; their coded domains are undocumented here — do not assume meanings.

---

## `rxqDrugCompoundIngredient`

Rows: 6,062 (RXCS) · Columns: 13 · PK: `ParentDrugKey`, `MixtureSequence` (composite) · ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores the ingredient formula lines for compounded drugs: each row is one ingredient (`IngredientDrugKey`) that goes into a parent compound (`ParentDrugKey`), at a given position in the mixture (`MixtureSequence`). Columns like `MetricDecimalQuantity`, `ActiveIngredient`/`ActiveIngredientRatio`, `BillIngredient`, `QuantitySufficient`, and `Wastage` support compounding-workflow accounting — how much of each ingredient goes in, which ingredient(s) are the active pharmaceutical ingredient(s) vs. base/vehicle, which ingredients are separately billed, and which quantity is treated as "quantity sufficient" (qs, i.e. fill-to-volume) rather than a fixed amount (inferred, standard NCPDP/compounding-pharmacy semantics). `BasisOfCost` (inferred) likely drives which cost basis (e.g. AWP/WAC/ingredient cost) is used for pricing that ingredient line. This table is not currently mirrored into the eMed warehouse (`mirrored_by_etl: false`), so it is only reachable via direct Liberty/RxQ queries, not via `liberty_link_stage`.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `cDrugCompoundIngredientId` | int | NOT NULL | | identity (surrogate row id) |
| `ParentDrugKey` | varchar(50) | NOT NULL | PK | compound drug identifier (part 1 of composite PK); no validated outbound edge recorded — likely references a drug master table by naming, but not confirmed in `inferred_relationships` |
| `MixtureSequence` | int | NOT NULL | PK | position of this ingredient within the compound formula (part 2 of composite PK); referenced by `rxqDrugBatchCompoundIngredient` (see Relationships) |
| `IngredientDrugKey` | varchar(50) | NULL | (indexed) | the ingredient's drug identifier; naming implies a drug-master reference but no validated outbound edge is recorded |
| `BasisOfCost` | varchar(50) | NULL | | coded cost-basis for this ingredient line; not present in sampled lookups (no enum domain captured) |
| `MetricDecimalQuantity` | float | NULL | | quantity of this ingredient in metric decimal form |
| `LastModified` | datetime | NULL | | audit timestamp |
| `IsValid` | bit | NULL | | sampled values: `true` (6,062 / 6,062) — every sampled row is valid; no `false` rows observed |
| `ActiveIngredient` | bit | NOT NULL | | flags active-pharmaceutical-ingredient lines; sampled values: `false` (3,470), `true` (2,592) |
| `ActiveIngredientRatio` | float | NOT NULL | | proportion/ratio attributable to the active ingredient (inferred) |
| `BillIngredient` | bit | NULL | | whether this ingredient line is separately billed (inferred) |
| `QuantitySufficient` | bit | NOT NULL | | "qs" flag — fill-to-quantity rather than fixed amount (inferred) |
| `Wastage` | bit | NULL | | flags an ingredient quantity accounted for as wastage (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none recorded. Note: `ParentDrugKey` and `IngredientDrugKey` are naming-suggestive of drug-master references, but no outbound edge for either survived inference/validation in this extract — treat any such relationship as an unconfirmed guess, not evidenced here.
- **Inbound (inferred):**
  - `rxqDrugBatchCompoundIngredient.MixtureSequence` → this table's `MixtureSequence` — inferred, **high** confidence (100.0% referential match).

**Indexes**

- `IX_DrugCompoundIngredient_IngredientDrugKey` (NONCLUSTERED, non-unique) on `IngredientDrugKey` — supports lookup of all compound-ingredient lines that use a given ingredient drug.

**Gotchas**

- Both key-like columns (`ParentDrugKey`, `IngredientDrugKey`) are `varchar(50)`, not integer surrogate keys — typical of Liberty's drug-key scheme, but means joins to any drug master table must match on string keys, not IDs.
- `IsValid` shows only `true` in the sample (6,062/6,062) — no soft-deleted/invalidated rows were observed here, so don't assume the column is unused; it may simply be that no invalid rows exist at this point in time.
- Not ETL-mirrored: any eMed-side reporting on compound formulas/ingredient costing requires direct Liberty/RxQ access, not `liberty_link_stage`.
- `BasisOfCost` has no captured lookup values — its coded domain is unknown from this extract; do not assume specific values without checking Liberty directly.

---

## `rxqDrugCompoundPending`

Rows (RXCS): 4,876 | Columns: 13 | PK: `cDrugCompoundPendingId` | ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores in-progress compounded-drug production items — one row per compound batch item awaiting/undergoing manufacture, linking a drug (`DrugId`), quantity being made (`QtyInMake`), and wastage recorded during compounding (`Wastage`) to a production batch (`BatchId`) and a workflow `Stage` (inferred: numeric status code tracking the compound through its make pipeline, e.g. queued/mixing/complete). `ProblemNotes` suggests exception/QA handling when a compound run hits an issue (inferred). `ScriptNumber`/`RefillNumber` attempt to tie the pending compound back to the originating prescription, but the data shows most `ScriptNumber` values do not resolve to `rxqScriptBase` (see Relationships), so this linkage is weak/unreliable in practice. Not mirrored by ETL, so eMed has no visibility into in-flight compounding work.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cDrugCompoundPendingId | int | NO | PK | identity |
| DrugId | nvarchar(50) | YES | → rxqDrug | |
| StoreNumber | nvarchar(50) | YES | | |
| QtyInMake | decimal(12,5) | YES | | |
| DateAdded | datetime | YES | | |
| LastModified | datetime | YES | | |
| Stage | int | YES | | workflow/status code (no lookup sample captured) |
| BatchId | varchar(50) | YES | → rxqDrugBatch | |
| ProblemNotes | varchar(500) | YES | | free-text exception notes (inferred) |
| ItemType | int | YES | | coded domain sampled: `1` (4,835 rows), `0` (41 rows) |
| ScriptNumber | int | YES | → rxqScriptBase (weak) | |
| RefillNumber | int | YES | | |
| Wastage | decimal(18,8) | YES | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**
  - `DrugId` → `rxqDrug` — inferred, **high** confidence (100.0% referential match, 4,876/4,876 non-null resolve)
  - `BatchId` → `rxqDrugBatch` — inferred, **high** confidence (100.0% referential match, 4,829/4,829 non-null resolve)
  - `ScriptNumber` → `rxqScriptBase` — inferred, **low** confidence (0.78% referential match; 4,838 of 4,876 non-null values are orphans — treat as an unconfirmed/likely-unreliable link)
- **Inbound (inferred)**: none

**Indexes**
None reported (no indexes present on this table).

**Gotchas**
- `DrugId` and `BatchId` are string-typed (`nvarchar`/`varchar`) surrogate-ish keys, not integers — typical of Liberty's loose-typing pattern despite high referential integrity here.
- `ScriptNumber` looks like a script linkage column by naming but is almost entirely orphaned against `rxqScriptBase` (99.2% orphan rate) — do not treat it as a reliable join key without further investigation; it may reference a different/legacy numbering scheme or be stale/unused.
- No ETL mirror exists, so any eMed-side reporting on active compounding work would need a new pull from this table.
- `Stage` and `ItemType` are undocumented numeric codes; only `ItemType` has a sampled domain (0/1) — `Stage`'s meaning is unconfirmed from this metadata.

---

## `rxqDrugCompoundInstructions`

Rows: 853 (RXCS) · Columns: 5 · PK: `drugCompoundInstructionsID` · ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores free-text compounding instructions (`instructions`, type `text`) associated with a compound drug identified by `compoundDrugID` (varchar(50)). (inferred) This looks like a lookup/master table holding the preparation/mixing directions a pharmacist or compounding tech follows for a given compound drug formulation, separate from the patient-specific prescription record — `compoundDrugID` is not validated against another table here (no `inferred_relationships` recorded), so its parent table could not be confirmed from this extract. `createdDate`/`lastModifiedDate` provide basic audit timestamps for when instructions were authored/edited.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| drugCompoundInstructionsID | int | NO | PK | identity |
| instructions | text | NO | | free-text compounding directions |
| compoundDrugID | varchar(50) | NO | | no validated implicit_ref found; likely links to a compound-drug master table (inferred, unconfirmed) |
| createdDate | datetime | NO | | |
| lastModifiedDate | datetime | NO | | |

**Relationships**
Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no inferred_relationships were detected for this table's columns (notably `compoundDrugID` did not resolve to a validated parent table in this extract).
- **Inbound (inferred):**
  - `rxqAuditLogMaster.drugCompoundInstructionsID` → this table — inferred, **low** confidence (4.2% referential match). This is a weak/unconfirmed edge; treat the audit-log linkage as unreliable, likely reflecting generic audit-ID reuse rather than a true consistent foreign key relationship.

**Indexes**
None reported in the extract.

**Gotchas**
- `compoundDrugID` is a varchar(50) key with no confirmed parent table in this dataset — do not assume it joins cleanly to any specific compound-drug table without further validation.
- The only inbound reference (`rxqAuditLogMaster`) has just a 4.2% match rate — almost certainly not a genuine dependency; don't rely on it for join logic.
- Table is not ETL-mirrored to liberty_link_stage, so this data is not queryable from the eMed side without a direct Liberty DB connection.

---

## `RxCompoundStoreCode`

rows: 20,346 (RXCS), columns: 3, PK: none declared, ETL-mirrored: no (not mirrored into liberty_link_stage).

**Purpose**

Stores a per-person (`Last`/`First` name) association to a `Code` value that structurally matches `rxqEcareCode.Code` (inferred). Given the table name ("CompoundStoreCode"), it likely maps pharmacy staff/compounders to a store or e-care classification code used elsewhere in Liberty's compounding workflow (inferred) — but the `Code` → `rxqEcareCode` link is data-validated at 0% match (all 10,264 non-null codes are orphans), so this cannot be confirmed from the data; the naming-based inference is weak/unconfirmed. No primary key, no indexes, and no other tables reference this one, suggesting it may be a lookup/reference or legacy/staging table rather than an actively joined operational table (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `Last` | nvarchar(50) | yes | | Likely surname of a person (compounder/pharmacist) (inferred) |
| `First` | nvarchar(50) | yes | | Likely given name of a person (inferred) |
| `Code` | nvarchar(50) | yes | → `rxqEcareCode` (unconfirmed) | Free-text/varchar code; no sampled lookup values available |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):**
  - `Code` → `rxqEcareCode` (join col `Code`) — inferred, **low** confidence (0.0% referential match, 10,264 non-null values, 10,264 orphans, not sampled). This edge is a naming-based guess only; the data does not support it — treat as unconfirmed.
- **Inbound (inferred):** none.

**Indexes**

None defined (no indexes reported).

**Gotchas**

- No primary key at all — rows cannot be uniquely identified by declared structure; likely deduping/uniqueness must rely on `(Last, First, Code)` in combination or an external row identity, if any.
- The only inferred relationship (`Code` → `rxqEcareCode`) data-validates at 0% match despite naming similarity — do not treat this as a real join path without further investigation; it may reference a different/decommissioned code domain, or `Code` may not be an `rxqEcareCode` reference at all.
- No columns are covered by `lookups`, so the coded domain of `Code` is unknown from sampling — treat it as opaque free text pending further inspection.
- Not ETL-mirrored into liberty_link_stage, so this table is invisible to downstream eMed reporting/ETL consumers.

---

## `rxqScriptDrugBatch`

Rows: 464,932 (RXCS) · Columns: 5 · PK: `id` · ETL-mirrored into `liberty_link_stage`: no

**Purpose** — A junction/link table tying a specific script/refill (`ScriptNumber` + `RefillNumber`) to a drug batch (`BatchId`) with a quantity (`Qty`). It records which drug-inventory batch(es) were used to fill a given script fill, and in what amount (inferred). This supports lot/batch traceability for dispensed drugs — e.g. for recalls or NCPDP fill-lot reporting (inferred). Both `ScriptNumber` and `BatchId` validate at 100% (sampled) against `rxqScriptBase` and `rxqDrugBatch` respectively, confirming this is a clean link table between scripts and batches rather than a standalone entity.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `id` | nvarchar(50) | NO | PK | Surrogate string key (not identity) |
| `ScriptNumber` | int | YES | → `rxqScriptBase` | Implicit ref; inferred outbound edge, high confidence |
| `RefillNumber` | int | YES | | No implicit ref detected; paired with `ScriptNumber` in index `scriptrefillDrugBatch` to identify a specific fill |
| `BatchId` | nvarchar(50) | YES | → `rxqDrugBatch` | Implicit ref; inferred outbound edge, high confidence |
| `Qty` | decimal(12,3) | YES | | Quantity of the batch consumed/allocated for this script fill (inferred) |

No `lookups` data present for this table (no small coded columns sampled).

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- Outbound (inferred):
  - `ScriptNumber` → `rxqScriptBase` (join col `ScriptNumber`) — inferred, **high** confidence (100.0% referential match, sampled).
  - `BatchId` → `rxqDrugBatch` (join col `BatchId`) — inferred, **high** confidence (100.0% referential match, sampled).
- Inbound (inferred): none.

These edges are inferred purely from column naming and then data-validated by checking that sampled non-null values exist in the candidate parent table's key column — they are not enforced/declared database constraints, so referential integrity is not guaranteed for unsampled rows.

**Indexes**

- `batchScriptBatch` (NONCLUSTERED, key: `BatchId`) — supports lookups from a drug batch to all scripts it was used on.
- `scriptrefillDrugBatch` (NONCLUSTERED, key: `ScriptNumber`, `RefillNumber`) — supports the primary access path: find batch usage for a specific script fill/refill.
- `_dta_index_rxqScriptDrugBatch_36_1531152500__K2_3_4` (NONCLUSTERED, key: `ScriptNumber`, included: `RefillNumber`, `BatchId`) — auto-generated (Database Tuning Advisor) covering index over the same script/refill/batch access pattern; largely redundant with `scriptrefillDrugBatch`.

**Gotchas**

- PK `id` is a non-identity `nvarchar(50)` — likely a GUID or externally-generated string, not a sequential surrogate.
- Both FK-like columns (`ScriptNumber`, `BatchId`) are nullable despite being the table's only substantive relational content; a null in either produces an orphaned quantity row with no resolvable script or batch.
- No `lookups` data and not ETL-mirrored — this table isn't currently visible to eMed/liberty_link_stage consumers, so any batch/lot-traceability need in eMed would require a new mirror.
- `RefillNumber` has no detected implicit_ref itself, but functionally composes with `ScriptNumber` (see `scriptrefillDrugBatch` index) to identify a specific fill event — treat the pair as the effective "fill" key, not `ScriptNumber` alone.

---
