# Liberty schema — Drugs & Formulary

The rxqDrug catalog/formulary and its dictionaries — NDC clinical lookup, generics, GPI categories, vendor item numbers, unit multipliers, user drug classes, immunization dose, and per-drug patient education.

> Part of the [Liberty/RxQ schema reference](../README.md). Liberty declares **no foreign-key constraints** (verified via `sys.foreign_keys`), so all relationships shown are **inferred from column naming and then data-validated** by referential match rate — each is tagged high / medium / low / no-data / unvalidated confidence. Row counts and sampled enum values are from the RXCS instance (point-in-time); the schema itself is identical across the rxcs / mmed / mdvo tenants.

**Tables in this module (10):** [`rxqDrug`](#rxqdrug) · [`rxqDrugOptions`](#rxqdrugoptions) · [`rxqDrugGenerics`](#rxqdruggenerics) · [`rxqDrugItemNumber`](#rxqdrugitemnumber) · [`rxqDrugGPICategories`](#rxqdruggpicategories) · [`rxqDrugImmunizationDose`](#rxqdrugimmunizationdose) · [`rxqUserDrugClass`](#rxquserdrugclass) · [`rxqClinicalLookup`](#rxqclinicallookup) · [`DigitalPatientEducation`](#digitalpatienteducation) · [`DrugUnitMultiplier`](#drugunitmultiplier)

---

## `rxqDrug`

Rows: 2,941 (RXCS) · Columns: 111 · PK: `DrugId` · ETL-mirrored: yes (into `liberty_link_stage`, 104 of 111 columns mirrored)

**Purpose**

`rxqDrug` is the pharmacy's drug master file — one row per dispensable drug/NDC-level product, holding identity (NDC, name, strength, form, schedule), pricing (AWP/ACQ/WAC/contract/MFP at both container and unit level, price-update timestamps and formulas), compounding attributes (`CompoundForm`, `CompoundUnit`, `CompoundType`, `CompoundIngredientModifierCodes`, `CompoundLevelOfEffort`), dispensing/regulatory flags (`Is340B`, `IsHazardous`, `Vaccine`, `DoNotSub`, `Schedule`, `OverTheCounter`), and inventory/vendor attributes (`PreferredVendor`, `StockLocation`, `CentralFillServiceId`, `DrugUnitMultiplierId`). It is the central reference table joined by nearly every prescription, dispensing, inventory, and clinical-lookup table in Liberty (30 inbound references found), functioning as the drug catalog underlying script entry, pricing, and inventory workflows (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| GID | numeric(18,0) | NO | | identity |
| DrugId | varchar(50) | NO | PK | |
| NdcNumber | varchar(50) | YES | → `rxqClinicalLookup` | indexed (IX_cDrug) |
| Strength | varchar(50) | YES | | |
| Form | varchar(50) | YES | | |
| Schedule | varchar(50) | YES | | DEA schedule code (inferred) |
| Generic | varchar(50) | YES | | |
| OverTheCounter | varchar(50) | YES | | |
| StateCode | varchar(50) | YES | | |
| Reorder | varchar(50) | YES | | |
| Manufacturer | varchar(50) | YES | | |
| ContainerCharge | varchar(50) | YES | | |
| SpecialSwitch | varchar(50) | YES | | |
| InventoryOption | varchar(50) | YES | | |
| DrugCode | varchar(50) | YES | | |
| Mixture | varchar(50) | YES | | |
| PriceBreak | decimal(8,3) | YES | → `rxqCopayPriceBreaks` | parent table empty, unvalidated |
| Alert1 | varchar(50) | YES | | |
| Alert2 | varchar(50) | YES | | |
| Alert3 | varchar(50) | YES | | |
| Alert4 | varchar(50) | YES | | |
| GenericSwitch | varchar(50) | YES | | |
| GenericPercent | int | YES | | |
| ContainerQuantity | decimal(18,4) | YES | | |
| ContainerAwpPrice | decimal(18,2) | YES | | |
| ContainerAcqPriceDeprecated | decimal(18,2) | YES | | name flags deprecated |
| ContainerContractPrice | decimal(18,2) | YES | | |
| UnitAwpPrice | decimal(18,4) | YES | | |
| UnitAcqPrice | decimal(18,4) | YES | | |
| UnitContractPrice | decimal(18,4) | YES | | |
| LastPriceUpdate | date | YES | | |
| PreviousPriceUpdate | date | YES | | |
| LastDateDispensed | date | YES | | |
| PriceFormula | varchar(50) | YES | | indexed (IX_Drug_PriceFormula) |
| MetricName | varchar(50) | YES | | |
| MetricUnit | decimal(18,5) | YES | | |
| AwpPriceUpdateSwitch | varchar(50) | YES | | |
| AcqPriceUpdateSwitch | varchar(50) | YES | | |
| HotListQty | decimal(18,4) | YES | | |
| HotListCost | decimal(18,2) | YES | | |
| CompoundForm | varchar(50) | YES | | |
| CompoundUnit | int | YES | | sampled: 0=1762, 2=1027, 3=117, 1=35 |
| CompoundAdministration | int | YES | | |
| Name | varchar(100) | YES | | indexed (IX_cDrug_1) |
| Hcpcs | varchar(50) | YES | | HCPCS billing code |
| ProcedureModifierCode | varchar(50) | YES | | |
| TherapeuticNoHitOption | varchar(50) | YES | | |
| MonographNdcNumber | varchar(50) | YES | | |
| CompoundUpdateAWP | varchar(50) | YES | | |
| CompoundUpdateACQ | varchar(50) | YES | | |
| LastModified | datetime | YES | | |
| IsValid | bit | YES | | sampled: true=2941 (all rows) |
| GenericLabelText | varchar(50) | YES | | |
| DoNotPrintMedGuide | char(1) | YES | | |
| QuickLookup | varchar(50) | YES | | indexed (IX_rxqDrug_2) |
| CustomField1 | varchar(50) | YES | | |
| CustomField2 | varchar(50) | YES | | |
| CustomField3 | varchar(50) | YES | | |
| CustomField4 | varchar(50) | YES | | |
| DefaultGeneric | bit | NO | | sampled: false=2939, true=2 |
| ContainerWacPrice | decimal(18,2) | YES | | |
| UnitWacPrice | decimal(18,4) | YES | | |
| PreferredVendor | varchar(50) | YES | | |
| CompoundType | char(2) | YES | | sampled: "  " (blank)=1745, "99"=1150, "01"=24, "04"=20, "07"=1, "03"=1 |
| CompoundIngredientModifierCodes | varchar(200) | YES | | |
| RouteOfAdministration | varchar(100) | YES | | |
| Is340B | bit | NO | | 340B pricing eligibility flag (inferred) |
| PotencyUnitCode | varchar(50) | NO | | |
| MinimumDispenseQuantity | decimal(10,4) | NO | | |
| ExpirationDays | int | YES | | |
| Alert5 | varchar(50) | YES | | |
| OrganizationId | varchar(50) | YES | | indexed (NonClusteredIndex-OrgId) |
| DoNotSub | bit | YES | | do-not-substitute (generic) flag (inferred) |
| RxLoyaltyPriceFormula | varchar(50) | YES | | |
| StockLocation | varchar(50) | YES | | |
| CategoryId | int | YES | | sampled: 0=2941 (all rows) |
| DateCreated | datetime | YES | | |
| WillCallLocation | int | NO | | sampled: 0=2941 (all rows) |
| SpecialtyDrug | varchar(50) | YES | | |
| Vaccine | varchar(50) | YES | | |
| SigVerb | varchar(50) | YES | | |
| SigRoute | varchar(50) | YES | | |
| GPIOverride | varchar(20) | YES | | Generic Product Identifier override |
| AlternativeProductQualifier | int | YES | | |
| AlternativeProductId | varchar(200) | YES | | |
| VaccineGroup | varchar(50) | YES | | |
| PriceReportQuantity | decimal(19,3) | YES | | |
| ExcludeEquivalent | bit | YES | | |
| ContainerQuantityPartition | bit | YES | | |
| EquivalentOrdering | int | YES | | |
| DoNotAutoFill | bit | YES | | |
| VisDate | date | YES | | Vaccine Information Statement date (inferred) |
| VisVersion | varchar(50) | YES | | |
| CompoundSpecialityType | int | YES | | sampled: 0=2485, 2=314, 1=139, null=3 |
| IncludeDefaultWastage | bit | YES | | sampled: false=2890, true=48, null=3 |
| DefaultWastage | decimal(18,8) | YES | | |
| DrugUnitMultiplierId | int | YES | | |
| CountryOfOrigin | nvarchar(max) | YES | | not ETL-mirrored |
| CentralFillServiceId | int | YES | | not ETL-mirrored |
| DoNotCf | bit | YES | | not ETL-mirrored; "do not central-fill" flag (inferred) |
| OnCfFormulary | bit | YES | | not ETL-mirrored; sampled: null=2941 (all rows, unused) |
| UnitOfUseQTY | decimal(8,3) | YES | | not ETL-mirrored |
| LabelsPerUnit | int | YES | | not ETL-mirrored; sampled: 0=2928, null=13 |
| IsHazardous | bit | NO | | not ETL-mirrored |
| CompoundLevelOfEffort | int | YES | | not ETL-mirrored; sampled: null=2311, 0=630 |
| ContainerMfpPrice | decimal(10,2) | YES | | not ETL-mirrored; Medicare "Maximum Fair Price" |
| MfpEffectiveDate | date | YES | | not ETL-mirrored |
| MfpEndDate | date | YES | | not ETL-mirrored |
| DefaultBinId | int | YES | | not ETL-mirrored; sampled: null=2941 (all rows, unused) |
| PreferredGeneric | bit | YES | | not ETL-mirrored |
| LastACQPerUnit | decimal(18,4) | YES | | not ETL-mirrored |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

These are INFERRED from column naming and DATA-VALIDATED against actual parent-key values — not enforced constraints.

- **Outbound (inferred)**
  - `NdcNumber` → `rxqClinicalLookup` — inferred, **low** confidence (37.5% referential match; 1,839 of 2,941 non-null values are orphans)
  - `PriceBreak` → `rxqCopayPriceBreaks` — inferred, **unvalidated** (parent table empty, cannot validate)

- **Inbound (inferred)** — `DrugId`/`DrugKey`/`DrugID` from 30 tables reference this table's PK:
  - `DrugPreferredVendor.DrugId` — **high** (100.0% match)
  - `PrescriptionRequests.DrugKey` — **high** (100.0% match)
  - `rxqDrugCompoundPending.DrugId` — **high** (100.0% match)
  - `rxqDrugGenerics.DrugKey` — **high** (100.0% match)
  - `rxqDrugImmunizationDose.DrugId` — **high** (100.0% match)
  - `rxqDrugSigs.DrugKey` — **high** (100.0% match)
  - `rxqProfileOnlyScripts.DrugKey` — **high** (100.0% match)
  - `rxqScriptBase.DrugKey` — **high** (100.0% match)
  - `rxqScriptTransaction.DrugId` — **high** (100.0% match)
  - `rxqUserDrugClass.DrugKey` — **high** (100.0% match)
  - `StockReturnHistory.DrugID` — **high** (100.0% match)
  - `rxqDrugBatch.DrugId` — **high** (99.97% match)
  - `rxqDrugOptions.DrugId` — **high** (99.89% match)
  - `rxqDrugPricingHistory.DrugId` — **high** (99.86% match)
  - `rxqAuxiliaryLabels.DrugId` — **high** (99.84% match)
  - `rxqDrugItemNumber.DrugKey` — **high** (99.72% match)
  - `DrugUnitMultiplier.DrugId` — **high** (95.94% match)
  - `CompoundMonographNotes.DrugID` — **no-data** (source table has no rows to check)
  - `DrugNotes.DrugID` — **no-data**
  - `DrugPreference.DrugID` — **no-data**
  - `HistoricalAppointment.DrugId` — **no-data**
  - `InventoryOperations.DrugId` — **no-data**
  - `InventoryTransactions.DrugId` — **no-data**
  - `rxqAcceptInventoryDetail.DrugId` — **no-data**
  - `rxqBCell.DrugKey` — **no-data**
  - `rxqDrugXM.DrugKey` — **no-data**
  - `rxqInventoryTransferLine.DrugId` — **no-data**
  - `rxqNewRxRequest.DrugId` — **no-data**
  - `rxqOnlineHistory.DrugKey` — **no-data**
  - `rxqScriptDrugSplit.DrugId` — **no-data**
  - `ScriptOperations.DrugId` — **no-data**
  - `rxqParameterGeneral.DrugKey` — **low** (0.0% match — weak/unconfirmed guess, likely not a real reference or column repurposed)
  - `rxqPendingScript.DrugId` — **low** (0.0% match — weak/unconfirmed guess)

**Indexes**

- `IX_cDrug` (NONCLUSTERED) on `NdcNumber` — supports NDC lookup.
- `IX_cDrug_1` (NONCLUSTERED) on `Name` — supports drug-name search.
- `IX_Drug_PriceFormula` (NONCLUSTERED) on `PriceFormula` — supports pricing-engine lookups by formula.
- `IX_rxqDrug_2` (NONCLUSTERED) on `QuickLookup` — supports quick-code lookup at script entry.
- `NonClusteredIndex-OrgId` (NONCLUSTERED) on `OrganizationId` — supports multi-org/tenant filtering.

**Gotchas**

- `DrugId` (PK) is a varchar(50), not numeric, despite an internal numeric identity `GID` also existing on the row — joins from other tables use varchar `DrugId`/`DrugKey`/`DrugID` (inconsistent naming across referencing tables, all validated at ~100% match).
- `NdcNumber` → `rxqClinicalLookup` is a weak (low-confidence, 37.5%) inferred link — do not treat it as a reliable clinical join; most NDCs on this table are not found in `rxqClinicalLookup`.
- `CategoryId`, `WillCallLocation`, `DefaultBinId`, and `OnCfFormulary` are single-valued or all-null across every sampled row (constant columns) — likely unused/legacy in this tenant's configuration; do not assume they carry meaningful signal.
- `ContainerAcqPriceDeprecated` is explicitly named deprecated — prefer `UnitAcqPrice`/`ContainerContractPrice`/`ContainerWacPrice` for current acquisition-cost logic.
- 7 columns (`CountryOfOrigin`, `CentralFillServiceId`, `DoNotCf`, `OnCfFormulary`, `UnitOfUseQTY`, `LabelsPerUnit`, `IsHazardous`, `CompoundLevelOfEffort`, `ContainerMfpPrice`, `MfpEffectiveDate`, `MfpEndDate`, `DefaultBinId`, `PreferredGeneric`, `LastACQPerUnit` — 13 total) are present in the live schema but NOT mirrored by ETL into `liberty_link_stage`; consumers needing MFP (Medicare Maximum Fair Price) fields, hazardous-drug flags, or central-fill routing must query Liberty directly.
- `rxqParameterGeneral.DrugKey` and `rxqPendingScript.DrugId` show 0% match against this table despite naming — these are likely false-positive inferred edges (different domain or a column that is normally null/unused) and should not be relied upon as real relationships.

---

## `rxqDrugOptions`

Rows (RXCS): 2,820 | Columns: 8 | PK: `StoreNumber, DrugId` | ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores per-store, per-drug dispensing/configuration flags for the Liberty pharmacy-management system — a store-drug override layer on top of the base `rxqDrug` catalog record. Columns `InActive`, `InAutoDispenser`, `IsValid`, `IsCentralFill`, and `AltPackSize` indicate this table governs whether a drug is active/valid at a given store, whether it's loaded in an automated dispensing device, whether it's fulfilled via central fill, and an alternate pack size for that store's stock (inferred). The composite PK (`StoreNumber`, `DrugId`) confirms this is a store-scoped drug settings row, not a global drug attribute table.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| StoreNumber | varchar(50) | NO | PK | part of composite key; identifies the store/location |
| DrugId | varchar(50) | NO | PK, → `rxqDrug` | part of composite key; drug catalog identifier |
| InActive | bit | NO | | sampled values: `false` (2,458), `true` (362) |
| InAutoDispenser | bit | NO | | flag, no sampled lookup values captured |
| LastModified | datetime | YES | | audit timestamp |
| IsValid | bit | YES | | sampled values: `true` (2,820) — 100% of sampled rows are valid; no `false` observed |
| IsCentralFill | bit | YES | | flag, no sampled lookup values captured |
| AltPackSize | decimal(10,3) | YES | | alternate pack size, presumably for store-specific stock unit (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**
  - `DrugId` → `rxqDrug` (join col `DrugId`) — inferred from column naming, DATA-VALIDATED, **high** confidence (99.89% referential match: 2,817/2,820 non-null values resolve; 3 orphans; not sampled).
- **Inbound (inferred)**
  - none.

**Indexes**
None reported (empty indexes array — no named/auxiliary indexes beyond the implicit PK).

**Gotchas**
- Both PK columns (`StoreNumber`, `DrugId`) are `varchar(50)` rather than integer surrogate keys — typical Liberty pattern, watch for join type/format mismatches against numeric IDs elsewhere.
- 3 `DrugId` values (0.11%) don't resolve to `rxqDrug` — likely stale/retired drug references or data-entry artifacts; not enough to lower confidence but worth excluding in strict joins.
- `IsValid` shows only `true` in the sampled data (all 2,820 rows) — either this column is effectively always true in practice or `false` rows exist but weren't captured in the lookup sample; don't assume `false` is impossible.
- Not ETL-mirrored to liberty_link_stage — any eMed-side feature needing store-level drug activation/auto-dispenser/central-fill flags must query Liberty directly or add ETL coverage.

---

## `rxqDrugGenerics`

Rows (RXCS): 2 | Columns: 12 | PK: `DrugKey` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Maps a drug (`DrugKey`, referencing `rxqDrug`) to up to four candidate generic-equivalent drugs, each identified by a `GenericDrugKeyN`/`GenericDrugNdcN` pair (N=1..4) (inferred: this looks like a generic-substitution / equivalence lookup table used for dispensing decisions or interchange logic, though the four generic slots have no declared or inferred FK link back into `rxqDrug` themselves). `IsValid` flags whether the mapping row is active; `LastModified` is an audit timestamp. The table is extremely sparse in this tenant (2 rows), so its real-world usage pattern can't be inferred from data alone.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cDrugGenericsId | int | NO | | identity |
| DrugKey | varchar(50) | NO | PK, → `rxqDrug` | |
| GenericDrugKey1 | varchar(50) | YES | | candidate generic #1 key (no inferred ref) |
| GenericDrugKey2 | varchar(50) | YES | | candidate generic #2 key (no inferred ref) |
| GenericDrugKey3 | varchar(50) | YES | | candidate generic #3 key (no inferred ref) |
| GenericDrugKey4 | varchar(50) | YES | | candidate generic #4 key (no inferred ref) |
| GenericDrugNdc1 | varchar(50) | YES | | NDC code for generic #1 |
| GenericDrugNdc2 | varchar(50) | YES | | NDC code for generic #2 |
| GenericDrugNdc3 | varchar(50) | YES | | NDC code for generic #3 |
| GenericDrugNdc4 | varchar(50) | YES | | NDC code for generic #4 |
| LastModified | datetime | YES | | audit timestamp |
| IsValid | bit | YES | | sampled values: `true` (2) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- Outbound (inferred):
  - `DrugKey` → `rxqDrug` (join col `DrugId`) — inferred, **high** confidence (100.0% referential match, not sampled — full check of 2 non-null values).
  - `GenericDrugKey1`–`GenericDrugKey4` — no inferred_relationships entries; naming suggests drug-key references but the extractor found no validated link (treat as unconfirmed/no evidence).
- Inbound (inferred): none.

**Indexes**

- `IX_DrugGenerics_GenericDrugKey1` (NONCLUSTERED, key: `GenericDrugKey1`)
- `IX_DrugGenerics_GenericDrugKey2` (NONCLUSTERED, key: `GenericDrugKey2`)
- `IX_DrugGenerics_GenericDrugKey3` (NONCLUSTERED, key: `GenericDrugKey3`)
- `IX_DrugGenerics_GenericDrugKey4` (NONCLUSTERED, key: `GenericDrugKey4`)

These four indexes each key a single `GenericDrugKeyN` column, indicating the table is queried by generic-drug lookup (reverse lookup: "what drugs list this generic as an equivalent") in addition to primary lookup by `DrugKey`.

**Gotchas**

- Varchar PK/key columns throughout (`DrugKey`, `GenericDrugKeyN`) rather than surrogate ints — typical Liberty pattern, but no referential integrity is enforced.
- Only 2 rows in RXCS and no inbound references from any other table — this table may be largely unused/deprecated in practice for this tenant, or generic mapping may be sourced elsewhere; low confidence in inferring its operational role from data alone.
- `GenericDrugKey1`–`4` have no validated inferred_relationships despite naming strongly suggesting they reference drug keys (likely `rxqDrug` or a generics master) — the extractor could not confirm this, possibly due to the tiny row count.

---

## `rxqDrugItemNumber`

Rows (RXCS): 4,987 | Columns: 5 | PK: `DrugKey`, `VendorId` | ETL-mirrored into `liberty_link_stage`: no

**Purpose**

Maps a drug (`DrugKey`, referencing `rxqDrug`) to a specific vendor's (`VendorId`) catalog/item number and acquisition data — i.e. a vendor-specific NDC/item-number crosswalk with per-vendor container acquisition cost (`VendorContainerACQ`) and a generic-equivalent flag (`VendorGeneric`) (inferred). This supports purchasing/procurement workflows where the same drug can be sourced from multiple wholesalers/vendors, each with its own item number and pricing (inferred). Not mirrored by ETL, suggesting it is used internally by the pharmacy system for purchasing rather than for downstream reporting/order data.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| VendorId | int | NO | PK | Part of composite PK; no lookup values sampled |
| DrugKey | varchar(50) | NO | PK, → `rxqDrug` | Part of composite PK; varchar surrogate key (not int) |
| ItemNumber | varchar(50) | YES | | Vendor's item/catalog number for this drug |
| VendorContainerACQ | float | YES | | Vendor container acquisition cost (price) |
| VendorGeneric | bit | YES | | Boolean flag, presumably whether vendor's item is the generic equivalent (inferred); no sampled values available |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**:
  - `DrugKey` → `rxqDrug` (join col `DrugId`) — inferred, **high** confidence (99.72% referential match, 4,987 non-null / 14 orphans, not sampled — full check)
- **Inbound (inferred)**: none

**Indexes**

- `_dta_index_rxqDrugItemNumber_195_1557580587__K2_K1_3_4` (NONCLUSTERED, non-unique) — key cols `DrugKey, VendorId`, includes `ItemNumber, VendorContainerACQ`. This is a DTA-generated covering index but its key/include shape usefully mirrors the PK-based lookup path (drug → vendor item/cost), so it's worth noting as the real access pattern for this table.

**Gotchas**

- `DrugKey` is a varchar(50) surrogate, not the more common int `DrugId` — the ~0.28% orphan rate (14 rows) implies a small number of stale/deleted-drug references.
- No FK constraints exist anywhere in Liberty (schema-wide convention) — all relationships here are naming/data-inferred only.
- `lookups` is empty for this table (no small coded columns sampled), so `VendorGeneric`'s bit semantics (0/1 meaning) is inferred from its name only, not confirmed by sampled data.
- `VendorId` has no companion vendor-lookup table in this metadata (`inferred_relationships` is limited to `DrugKey`), so the vendor identity/name behind `VendorId` cannot be resolved from this table alone.

---

## `rxqDrugGPICategories`

Rows: 101 (RXCS) | Columns: 4 | PK: `cDrugGPINotesID` | ETL-mirrored into liberty_link_stage: no

**Purpose**
Maps GPI (Generic Product Identifier) drug codes to named categories/notes keys, with an optional generic-vs-brand flag. The unique composite index on (`CategoryKey`, `GPI`) indicates each row associates one category label with one specific GPI code, and a given GPI can belong to multiple categories (no unique constraint on `GPI` alone) (inferred). This looks like a small reference/lookup table used to tag or classify drugs (e.g., for pharmacy note triggers, category-based rules, or reporting) rather than a transactional table — 101 rows is consistent with a curated code list (inferred). No FK to a drug master table is declared or inferable from this metadata alone, so the exact linkage to `rxqDrug`/GPI master data cannot be confirmed here.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `cDrugGPINotesID` | int | No | PK | identity |
| `CategoryKey` | varchar(50) | No | | part of unique composite index `unKeyGPI` with `GPI`; indexed alone via `IX_NoteKey` |
| `GPI` | varchar(50) | No | | GPI drug code, stored as varchar (not numeric); indexed alone via `IX_GPI` and as part of `unKeyGPI` |
| `GenericOrBrand` | char(1) | Yes | | likely coded flag (e.g., G/B) but no sampled values present in `lookups` — domain not confirmed here |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no inferred_relationships were detected for this table (no naming-based candidate columns resolved to a parent key, or none passed validation).
- **Inbound (inferred):** none — no other table's columns were inferred to reference this table.

All relationship inference here is naming/data-driven, not schema-declared; the absence of edges means no candidate join was found automatically, not that no relationship exists. In particular, a link from `GPI` to a drug-master table (e.g., `rxqDrug`) is plausible functionally but was not surfaced by the inference pass and should be treated as unconfirmed.

**Indexes**
- `unKeyGPI` (unique, NONCLUSTERED) on (`CategoryKey`, `GPI`) — enforces one row per category/GPI pair; primary lookup path for "is this GPI tagged with this category".
- `IX_GPI` (NONCLUSTERED) on `GPI` — supports lookups by drug code across categories.
- `IX_NoteKey` (NONCLUSTERED) on `CategoryKey` — supports lookups of all GPIs under a given category.

**Gotchas**
- `GPI` is stored as `varchar(50)`, not a numeric/fixed-length code — verify formatting/padding conventions before joining against other GPI columns elsewhere in the schema.
- `lookups` is empty for `CategoryKey` and `GenericOrBrand`, so their coded/enum domains are not documented in this extract — do not assume values (e.g., don't guess `GenericOrBrand` is literally 'G'/'B') without checking live data.
- No declared or inferred FK ties this table to a drug master (`rxqDrug`) or note-definition table despite the naming (`cDrugGPINotesID`, `CategoryKey` suggesting "notes"); confirm the real join path before relying on it in code.

---

## `rxqDrugImmunizationDose`

Rows (RXCS): 1 | Columns: 7 | PK: `DrugImmunizationDoseId` | ETL-mirrored into liberty_link_stage: no

**Purpose** — Defines a per-dose schedule template for immunization drugs: for a given `DrugId`, a `DoseNumber` (e.g. dose 1, 2, 3 in a series) with `DaysUntilNextDose` to the following dose, an optional `ImmunizationFeeOverride`, and a link to a `TemplateId` (inferred: likely a documentation/consent template used at administration). This supports multi-dose immunization series (e.g. 2- or 3-shot regimens) by letting the system prompt the next dose date and apply a dose-specific fee (inferred — no columns directly evidence "immunization consent" beyond naming/domain convention). Table currently holds only 1 row in RXCS, so it is sparsely populated / possibly used for only one drug's dosing schedule at present.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| DrugImmunizationDoseId | int | NO | PK | identity |
| DrugId | varchar(50) | YES | → `rxqDrug` | |
| DoseNumber | int | YES | | ordinal position of dose in series (inferred) |
| DaysUntilNextDose | int | YES | | interval to next scheduled dose (inferred) |
| ImmunizationFeeOverride | decimal(9,2) | YES | | overrides standard immunization admin fee for this dose (inferred) |
| TemplateId | int | YES | | likely FK to a document/consent template table (inferred, not resolvable — no matching table found by naming) |
| LastModified | datetime | YES | | audit timestamp |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**:
  - `DrugId` → `rxqDrug` — inferred, **high** confidence (100.0% referential match, not sampled; based on only 1 non-null value).
- **Inbound (inferred)**: none.

These edges are inferred purely from column naming and then data-validated against actual key values in the referenced table — they are not enforced database constraints. Given the table has only 1 row, the 100% match rate for `DrugId` should be treated as directionally suggestive rather than statistically robust.

**Indexes** — none defined.

**Gotchas**
- Only 1 row present in RXCS — this feature/table appears minimally used or in early/limited rollout; do not assume broad coverage of immunization drugs.
- `DrugId` is varchar(50) despite typically referencing a numeric-style drug identifier elsewhere — consistent with Liberty's general pattern of string-typed keys.
- `TemplateId` has no discoverable referenced table by naming convention in this extract; treat its target as unknown/undocumented.
- Not mirrored by ETL, so this data is invisible to eMed/liberty_link_stage-side reporting and joins.

---

## `rxqUserDrugClass`

Rows (RXCS): 4 | Columns: 9 | PK: `DrugKey`, `ClassIdCode` (composite) | ETL-mirrored into liberty_link_stage: no

**Purpose**: A user-defined drug classification/tagging table, associating a drug (`DrugKey`) with a custom class code (`ClassIdCode`) — e.g. a pharmacy-configurable grouping label layered on top of standard NCPDP/therapeutic classes (inferred). Audit-style columns (`DateAddedYYYYMMDD`, `TimeAddedHHMMSS`, `AddedByUser`, `LastModified`, `IsValid`) suggest each row is a manually-entered tag/annotation on a drug record rather than a system-generated relationship (inferred). Very low row count (4) at RXCS indicates this is a lightly-used or legacy custom-classification feature, not a core dispensing table (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cUserDrugClassId | int | NO | | identity |
| DrugKey | varchar(50) | NO | PK, → `rxqDrug` | part of composite PK |
| ClassIdCode | varchar(50) | NO | PK | part of composite PK; user-defined class code, no lookup domain sampled |
| DateAddedYYYYMMDD | varchar(50) | YES | | date stored as string, YYYYMMDD format (per name) |
| TimeAddedHHMMSS | varchar(50) | YES | | time stored as string, HHMMSS format (per name) |
| AddedByUser | varchar(50) | YES | | free-text/user-id of creator, no lookup domain sampled |
| FreeTextFld | varchar(50) | YES | | generic free-text field, no lookup domain sampled |
| LastModified | datetime | YES | | native datetime, unlike the string-based Added fields |
| IsValid | bit | YES | | sampled domain: `true` (4/4 rows) — no `false` rows observed in this sample |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**:
  - `DrugKey` → `rxqDrug` (join col `DrugId`) — inferred, **high** confidence (100.0% referential match, not sampled — full check on 4 non-null values, 0 orphans)
- **Inbound (inferred)**: none

These edges are inferred purely from column naming conventions and then data-validated by checking actual value overlap against the candidate parent table's key column — they are NOT enforced database constraints.

**Indexes**: none declared (indexes list empty).

**Gotchas**
- Composite varchar PK (`DrugKey` + `ClassIdCode`) rather than the identity column `cUserDrugClassId` — the identity column looks like it should be the PK but isn't declared as one.
- Date/time split across two string columns (`DateAddedYYYYMMDD`, `TimeAddedHHMMSS`) instead of a single datetime, while `LastModified` uses native datetime — inconsistent audit-field pattern typical of legacy Liberty tables.
- Only 4 rows sampled at RXCS — too small to reliably characterize `ClassIdCode`'s full value domain; treat any conclusions about its coding scheme as unconfirmed.
- Not ETL-mirrored into liberty_link_stage, so this data is invisible to eMed-side reporting/queries unless sourced directly from Liberty.

---

## `rxqClinicalLookup`

Rows (RXCS): 150,445 | Columns: 2 | PK: `NdcNumber` | ETL-mirrored into liberty_link_stage: no

**Purpose** — A drug-level clinical flag lookup keyed by NDC number, storing a single boolean attribute, `Hazardous`, per NDC. (inferred) It functions as a reference/enrichment table that other drug and inventory tables join against by NDC to determine hazardous-drug handling status (e.g., for compounding, receiving, or transfer workflows), consistent with its being referenced by `rxqDrug`, `rxqDrugBatchCompoundIngredient`, `rxqAcceptInventoryDetail`, `rxqCouponDrug`, and `rxqInventoryTransferLine`. No PHI or transactional data is present — only a static NDC-to-flag mapping.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `NdcNumber` | varchar(50) | NOT NULL | PK | Referenced by (inbound) `rxqDrug.NdcNumber`, `rxqDrugBatchCompoundIngredient.NDCNumber`, `rxqAcceptInventoryDetail.NDCNumber`, `rxqCouponDrug.NdcNumber`, `rxqInventoryTransferLine.NdcNumber` |
| `Hazardous` | bit | NULL | — | Boolean flag; no sampled values available (not in lookups) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none.
- **Inbound (inferred)** — other tables' NDC columns inferred to reference this table's `NdcNumber`, DATA-VALIDATED against actual key values (not declared constraints):
  - `rxqDrugBatchCompoundIngredient.NDCNumber` → this table — inferred, **low** confidence (57.84% referential match)
  - `rxqDrug.NdcNumber` → this table — inferred, **low** confidence (37.47% referential match)
  - `rxqAcceptInventoryDetail.NDCNumber` → this table — inferred, **no-data** confidence (no match rate available)
  - `rxqCouponDrug.NdcNumber` → this table — inferred, **no-data** confidence (no match rate available)
  - `rxqInventoryTransferLine.NdcNumber` → this table — inferred, **no-data** confidence (no match rate available)

**Indexes** — none defined (empty index list).

**Gotchas**
- All inbound edges are **low confidence or no-data** — most referencing tables' NDC values do NOT reliably resolve into this table's key (e.g., only ~37-58% match for `rxqDrug`/`rxqDrugBatchCompoundIngredient`, and three tables show no validated match data at all). This table should be treated as a partial/incomplete NDC universe, not an authoritative full drug master — do not assume a join here will always resolve.
- No indexes beyond the implicit PK are defined, despite being a high-row-count (150K+) lookup target for multiple tables — joins against it rely solely on the varchar PK.
- Varchar PK (`NdcNumber`, up to 50 chars) rather than a numeric/normalized NDC format — formatting inconsistencies (leading zeros, dashes, package-code variants) across source tables likely explain the low match rates.
- `Hazardous` has no sampled lookup values, so its coded domain (true/false/null semantics, e.g. USP <800> hazardous-drug designation) is unconfirmed from data alone.

---

## `DigitalPatientEducation`

Rows (RXCS): 96 | Columns: 3 | PK: `NDC`, `LanguageCode` (composite) | ETL-mirrored into `liberty_link_stage`: no

**Purpose** — Maps an NDC (drug product identifier) plus a language code to a `URL`, i.e. a lookup table of patient-education document links keyed by drug and language (inferred). The composite PK (`NDC`, `LanguageCode`) means each drug can have one education link per language. In the sampled data every row's `LanguageCode` is `"eng"`, so only English-language links are populated in this instance (inferred: multi-language support exists in the schema but is unused/incomplete here). Not mirrored by ETL, so this table is not available in `liberty_link_stage`/eMed downstream reporting.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| NDC | varchar(50) | NOT NULL | PK | Drug product identifier (National Drug Code), no declared/inferred FK to a drug master table |
| LanguageCode | varchar(3) | NOT NULL | PK | Sampled values: `eng` (96/96 — only value observed) |
| URL | varchar(max) | NOT NULL | | Link to the patient-education document/page |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no `implicit_ref` or inferred_relationships detected for `NDC` or `LanguageCode` (e.g. no validated link to an NDC/drug master table in this extract).
- **Inbound (inferred):** none — no other table's columns were found to reference `DigitalPatientEducation`.

**Indexes** — none defined (empty index list; only the implicit PK constraint enforces uniqueness on `NDC`+`LanguageCode`).

**Gotchas**
- No FK to any drug/NDC master table (e.g. an `rxqDrug`-style table) was declared or inferred — `NDC` is a free-form varchar(50) with no referential validation shown in this extract, so orphaned/mistyped NDCs are possible.
- `LanguageCode` is 100% `"eng"` in the sampled 96 rows — treat any assumption of multi-language coverage as unconfirmed; the column exists but appears effectively unused for other languages.
- Not ETL-mirrored, so any consumer needing this data (e.g. surfacing education links in eMed) must query Liberty directly per-tenant (rxcs/mmed/mdvo) rather than via `liberty_link_stage`.

---

## `DrugUnitMultiplier`

Rows (RXCS): 6,410 | Columns: 4 | PK: `Id` | ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores a per-drug unit-conversion factor: each row ties a `DrugId` to a decimal `Value` (18,5 precision), suggesting a multiplier used to convert between dispensing units (e.g., package-to-billing-unit, or NDC-package-size-to-metric-quantity conversions) for that drug (inferred). The `Modified` timestamp indicates rows are maintained/updated over time rather than being static reference data. Not currently pulled into the eMed ETL mirror, so this table is invisible to eMed today.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| Id | int | NO | PK | identity |
| DrugId | varchar(50) | NO | → `rxqDrug` | |
| Value | decimal(18,5) | NO | (see Relationships — spurious inferred link) | the conversion multiplier itself |
| Modified | datetime | NO | | last-updated timestamp |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**
  - `DrugId` → `rxqDrug` — inferred, **high** confidence (95.9% referential match; 260 of 6,410 non-null values are orphans).
  - `Value` → `DiscountCard` — inferred, **unvalidated** (parent table `DiscountCard` is empty, so the match rate could not be computed). This is almost certainly a spurious name/type collision from column-naming inference, not a real relationship — `Value` is a decimal multiplier, not an identifier — treat as noise.
- **Inbound (inferred)**: none.

**Indexes**
None declared (empty index list) — no explicit indexes on `DrugId` or `Value`; any join/lookup by drug relies on a table scan or the clustered PK.

**Gotchas**
- `DrugId` is a varchar(50) natural key (not the int surrogate `Id`), consistent with Liberty's drug-identifier convention elsewhere, but only 95.9% resolve to `rxqDrug` — roughly 260 rows reference a `DrugId` not present in `rxqDrug` (deleted/renamed drugs, or a differently-scoped identifier).
- The `Value`→`DiscountCard` inferred edge is a false positive from the metadata inference process (matched on generic column name `Value` against an empty table) — do not treat it as a real relationship.
- No lookups/enum columns present (table has no small coded columns sampled).
- Not ETL-mirrored: any eMed feature needing drug unit-conversion factors would need a new ETL pull.

---
