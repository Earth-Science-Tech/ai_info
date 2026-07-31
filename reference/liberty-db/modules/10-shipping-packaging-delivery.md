# Liberty schema — Shipping, Packaging & Delivery

Outbound shipment records and script-to-shipment mapping, package scanning and script-transaction package links, and will-call pickup bins.

> Part of the [Liberty/RxQ schema reference](../README.md). Liberty declares **no foreign-key constraints** (verified via `sys.foreign_keys`), so all relationships shown are **inferred from column naming and then data-validated** by referential match rate — each is tagged high / medium / low / no-data / unvalidated confidence. Row counts and sampled enum values are from the RXCS instance (point-in-time); the schema itself is identical across the rxcs / mmed / mdvo tenants.

**Tables in this module (5):** [`rxqShipment`](#rxqshipment) · [`rxqShipmentScriptNumber`](#rxqshipmentscriptnumber) · [`ScannedPackage`](#scannedpackage) · [`ScriptTransactionPackageLink`](#scripttransactionpackagelink) · [`Bin`](#bin)

---

## `rxqShipment`

Rows (RXCS): 190,121 | Columns: 16 | PK: `id` | ETL-mirrored: yes (into `liberty_link_stage`, all 16 columns mirrored)

**Purpose**

Stores one row per physical shipment/package sent out of the pharmacy — carrier/method, cost, ship date, destination (recipient name/address/phone), package count, tracking number, and which store/user created it (inferred, from `ShipmentMethod`/`ShipmentType`/`ShipDate`/`ShippedAddress`/`TrackingNumber`/`PackageCount`/`StoreNumber` columns). It has no PatientId, OrderId, or RxNumber column itself — the link from a shipment to the script(s)/rx(s) it fulfilled is carried by the child table `rxqShipmentScriptNumber` via `ShipmentId` (inferred, from inbound relationship with 100% match). `rxqAuditLogMaster` also references shipments by `ShipmentId` (inferred), suggesting shipment creation/edits are audit-logged there. No lookups were sampled (table has no small NON-PHI coded columns captured), so `ShipmentMethod`/`ShipmentType` domains are unknown from this extract.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| id | int | NO | PK | identity |
| ShipmentMethod | nvarchar(50) | YES | | carrier/method label (e.g. UPS/FedEx/USPS) — no sampled values available |
| ShipmentType | nvarchar(50) | YES | | shipment type classification — no sampled values available |
| Reference | nvarchar(50) | YES | | free-text/external reference; indexed (`IX_Shipment_Reference`) |
| ShipmentCost | float | YES | | shipping cost |
| ShipDate | datetime | YES | | date/time shipped; indexed descending (`IX_cDateTimeDESC`) and included in `IX_Shipment_ID_DateTypeTacking` |
| ShippedAddress | nvarchar(50) | YES | | recipient street address |
| ShippedCity | nvarchar(50) | YES | | recipient city |
| ShippedState | nvarchar(2) | YES | | recipient state (2-char code) |
| ShippedZip | varchar(12) | YES | | recipient ZIP |
| ShippedName | nvarchar(50) | YES | | recipient name |
| ShippedPhone | nvarchar(50) | YES | | recipient phone |
| PackageCount | int | YES | | number of packages in the shipment |
| TrackingNumber | nvarchar(50) | YES | | carrier tracking number; included in `IX_Shipment_ID_DateTypeTacking` |
| UserCreatingShipment | varchar(50) | YES | | user/operator who created the shipment record (varchar, likely a username/ID, not a typed FK) |
| StoreNumber | varchar(50) | YES | | store/tenant identifier (varchar, not a typed FK) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none.
- **Inbound (inferred):**
  - `rxqShipmentScriptNumber.ShipmentId` → this table's `id` — inferred, **high** confidence (100.0% referential match); this is the join path from shipments to the scripts/rx numbers they fulfilled.
  - `rxqAuditLogMaster.ShipmentId` → this table's `id` — inferred, **high** confidence (99.93% referential match); audit trail of shipment record activity.

**Indexes**

- `IX_cDateTimeDESC` (nonclustered) on `ShipDate` — supports date-range/recency queries on shipments.
- `IX_Shipment_ID_DateTypeTacking` (nonclustered) on `id`, including `ShipDate`, `ShipmentType`, `TrackingNumber` — covering index for shipment lookup by id with common display fields (avoids key lookup).
- `IX_Shipment_Reference` (nonclustered) on `Reference` — supports lookup by external/reference number.

**Gotchas**

- `UserCreatingShipment` and `StoreNumber` are untyped varchar columns, not integer FKs to a users/stores table — join reliability to any such table is unverified/unvalidated by this extract.
- No `PatientId`/`OrderId`/`RxNumber` column exists on this table directly; correlating a shipment to a specific patient or prescription requires traversing `rxqShipmentScriptNumber` (child table) first.
- `lookups` is empty for this table — no coded-domain values (e.g. for `ShipmentMethod`/`ShipmentType`) were captured in this extract; treat those columns' possible values as unknown rather than assuming a fixed enum.
- `ShippedAddress`/`ShippedName`/`ShippedPhone` duplicate patient/contact PII at time of shipment rather than referencing a patient/address table — this is a denormalized snapshot, useful for point-in-time shipping labels but can drift from the patient's current address on file (inferred).

---

## `rxqShipmentScriptNumber`

Rows (RXCS): 327,094 | Columns: 7 | PK: `id` | ETL-mirrored into liberty_link_stage: yes (all 7 columns)

**Purpose**
Junction/link table associating a shipment (`rxqShipment`) with a specific script fill (`rxqScriptBase.ScriptNumber` + `RefillNumber`), plus a per-line workflow-clearance status. Both `ShipmentId`→`rxqShipment` and `ScriptNumber`→`rxqScriptBase` are inferred relationships with 100% referential match (high confidence), so this table's core role is a many-to-many/line-item bridge letting one shipment carry multiple script/refill lines (and, implicitly, letting a script's fills be tracked across shipments). The `ShipmentWorkflowStatus` / `StatusClearedBy` / `ClearedAt` triplet (inferred) records whether/when/by-whom a per-line hold or workflow gate on that shipment-script pairing was cleared — consistent with a fulfillment checkpoint (e.g., a manual release step before a script line ships) (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| id | nvarchar(50) | NO | PK | Varchar surrogate key (not an int identity) |
| ShipmentId | int | YES | → `rxqShipment` (id) | Inferred relationship, high confidence (100% match, sampled) |
| ScriptNumber | int | YES | → `rxqScriptBase` (ScriptNumber) | Inferred relationship, high confidence (100% match, sampled) |
| RefillNumber | int | YES | — | Fill sequence number for the linked script; no inferred FK |
| ShipmentWorkflowStatus | int | YES | — | Coded status; sampled domain: `0` (321,832 rows), `1` (3,281 rows), `null` (1,981 rows) |
| StatusClearedBy | varchar(50) | YES | — | Presumed user/system identifier that cleared the workflow status (inferred; no lookup data present) |
| ClearedAt | datetime | YES | — | Timestamp the workflow status was cleared (inferred) |

**Relationships**
Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**:
  - `ShipmentId` → `rxqShipment` — inferred, **high** confidence (100.0% referential match, sampled)
  - `ScriptNumber` → `rxqScriptBase` — inferred, **high** confidence (100.0% referential match, sampled)
- **Inbound (inferred)**: none

These edges are inferred purely from column naming and were then data-validated against actual key values (not enforced constraints) — treat as strong (high-confidence, fully sampled-match) but not schema-guaranteed.

**Indexes**
- `IX_rxqShipmentScriptNumber` (nonclustered, non-unique) on (`ScriptNumber`, `RefillNumber`) — primary lookup path from script/refill to shipment links.
- `IX_ShipmentScript_ScriptRefill_ID` (nonclustered, non-unique) on (`ScriptNumber`, `RefillNumber`) INCLUDE (`ShipmentId`) — covering variant of the same lookup, avoids a key-lookup back to the base table when only `ShipmentId` is needed.

**Gotchas**
- PK `id` is `nvarchar(50)`, not an integer identity — likely a GUID/string key generated app-side rather than by SQL Server.
- Both indexes are keyed on (`ScriptNumber`, `RefillNumber`) with no index on `ShipmentId` alone — reverse lookups (all script lines for a given shipment) rely on a scan or the `ShipmentId` column being included, not keyed.
- `ShipmentWorkflowStatus` domain looks binary (0/1) plus ~0.6% NULL; meaning of 0 vs 1 is not documented in metadata — do not assume 1=cleared/0=pending without confirming against app code or `StatusClearedBy`/`ClearedAt` population patterns.
- No inbound references detected from other tables — this table appears to be a terminal/leaf link table in the schema graph as sampled.

---

## `ScannedPackage`

Rows (RXCS): 6 · Columns: 9 · PK: `Id` · ETL-mirrored into `liberty_link_stage`: no

**Purpose** — Stores one record per physical drug package unit scanned during dispensing/receiving, capturing DSCSA-style track-and-trace identifiers: `GTIN`, `NDC`, `SerialNumber`, `LotNumber`, `ExpirationDate`, and the raw `Barcode` string that was scanned, plus `DateAdded` (when the scan was recorded) and `FirstScanLocation` (inferred: where/which station or workflow step the first scan occurred). (inferred) This supports pharmacy compliance/traceability workflows (e.g., verifying package-level serialization against manufacturer data before dispensing) rather than order or patient management directly — there are no columns linking it to patient, order, or Rx tables. The table is very sparsely populated (6 rows) relative to a live production system, suggesting the scanning feature is lightly used, newly introduced, or largely superseded by another mechanism (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| Id | int | NOT NULL | PK | identity |
| GTIN | varchar(14) | NULL | | Global Trade Item Number (package barcode standard) |
| NDC | varchar(11) | NULL | | National Drug Code |
| SerialNumber | varchar(20) | NULL | | manufacturer serial number of the scanned unit |
| LotNumber | varchar(20) | NULL | | manufacturer lot/batch number |
| ExpirationDate | datetime | NULL | | package expiration date |
| DateAdded | datetime | NULL | | timestamp scan record was created |
| Barcode | varchar(80) | NULL | | raw scanned barcode string (likely the full concatenated GS1 barcode payload) (inferred) |
| FirstScanLocation | varchar(50) | NULL | | location/station of first scan (inferred) |

No columns are present in `lookups` — all coded/enum-domain values are absent from the sampled data (table has only 6 rows).

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no `implicit_ref` values and no entries in `inferred_relationships`. `NDC` and `GTIN` are drug-identifier columns that plausibly relate to a drug master table elsewhere in the schema, but no such edge was detected/validated here.
- **Inbound (inferred):** none — no other table's columns were inferred to reference `ScannedPackage`.

**Indexes** — Seven single-column NONCLUSTERED indexes, one per identifier/date column (`Barcode`, `DateAdded`, `ExpirationDate`, `GTIN`, `LotNumber`, `NDC`, `SerialNumber`), each named explicitly (not auto-generated `_dta_`/`missing_index_`). This indicates the table is designed to be looked up by any single track-and-trace identifier independently (e.g., "find this NDC across all scans" or "find this serial number"), consistent with a compliance/verification lookup use case rather than a single natural access path.

**Gotchas**
- All identifier columns (`GTIN`, `NDC`, `SerialNumber`, `LotNumber`, `Barcode`) are nullable varchars with no declared uniqueness — duplicate or partial scans are not constrained by the schema.
- No FK/linkage to any order, Rx, or patient table — cannot be joined back to a dispensing event or prescription without an unlisted intermediary (if one exists) or business-key matching on NDC/lot/serial against another table.
- Only 6 rows sampled — any structural conclusions about typical data shape are low-confidence; this may be a rarely-exercised or recently added feature.

---

## `ScriptTransactionPackageLink`

Rows (RXCS): 5 | Columns: 4 | PK: `ScriptNumber, RefillNumber, PackageId` | ETL-mirrored into liberty_link_stage: no

**Purpose**

A junction/link table associating a specific script fill (`ScriptNumber` + `RefillNumber`) with a package (`PackageId`), timestamped by `DateLinked`. (inferred) It likely records which physical package(s) a given script transaction/refill was dispensed into or associated with, e.g. for packaging/repackaging or shipment-unit tracking in the dispensing workflow. The composite PK allows multiple packages to link to the same script/refill (or vice versa), consistent with a many-to-many link structure. Table is extremely sparse (5 rows) in the RXCS instance, suggesting this feature/path is rarely used or only recently active (point-in-time).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| ScriptNumber | int | NOT NULL | PK, → `rxqScriptBase` | part of composite PK |
| RefillNumber | int | NOT NULL | PK | part of composite PK |
| PackageId | int | NOT NULL | PK | part of composite PK; presumed FK to a packaging table (not resolved in inferred_relationships — no matching table found/validated) |
| DateLinked | datetime | NULL | | indexed (`idx_ScriptTransactionPackageLink_DateLinked`); no default |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**
  - `ScriptNumber` → `rxqScriptBase` — inferred, **high** confidence (100.0% referential match, not sampled — full check across all 5 rows).
  - `PackageId` has no inferred_relationships entry — no candidate parent table was identified/validated by the extraction; treat any packaging-table linkage as an unconfirmed guess (inferred).

- **Inbound (inferred)**
  - none

**Indexes**

- `idx_ScriptTransactionPackageLink_DateLinked` (NONCLUSTERED, non-unique) on `DateLinked` — supports lookups/reporting by link date.

**Gotchas**

- Only 5 rows sampled — any conclusions about typical usage patterns or `PackageId` semantics are low-confidence given the near-empty state of the table.
- `PackageId` is not resolved to any parent table in the inferred relationships, despite the name strongly suggesting a foreign reference — likely no matching "Package" table exists in this extract, or the join could not be data-validated (no rows/candidate). Do not assume a target table without further investigation.
- No `lookups` captured (no small coded columns present) — all columns are either PK integers or a raw datetime.
- Not mirrored by ETL into liberty_link_stage, so this table's data is not currently available to eMed application logic.

---

## `Bin`

Rows (RXCS): 6 · Columns: 6 · PK: `Id` · ETL-mirrored into liberty_link_stage: no

**Purpose**
A small static lookup/reference table defining physical storage-bin categories used in the pharmacy workflow (e.g. shelving locations for refills, overflow, recalls, cold/freezer storage) (inferred from `ShortCode` values REF/REC/OVF/OSB/FZR/CFL). Each row defines a bin type (`Type`), a display label (`DisplayValue`), a short code, a capacity limit (`MaxRxs` — likely the max number of Rxs the bin can hold, inferred), and a `StoreNumber` scoping the bin to a specific pharmacy store location. With only 6 rows and no FKs pointing at it in this metadata snapshot, it functions as a small per-store configuration/reference set rather than a high-volume operational table.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `Id` | int | NOT NULL | PK | identity |
| `DisplayValue` | varchar(50) | NOT NULL | | Human-readable label for the bin |
| `ShortCode` | varchar(3) | NULL | | Sampled values: `REF`, `REC`, `OVF`, `OSB`, `FZR`, `CFL` (each count 1) |
| `MaxRxs` | int | NULL | | Likely max Rx capacity for the bin (inferred) |
| `Type` | int | NOT NULL | | Coded bin type. Sampled values: `1` (count 2), `3`, `4`, `5`, `6` (count 1 each) |
| `StoreNumber` | varchar(50) | NOT NULL | | Store/location scope for the bin; varchar rather than an int store key |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none.
- **Inbound (inferred):** none.

No inferred_relationships or inferred_referenced_by edges were detected for this table in the naming/data-validation pass — `StoreNumber` looks like it should relate to a store/location table elsewhere in the schema, but no such edge was inferred or data-validated here, so treat any store linkage as unconfirmed.

**Indexes**

None reported (no indexes defined beyond the implicit PK).

**Gotchas**
- `StoreNumber` is varchar(50), not an int FK — joins to a store/location table (if one exists) would need to match on string values.
- `Type` and `ShortCode` appear to be two parallel encodings of the same bin category (e.g. Type 1 ↔ ShortCode); no declared or inferred relationship ties them together or to a separate code-lookup table, so their mapping must be confirmed manually.
- Very low row count (6) confirms this is a static/config table, likely one row per bin category per store, not a transactional log.

---
