# Liberty schema — Inventory, Stock & Ordering

Perpetual drug inventory and its high-volume movement logs, categories, vendors and preferred-vendor mapping, purchase order lines/defaults, and stock returns.

> Part of the [Liberty/RxQ schema reference](../README.md). Liberty declares **no foreign-key constraints** (verified via `sys.foreign_keys`), so all relationships shown are **inferred from column naming and then data-validated** by referential match rate — each is tagged high / medium / low / no-data / unvalidated confidence. Row counts and sampled enum values are from the RXCS instance (point-in-time); the schema itself is identical across the rxcs / mmed / mdvo tenants.

**Tables in this module (12):** [`rxqDrugInventory`](#rxqdruginventory) · [`rxqDrugInventoryLogMaster`](#rxqdruginventorylogmaster) · [`rxqDrugInventoryLogChange`](#rxqdruginventorylogchange) · [`rxqDrugInventoryLogOperation`](#rxqdruginventorylogoperation) · [`rxqCategories`](#rxqcategories) · [`rxqVendor`](#rxqvendor) · [`DrugPreferredVendor`](#drugpreferredvendor) · [`rxqOrderLine`](#rxqorderline) · [`rxqOrderDefaults`](#rxqorderdefaults) · [`StockReturnHistory`](#stockreturnhistory) · [`PendingStockReturn`](#pendingstockreturn) · [`rxqPendingStockReturn`](#rxqpendingstockreturn)

---

## `rxqDrugInventory`

Rows: 2,550 (RXCS) · Columns: 12 · PK: (`DrugInventoryKey`, `StoreNumber`) composite · ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores per-store, per-drug inventory control settings and current stock level — quantity on hand (`QtyInStock`), reorder threshold/quantity (`ReorderPoint`/`ReorderQty`), and a "snooze" mechanism (`SnoozeOrder`/`SnoozeUntil`) to temporarily suppress reorder alerts for a drug at a store (inferred). The composite key on `DrugInventoryKey`+`StoreNumber` indicates inventory is tracked independently per pharmacy location/tenant store, not globally. `IsValid` (2,487 true / 63 false) acts as a soft-delete/active flag, and the sole non-unique index is built around (`StoreNumber`, `IsValid`, `DrugInventoryKey`) — the shape of the primary access pattern is "active inventory rows for a given store" (inferred). `InventoryType` is almost entirely 0 (2,547 rows) with a rare value of 1 (3 rows), suggesting a default inventory class plus one uncommon alternate type (meaning of 0/1 not documented in metadata). `ContainerQuantityPartition` (bit) likely flags whether stock is tracked/partitioned by container rather than as a single pooled quantity (inferred, not confirmed by data).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cDrugInventoryId | int | NOT NULL | | identity (auto-increment surrogate) |
| DrugInventoryKey | varchar(50) | NOT NULL | PK | part of composite PK; no inferred outbound reference despite naming suggesting a drug/product link |
| QtyInStock | decimal(12,3) | NULL | | current on-hand quantity |
| ReorderPoint | decimal(12,3) | NULL | | stock level threshold that triggers reorder |
| ReorderQty | decimal(12,3) | NULL | | quantity to reorder when triggered |
| LastModified | datetime | NULL | | last update timestamp |
| IsValid | bit | NOT NULL | | active/soft-delete flag — sampled values: `true` (2,487), `false` (63) |
| StoreNumber | varchar(50) | NOT NULL | PK | part of composite PK; per-tenant/store scoping, no inferred outbound reference |
| SnoozeOrder | bit | NULL | | suppresses reorder alert when set (inferred) |
| SnoozeUntil | datetime | NULL | | expiry of the snooze window (inferred) |
| InventoryType | int | NULL | | sampled values: `0` (2,547), `1` (3) — coded domain, meaning undocumented |
| ContainerQuantityPartition | bit | NULL | | flags container-based quantity partitioning (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no inferred_relationships were detected/data-validated for this table. Note: `DrugInventoryKey` and `StoreNumber` read like references to a drug master table and a store/pharmacy-location table respectively, but no such edge was inferred or validated here — treat any drug/store linkage as an unconfirmed guess, not a documented relationship.
- **Inbound (inferred):** none — no other table's columns were inferred/data-validated to reference this table.

**Indexes**

- `IDX_DrugInventory_IsValidDrugInventoryKeyStoreNumber` (NONCLUSTERED, non-unique) on (`StoreNumber`, `IsValid`, `DrugInventoryKey`) — supports the "active rows for a store" lookup pattern.

**Gotchas**

- Both PK components (`DrugInventoryKey`, `StoreNumber`) are `varchar(50)`, not integer surrogate keys — join carefully on exact string match, watch for casing/padding drift.
- No inferred or declared relationships exist for this table at all, despite column names (`DrugInventoryKey`, `StoreNumber`) strongly suggesting FK-like links to drug and store master tables — this schema slice gives no basis to confirm those links; do not assume referential integrity.
- `cDrugInventoryId` (identity int) duplicates `DrugInventoryKey` (varchar business key) as a row identifier — two parallel keys, be explicit about which one downstream code/joins expect.
- `InventoryType` value 1 is rare (3 of 2,550 rows) — any logic branching on it will be exercised by almost no data; treat as effectively untested edge case.
- Not mirrored by ETL into liberty_link_stage — eMed-side reporting/queries cannot rely on this table; inventory data must be sourced live from Liberty or a separate feed if needed.

---

## `rxqDrugInventoryLogMaster`

Rows (RXCS): 675,756 | Columns: 12 | PK: `id` | ETL-mirrored into `liberty_link_stage`: no

**Purpose**

Audit/log table recording inventory-affecting events against `DrugInventoryId` records — each row captures an `Operation` code, the `UserId`/`User` who performed it, an optional `ScriptId` (fill/dispense that consumed stock) or `PurchaseOrderId` (receipt that added stock), a free-text `Note`, and a `ModifiedDate` timestamp, scoped per `StoreNumber` (inferred). It functions as an append-only inventory transaction/event log rather than a current-state table (inferred, based on `Operation` code column referencing `rxqAuditLogMasterOperation` and near-complete nullability of the transaction-source columns `ScriptId`/`PurchaseOrderId`/`Note`). `cCategoryId` and `AcceptInventoryId` appear to be sparsely-used adjunct fields (cCategoryId is non-null in only ~121 of 675,756 rows).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `id` | int | NO | PK | identity |
| `DrugInventoryId` | varchar(50) | NO | | subject inventory record (no validated parent table) |
| `UserId` | varchar(50) | YES | | actor identifier |
| `User` | varchar(50) | YES | | actor display name/username |
| `Operation` | int | NO | → `rxqAuditLogMasterOperation` | coded operation type |
| `ScriptId` | varchar(50) | YES | | linked script/fill, when operation is dispense-driven |
| `PurchaseOrderId` | varchar(50) | YES | | linked PO, when operation is receipt-driven |
| `Note` | varchar(512) | YES | | free-text annotation |
| `ModifiedDate` | datetime | NO | | event timestamp |
| `StoreNumber` | varchar(50) | NO | | store/location scope |
| `cCategoryId` | int | YES | → `rxqCategories` | sparse (675,635 of 675,756 rows NULL); sampled non-null values: 2 (71), 12 (32), 8 (8), 0 (6), 4 (3), 5 (1) |
| `AcceptInventoryId` | int | YES | | no validated parent; likely links to an acceptance/receiving inventory record (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**
  - `cCategoryId` → `rxqCategories` (join col `cCategoryId`) — inferred, **high** confidence (95.0% referential match, sampled; 121 non-null, 6 orphans)
  - `Operation` → `rxqAuditLogMasterOperation` — inferred, **unvalidated** (no matching parent key column found to validate against; treat as a weak/unconfirmed naming-based guess)
- **Inbound (inferred)**: none

**Indexes**

None reported (no indexes present on this table).

**Gotchas**

- All "foreign" identifiers (`DrugInventoryId`, `ScriptId`, `PurchaseOrderId`, `UserId`, `StoreNumber`) are stored as `varchar(50)` rather than typed/int keys, and none were data-validated against a parent table in this pass (no `implicit_ref` or inferred edge beyond `cCategoryId`/`Operation`) — treat any cross-table join on these as unverified.
- `cCategoryId` is almost entirely NULL (99.98%) despite having the strongest validated relationship in the table (95% match on the tiny non-null subset) — do not assume this column is generally populated or reliable for broad analysis.
- No indexes exist, including none on the PK's natural lookup columns (`DrugInventoryId`, `ScriptId`, `PurchaseOrderId`) — full-table scans are likely for any filtered query against this 675K-row log.
- Table is not ETL-mirrored to `liberty_link_stage`, so it is invisible to eMed-side reporting/tooling; any consumer needing this data must query Liberty/RxQ directly.

---

## `rxqDrugInventoryLogChange`

Rows (RXCS): 691,346 | Columns: 6 | PK: `id` | ETL-mirrored into liberty_link_stage: no

**Purpose**
Append-only audit/change log recording individual property-level mutations to a drug inventory record, keyed by `MasterId` (inferred: parent inventory row, likely a `rxqDrugInventory`-style table, but no data-validated relationship exists to confirm this). Each row captures which field changed (`PropertyChanged`), the delta (`ChangeAmount`), and the before/after values (`ValueBeforeChange`/`ValueAfterChange`) — a classic before/after audit-trail pattern for tracking inventory quantity or attribute adjustments over time (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `id` | int | NO | PK | identity |
| `MasterId` | int | NO | | no data-validated FK match; indexed (`IX_DrugInventoryLogChange_MasterId`); presumed parent inventory record ID (inferred) |
| `PropertyChanged` | varchar(50) | NO | | name of the field/property that was mutated; not present in lookups, no sampled enum values available |
| `ChangeAmount` | decimal(12,3) | NO | | delta applied to the property |
| `ValueAfterChange` | decimal(12,3) | NO | | resulting value post-change |
| `ValueBeforeChange` | decimal(12,3) | NO | | value prior to change |

**Relationships**
Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no inferred_relationships were detected/data-validated for this table (in particular, `MasterId` has no confirmed parent-table match despite being indexed).
- **Inbound (inferred):** none reported.

**Indexes**
- `IX_DrugInventoryLogChange_MasterId` (NONCLUSTERED, non-unique) on `MasterId` — the primary lookup path for pulling a given inventory record's change history; confirms `MasterId` is the operative join column even though no referential match was data-validated against a candidate parent table.

**Gotchas**
- `MasterId` strongly resembles a foreign key by naming/indexing convention but has zero data-validated inferred relationship — treat any assumed parent table (e.g., a drug-inventory master table) as unconfirmed.
- `PropertyChanged` is a free-text/coded field name with no sampled lookup values in this extract, so its domain (e.g., "OnHandQty", "Cost") is unknown from metadata alone — do not assume specific values.
- Not mirrored by ETL into liberty_link_stage, so this audit history is not queryable from the eMed side; any investigation requires direct Liberty DB access.

---

## `rxqDrugInventoryLogOperation`

Rows (RXCS): 14 | Columns: 2 | PK: `id` | ETL-mirrored into `liberty_link_stage`: no

**Purpose**

A tiny lookup/reference table holding a static list of named "operation" codes (`operation` varchar(100)), keyed by a surrogate identity `id`. Given the table name, it (inferred) enumerates the distinct operation types that can appear in a drug-inventory audit/log trail (e.g. receive, adjust, dispense, waste, transfer) — analogous in shape to `rxqAuditLogMasterOperation`, which its one column names as a naming-inferred peer. With only 14 rows and no FK enforcement, it functions as a small reference/enum table rather than a transactional one.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `id` | int | NOT NULL | PK | identity |
| `operation` | varchar(100) | NOT NULL | → `rxqAuditLogMasterOperation` (unconfirmed, see below) | no sampled lookup values available (lookups empty) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):**
  - `operation` → `rxqAuditLogMasterOperation.operation` — inferred from column naming, **low** confidence (0.0% referential match; 14/14 non-null values are orphans, not sampled). This is a weak/unconfirmed guess — the column name coincidentally matches a column in `rxqAuditLogMasterOperation`, but none of this table's 14 values were found there, so the two tables likely hold independent/non-overlapping operation vocabularies rather than a real parent-child link.
- **Inbound (inferred):** none.

**Indexes**

None declared beyond the implicit PK/identity on `id`.

**Gotchas**

- The sole non-key column (`operation`) has a naming-based inferred edge to `rxqAuditLogMasterOperation`, but the 0% match rate strongly suggests this is a false positive from name similarity, not a real relationship — treat the two "operation" tables as separate, unrelated vocabularies until proven otherwise.
- No `lookups` were sampled for `operation`, so its actual enum domain (the 14 values) is unknown from this metadata extract alone.
- Not mirrored by ETL, so it is not queryable via `liberty_link_stage`; any consumption requires direct Liberty DB access.

---

## `rxqCategories`

Rows: 19 (RXCS) · Columns: 10 · PK: `cCategoryId` · ETL-mirrored into liberty_link_stage: no

**Purpose**

A small reference/lookup table of category records (19 rows) used to classify inventory items, keyed by `cCategoryId` with a `CategoryName`/`Type` label pair, a display `Color`, an `Active` flag, and a `Sequence` for ordering. `rxqDrugInventoryLogMaster.cCategoryId` references this table with a 95.04% match rate (high confidence), indicating its primary role is categorizing drug inventory log entries (inferred). The `System`/`RtsSellWarning`/`RtsDefaultType` columns suggest some rows are system-reserved categories carrying return-to-stock (RTS) sell-warning behavior and a default RTS type (inferred, based on column naming — no declared semantics available).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `cCategoryId` | int | NO | PK | identity |
| `CategoryName` | varchar(50) | YES | | |
| `Type` | varchar(50) | YES | | |
| `Color` | int | YES | | sampled values: null (10), -393211 (2), -128 (1), -14878 (1), -557312 (1), -3479809 (1), -11534336 (1), -12080649 (1), -16406762 (1) — signed int color codes (likely ARGB/OLE color values) |
| `Active` | bit | NO | | sampled values: true (19) — all 19 sampled rows are active |
| `Source` | int | YES | | sampled values: 0 (9), 1 (8), 2 (2) — coded domain, meaning not derivable from metadata |
| `Sequence` | int | YES | → `BillingEvents` (weak, see Relationships) | |
| `System` | bit | YES | | no sampled lookup values available |
| `RtsSellWarning` | bit | YES | | no sampled lookup values available |
| `RtsDefaultType` | int | YES | | sampled values: null (17), 1 (1), 0 (1) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

These are all INFERRED from column naming and then DATA-VALIDATED against actual values — not declared constraints.

- **Outbound (inferred):**
  - `Sequence` → `BillingEvents` (join col `Sequence`) — inferred, **unvalidated** (parent table empty; match rate not computable). Treat as an unconfirmed guess only.

- **Inbound (inferred):**
  - `rxqDrugInventoryLogMaster.cCategoryId` → this table's `cCategoryId` — inferred, **high** confidence (95.04% referential match).

**Indexes**

None reported (empty `indexes[]` for this table — no informative or auto-generated indexes surfaced).

**Gotchas**

- `Sequence` looks like a plain ordering/sort column by name, but the metadata's naming-based inference maps it to `BillingEvents`; that edge is unvalidated (parent empty) and should be treated as noise, not a real relationship — the column is more plausibly just a display-order field for category lists (inferred).
- `Color` stores negative int values consistent with signed 32-bit ARGB/OLE color encoding rather than an RGB triplet or hex string — consumers must bit-decode rather than treat as a simple palette index.
- `System` and `RtsSellWarning` have no sampled values in this extract, so their true coded/boolean usage can't be confirmed from this data alone.
- Not ETL-mirrored into liberty_link_stage — any eMed-side reporting needing category names/colors must query Liberty directly or via a future mirror.

---

## `rxqVendor`

Rows (RXCS): 56 | Columns: 16 | PK: `cVendorId` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores pharmaceutical wholesaler/vendor master records used for drug procurement — name, active/primary status, and per-vendor generic/brand pricing rate multipliers (`GenericRate`, `BrandRate`). The `UseInRXQ`/`UseInBZQ` and `PrimaryVendorRXQ`/`PrimaryVendorBZQ` column pairs indicate this vendor list is shared across two Liberty subsystems (inferred: RXQ = retail/Rx queue, BZQ = a second queue/workflow, possibly compounding or a business line), each with its own "use this vendor" and "primary vendor" flags. `DscsaProvider` and `System`/`SystemKey` suggest integration with DSCSA (Drug Supply Chain Security Act) track-and-trace data providers per vendor. `IsFlavoRx` flags vendors supplying FlavoRx flavoring products (inferred). Inbound references from `rxqAcceptInventory` and `rxqAuditLogMaster` indicate this table anchors vendor identity for inventory receiving and audit logging, though referential match rates could not be validated (no-data).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cVendorId | int | NO | PK | identity |
| VendorName | varchar(50) | YES | | |
| Notes | varchar(500) | YES | | |
| System | bit | NO | | |
| SystemKey | char(3) | YES | | indexed (IX_SystemKey) |
| Active | bit | NO | | indexed (IX_Active); sampled values: `false` (55), `true` (1) |
| PrimaryVendor | bit | NO | | |
| GenericRate | decimal(9,3) | YES | | |
| BrandRate | decimal(9,3) | YES | | |
| CustomerNumber | varchar(200) | YES | | |
| UseInRXQ | bit | YES | | |
| UseInBZQ | bit | YES | | |
| PrimaryVendorRXQ | bit | YES | | |
| PrimaryVendorBZQ | bit | YES | | |
| DscsaProvider | varchar(50) | YES | | |
| IsFlavoRx | bit | YES | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none.
- **Inbound (inferred):**
  - `rxqAcceptInventory.cVendorId` → this table — inferred, **no-data** confidence (referential match not computable).
  - `rxqAuditLogMaster.cVendorId` → this table — inferred, **no-data** confidence (referential match not computable).

These inbound edges are naming-based guesses only, not validated by data (no-data confidence means the check could not be run, e.g. parent/child sampling gap) — treat as unconfirmed.

**Indexes**

- `IX_Active` (nonclustered, key: `Active`) — supports lookup of active vendors.
- `IX_SystemKey` (nonclustered, key: `SystemKey`) — supports lookup by external system key.

**Gotchas**

- Only 1 of 56 sampled vendors is `Active = true` — the `Active` flag's real-world meaning/usage should be confirmed before relying on it to filter "current" vendors.
- Dual RXQ/BZQ flag pairs (`UseInRXQ`/`PrimaryVendorRXQ` vs `UseInBZQ`/`PrimaryVendorBZQ`) imply this single vendor list is shared/overloaded across two distinct Liberty workflows — check which subsystem a consumer cares about before filtering just on `PrimaryVendor`.
- Not ETL-mirrored to liberty_link_stage, so eMed-side reporting/joins cannot reference vendor names directly without a separate extract.
- Inbound relationships are unvalidated (no-data) — do not assume referential integrity from `rxqAcceptInventory`/`rxqAuditLogMaster` without direct verification.

---

## `DrugPreferredVendor`

Rows (RXCS): 1,059 | Columns: 3 | PK: `DrugId, StoreNumber, VendorId` | ETL-mirrored into liberty_link_stage: no

**Purpose**
A pure association/mapping table linking a drug (`DrugId`), a store location (`StoreNumber`), and a vendor (`VendorId`) — no other attribute columns exist beyond the composite key. It records which vendor(s) are preferred/eligible for purchasing a given drug at a given store (inferred), supporting purchasing/ordering workflows where a store may source the same drug from multiple vendors, or where drug-vendor eligibility varies per store. The composite PK means a row exists per unique (drug, store, vendor) combination, with no ranking/priority column to indicate a single "most preferred" vendor beyond membership in this table (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| DrugId | varchar(50) | NO | PK, → `rxqDrug` | part of composite PK |
| StoreNumber | varchar(50) | NO | PK | part of composite PK; no inferred parent table detected |
| VendorId | int | NO | PK | part of composite PK; no inferred parent table detected |

**Relationships**
Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**:
  - `DrugId` → `rxqDrug` — inferred, **high** confidence (100.0% referential match, not sampled — full check).
- **Inbound (inferred)**: none.

**Indexes**
None reported (no index metadata present beyond the implicit composite PK).

**Gotchas**
- `StoreNumber` and `VendorId` have no detected inferred parent table in this extract — likely reference a Stores/Locations table and a Vendors table respectively that either weren't included in this metadata pass or don't match on naming/data patterns; treat their intended targets as unconfirmed.
- `DrugId` and `StoreNumber` are varchar(50) despite representing what are likely numeric identifiers elsewhere in Liberty — join carefully on type/format (e.g. padding, leading zeros) when relating to other tables.
- No non-key attribute columns (e.g. priority/rank, effective dates, active flag) — the table only expresses set membership, not preference ordering or vendor pricing/contract terms.

---

## `rxqOrderLine`

Rows (RXCS): 23. Columns: 28. PK: `cOrderLineId`. ETL-mirrored into liberty_link_stage: no.

**Purpose**

Stores individual line items of a purchasing/inventory order — one row per item ordered from a vendor, with requested vs. confirmed quantity, cost/ACQ pricing, NDC/UPC and vendor identity (inferred, from `Qty`/`RequestedQty`/`UpdatedQty`, `Cost`, `ACQ`, `VendorName`/`VendorId`, `NDCUPC`/`RequestedNDCUPC`). It appears to be the RxQ inventory-ordering subsystem's line-item table (name prefix `rxq`), tracking substitution and confirmation workflow against a purchase order referenced by `OrderId`/`OrderNumber` and an order confirmation referenced by `OrderConfirmationId` (inferred; no validated relationship exists to confirm the parent table). `RxqId` and `BzqId` are indexed varchar identifiers, likely cross-references to external/vendor order systems or RxQ/BuyLine order queues (inferred — meaning not confirmed by data). This table is tiny (23 rows) and not part of the ETL mirror, so it is not currently surfaced in eMed.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cOrderLineId | int | NO | PK | identity |
| Origin | nvarchar(50) | YES | | |
| Status | varchar(200) | YES | | |
| RxqId | varchar(50) | YES | | indexed (non-unique) |
| BzqId | varchar(50) | YES | | indexed (non-unique) |
| Qty | decimal(9,3) | YES | | |
| AllowSubstitution | bit | YES | | |
| Description | varchar(150) | YES | | |
| OrderId | int | YES | | indexed (clustered) |
| RequestedQty | decimal(9,3) | YES | | |
| UpdatedQty | decimal(9,3) | YES | | |
| Cost | decimal(9,2) | YES | | |
| VendorName | nvarchar(50) | YES | | |
| VendorId | int | YES | | |
| OrderNumber | nvarchar(50) | YES | | |
| NDCUPC | nvarchar(50) | YES | | |
| LastChanged | datetime | YES | | |
| ConfirmationNote | nvarchar(max) | YES | | |
| RequestedDescription | varchar(150) | YES | | |
| InventoryUpdated | bit | YES | | |
| ConfirmationMode | int | YES | | sampled values: `0` (count 23) — only value observed, domain likely wider |
| OrderLineType | int | YES | | sampled values: `null` (count 23) — all rows null in this sample |
| OrderConfirmationId | int | YES | | |
| RequestedItemNumber | varchar(200) | YES | | |
| RequestedNDCUPC | varchar(200) | YES | | |
| ACQ | decimal(12,5) | YES | | acquisition cost, 5-decimal precision |
| BulkOrder | bit | YES | | |
| UnexpectedLine | bit | YES | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no `implicit_ref` candidates were detected/validated for this table's columns (including `OrderId`, `OrderConfirmationId`, `VendorId`, `RxqId`, `BzqId`, despite naming that suggests parent tables; these are unconfirmed by the extraction and should be treated as unknown until independently validated).
- **Inbound (inferred):**
  - `rxqOrderDiscrepancyItem.cOrderLineId` → this table's PK — inferred, **no-data** confidence (match rate unavailable; likely the referencing table is empty or too small to sample).

All of the above are naming-based inferences, not enforced constraints — treat as weak/unconfirmed guesses, especially the no-data edge.

**Indexes**

- `OrderId` — CLUSTERED, non-unique, key `OrderId` — primary access path for pulling all line items belonging to a purchase order.
- `RxqId` — NONCLUSTERED, non-unique, key `RxqId` — lookup path by RxQ external identifier.
- `BzqId` — NONCLUSTERED, non-unique, key `BzqId` — lookup path by BuyLine/external order-queue identifier.

**Gotchas**

- Table is not ETL-mirrored, so any consuming code must query Liberty directly — no `liberty_link_stage` copy exists to join against.
- Extremely small live sample (23 rows) at RXCS; lookup domains for `ConfirmationMode`/`OrderLineType` are almost certainly incomplete (single/null value observed) — do not treat sampled values as the full enum.
- `RxqId`/`BzqId` are varchar identifiers despite indexing suggesting join usage — no validated parent table found, so their referential meaning is unresolved.
- Dual quantity/description/NDC pairs (`Qty` vs `RequestedQty`/`UpdatedQty`, `Description` vs `RequestedDescription`, `NDCUPC` vs `RequestedNDCUPC`, and `RequestedItemNumber`) suggest an order-confirmation reconciliation workflow (as-ordered vs. as-requested vs. as-received) — inferred, not confirmed by any relationship data.
- `OrderId` clustered index but column itself nullable — clustering on a nullable FK-like column is unusual and worth double-checking against Liberty's actual PK/clustering intent if this table is ever integrated.

---

## `rxqOrderDefaults`

rows: 1 (RXCS) | columns: 11 | PK: `id` | ETL-mirrored into liberty_link_stage: no

**Purpose** — A singleton (1-row) configuration table storing default settings for the RXQ purchase/re-order (drug ordering) module: which order queues to include (`IncludeRXQ`, `IncludeBZQ`), default create/sort/vendor/drug-schedule filter options, the next sequential order number counter (`NextOrderNumber`), a default usage-days window (`UsageDays`), and legacy/behavioral toggles (`OldPOQ`, `QuantityOnActiveOrders`) (inferred — table/column naming and single-row shape strongly suggest an app-level "settings" record rather than transactional data, not a declared purpose). No FK-style columns exist; nothing here references other tables.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| id | int | NO | PK | identity |
| IncludeRXQ | bit | YES | | |
| IncludeBZQ | bit | YES | | |
| CreateType | int | YES | | sampled values: `1` (count 1) |
| DrugScheduleOptions | int | YES | | sampled values: `1` (count 1) |
| SortOptions | int | YES | | sampled values: `1` (count 1) |
| VendorOptions | int | YES | | sampled values: `1` (count 1) |
| NextOrderNumber | int | YES | | |
| OldPOQ | bit | YES | | |
| UsageDays | int | YES | | |
| QuantityOnActiveOrders | bit | YES | | sampled values: `false` (count 1) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none.
- **Inbound (inferred):** none.

No column naming in this table implies a reference to another table, and no other table's columns were inferred to reference `rxqOrderDefaults`.

**Indexes** — none defined.

**Gotchas**
- Single-row (row_count=1) settings table — with only one sampled row, the "lookups" values (`CreateType`=1, `DrugScheduleOptions`=1, `SortOptions`=1, `VendorOptions`=1, `QuantityOnActiveOrders`=false) are this instance's current configuration, not a validated enum domain; do not assume other integer values are invalid.
- No indexes beyond the PK — expected for a singleton config row, but means there's no evidence of how the app queries it (likely `SELECT TOP 1` or `WHERE id = 1`, inferred).
- Not ETL-mirrored — this table's config values are invisible to eMed/liberty_link_stage; any reporting logic that needs to replicate RXQ ordering behavior (e.g. `UsageDays`, `NextOrderNumber`) cannot rely on the mirror.
- `OldPOQ` name suggests a legacy/deprecated toggle carried forward from a prior "POQ" (purchase order queue?) implementation (inferred from naming only — no other evidence).

---

## `StockReturnHistory`

Rows (RXCS): 137 | Columns: 19 | PK: `ID` | ETL-mirrored into liberty_link_stage: no

**Purpose** — Records reverse-transaction / stock-return events for previously dispensed prescriptions: which script (`ScriptNumber`/`cScriptBaseId`, `RefillNumber`), patient (`PatientID`), and drug (`DrugID`) had stock returned, along with the financial reversal amounts (`PatientPaid`, `InsurancePaid`, `Copay`, `Total`), quantity (`QuantityReturned`), a coded `Reason`, and audit fields (`RtsDate`, `User`, `TransactionNumber`, `StoreNumber`, `Agency`). (inferred) "Rts" likely abbreviates "Return To Stock," a standard pharmacy-operations action for un-dispensing/reversing a fill (e.g., patient never picked up). `Type` is a coded field currently constant (0) in this dataset, and `Display` appears to be a UI-visibility flag (127 true / 10 false, i.e. some return records are suppressed from display). Not currently mirrored to the eMed warehouse.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| ID | int | NO | PK | identity |
| ScriptNumber | int | YES | → rxqScriptBase | |
| RefillNumber | int | YES | | |
| cScriptBaseId | numeric(18,0) | NO | → rxqScriptBase | |
| TransactionNumber | int | NO | | |
| PatientID | varchar(50) | NO | → rxqPatient | |
| DrugID | varchar(50) | NO | → rxqDrug | |
| StoreNumber | varchar(50) | YES | | |
| RtsDate | datetime | NO | | (inferred) date the return-to-stock action occurred |
| User | varchar(50) | NO | | |
| Display | bit | YES | | sampled values: true (127), false (10) |
| Type | int | NO | | sampled values: 0 (137) — only value observed, domain otherwise unknown |
| Agency | varchar(50) | YES | | |
| PatientPaid | decimal(12,2) | YES | | |
| InsurancePaid | decimal(12,2) | YES | | |
| Copay | decimal(12,2) | YES | | |
| Total | decimal(12,2) | YES | | |
| QuantityReturned | varchar(50) | YES | | numeric quantity stored as varchar |
| Reason | varchar(50) | YES | | coded/free-text reason for return; no lookup values sampled |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)** — column naming + data-validated against actual parent-key values, NOT declared constraints:
  - `PatientID` → `rxqPatient` (join `PatientId`) — inferred, **high** confidence (100.0% referential match)
  - `DrugID` → `rxqDrug` (join `DrugId`) — inferred, **high** confidence (100.0% referential match)
  - `ScriptNumber` → `rxqScriptBase` (join `ScriptNumber`) — inferred, **high** confidence (96.35% referential match, 5 orphans)
  - `cScriptBaseId` → `rxqScriptBase` (join `cScriptBaseId`) — inferred, **high** confidence (96.35% referential match, 5 orphans)
- **Inbound (inferred)** — none

**Indexes** — none defined on this table.

**Gotchas**
- `QuantityReturned` is stored as varchar(50) despite being a numeric quantity — expect casting needed for aggregation.
- `ScriptNumber` and `cScriptBaseId` are redundant parallel references to `rxqScriptBase` (int vs numeric(18,0)) with identical match/orphan profile (5 orphans each, likely the same 5 rows) — probable audit-vs-operational duplication of the script key.
- `Type` shows only a single observed value (0) across all 137 rows; treat as an unconfirmed/likely-unused enum rather than a validated domain.
- `Reason` has no sampled lookup values despite being varchar(50) — likely free text or a coded domain not captured by the small-cardinality sampler.
- Not mirrored by ETL, so this data is unavailable in liberty_link_stage/eMed reporting today.

---

## `PendingStockReturn`

Rows (RXCS): 3,617 | Columns: 9 | PK: `ID` | ETL-mirrored into liberty_link_stage: no

**Purpose**
Queues dispensed-but-not-picked-up (or otherwise stock-recoverable) prescriptions for return-to-stock (RTS) processing, keyed by `ScriptNumber`/`RefillNumber` (inferred). `Source` and `Reason` (both freeform varchar(50), no lookup domain sampled) likely record what triggered the queue entry and why (inferred). `RtsSellWarning` (bit) suggests a flag warning staff not to re-sell/re-dispense returned stock without review (inferred). Every sampled row has `Status = 0`, so the table currently holds only entries in a single (presumably "pending") state — later status codes are not observed in this sample and should not be assumed.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| ID | int | NOT NULL | PK, identity | Identity column |
| ScriptNumber | int | NOT NULL | → `rxqScriptBase` | inferred link to the script/order base table |
| RefillNumber | int | NOT NULL | | no inferred ref; likely refill index within the script |
| DateAdded | datetime | NOT NULL | | |
| Source | varchar(50) | NOT NULL | | freeform, no sampled lookup domain |
| Status | int | NOT NULL | | lookup domain observed: `0` (count 3617) — only value present in this instance |
| AddedBy | varchar(50) | NULL | | freeform, likely user/system identifier |
| Reason | varchar(50) | NULL | | freeform, no sampled lookup domain |
| RtsSellWarning | bit | NULL | | flag, no sampled values captured |

**Relationships**
Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):**
  - `ScriptNumber` → `rxqScriptBase` — inferred, **high** confidence (100.0% referential match, not sampled — full check of 3,617 non-null values, 0 orphans)
- **Inbound (inferred):** none

These edges are inferred purely from column naming and then data-validated against actual parent-key values; they are not enforced database constraints.

**Indexes**
None declared/observed (indexes array empty).

**Gotchas**
- `Status` shows only a single observed value (0) across all 3,617 rows in this snapshot — the full status domain (e.g. what a completed/rejected RTS state looks like) is not visible from this data and should be confirmed against application code before relying on it.
- `Source` and `Reason` are unconstrained varchar(50) with no captured lookup values — likely free text or an uncoded application-level enum; don't assume a fixed value set.
- No indexes exist beyond the PK — any join through `ScriptNumber` to `rxqScriptBase` at scale would be a table/heap scan on this side.

---

## `rxqPendingStockReturn`

Rows (RXCS): 1 | Columns: 4 | PK: `ScriptNumber` | ETL-mirrored into liberty_link_stage: no

**Purpose**
Queues scripts flagged for a pending stock return, keyed one-row-per-`ScriptNumber` with a `Source` tag, an `Status` code, and a `DateAdded` timestamp (inferred). Given the tiny row count (1 row, presumably a stale/leftover queue entry) this appears to be a transient work-queue table rather than a durable ledger — items are likely inserted when a fill/pack is reversed or returned to stock and removed once processed (inferred). Not ETL-mirrored, so no downstream eMed visibility into stock-return queue state.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| ScriptNumber | int | NOT NULL | PK, → `rxqScriptBase` | |
| Source | varchar(50) | NULL | | no sampled values (not in lookups) |
| DateAdded | datetime | NOT NULL | | |
| Status | int | NULL | | sampled value: `null` (count 1) — only row present has NULL status, so no populated coded domain observed |

**Relationships**
Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**:
  - `ScriptNumber` → `rxqScriptBase` — inferred, **low** confidence (0.0% referential match; 1 non-null value, 1 orphan, not sampled)
- **Inbound (inferred)**: none

**Indexes**
None declared.

**Gotchas**
- Only 1 row in the entire table on RXCS, and its `ScriptNumber` does not match any row in `rxqScriptBase` (0% match, low confidence) — treat the `ScriptNumber` → `rxqScriptBase` link as unconfirmed/likely broken or referencing a purged/archived script.
- The single sampled `Status` value is NULL, so the coded meaning of `Status` (e.g., pending/approved/completed) cannot be derived from this data — do not assume a domain.
- Table has no indexes beyond the PK; with 1 row this reveals nothing about intended access patterns.
- Given the near-empty state, this table may be effectively deprecated or only used transiently during active stock-return processing (inferred).

---
