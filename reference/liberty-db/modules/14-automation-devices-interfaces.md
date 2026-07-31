# Liberty schema — Automation, Devices, Interfaces & Appointments

Automation and scheduled jobs (auto-reports, auto-run, autopilot), workflow hardware (devices, scales), central-fill interface and webhook subscriptions, plus appointment scheduling and resources.

> Part of the [Liberty/RxQ schema reference](../README.md). Liberty declares **no foreign-key constraints** (verified via `sys.foreign_keys`), so all relationships shown are **inferred from column naming and then data-validated** by referential match rate — each is tagged high / medium / low / no-data / unvalidated confidence. Row counts and sampled enum values are from the RXCS instance (point-in-time); the schema itself is identical across the rxcs / mmed / mdvo tenants.

**Tables in this module (10):** [`rxqAutoReport`](#rxqautoreport) · [`rxqAutoReportAudit`](#rxqautoreportaudit) · [`rxqAutoRunItem`](#rxqautorunitem) · [`AutoPilotSchedule`](#autopilotschedule) · [`RxqWorkflowDevice`](#rxqworkflowdevice) · [`rxqScaleSetup`](#rxqscalesetup) · [`rxqCentralInterface`](#rxqcentralinterface) · [`rxqWebhookSubscription`](#rxqwebhooksubscription) · [`rxqAppointments`](#rxqappointments) · [`rxqAppointmentsResources`](#rxqappointmentsresources)

---

## `rxqAutoReport`

Rows (RXCS): 3 | Columns: 10 | PK: `cAutoReport` | ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores definitions for scheduled/automated reports configured in the pharmacy system — each row is one report job with a `Template`, a `Filter`, a `Schedule`, and serialized `Options`, plus `LastDateRun`/`LastModified` audit timestamps and an `Active` flag (inferred: this is a report-scheduler config table, akin to a saved-report/cron entry, not a transactional pharmacy record). The presence of a companion `rxqAutoReportAudit` table referencing this one's PK (inferred) suggests each run of a scheduled report is logged there. `StoreNumber` (inferred) scopes a report definition to a specific pharmacy store/location. Very low row count (3) indicates this is an admin-configured, sparsely-used feature rather than a per-transaction table.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cAutoReport | int | NO | PK | identity |
| StoreNumber | varchar(50) | YES | | |
| Type | int | YES | | coded domain (sampled): `14` (count 2), `12` (count 1) |
| Template | varchar(max) | YES | | |
| Filter | varchar(max) | YES | | |
| Schedule | varchar(max) | YES | | |
| Options | varchar(max) | YES | | |
| LastDateRun | datetime | YES | | |
| LastModified | datetime | YES | | |
| Active | bit | YES | | coded domain (sampled): `true` (count 3) — all 3 sampled rows are active |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none.
- **Inbound (inferred):**
  - `rxqAutoReportAudit.cAutoReport` → `rxqAutoReport` — inferred, **high** confidence (100.0% referential match).

These edges are inferred purely from column naming and were data-validated against actual key values in each table — they are not enforced database constraints.

**Indexes**

None reported (empty `indexes[]` — no informative indexes beyond the PK).

**Gotchas**

- `Type` and `Active` domains are sampled from only 3 rows — treat as illustrative, not exhaustive, enum coverage.
- `Template`, `Filter`, `Schedule`, and `Options` are all `varchar(max)`, likely holding serialized/structured text (e.g., XML/JSON or delimited config) rather than atomic values — no further structure is visible in this metadata.
- Not mirrored by ETL, so this table is invisible to liberty_link_stage/downstream eMed reporting — any eMed-side feature needing Liberty's own scheduled-report config would need a separate direct read.

---

## `rxqAutoReportAudit`

Rows (RXCS): 4,576 | Columns: 6 | PK: `cAutoReportAudit` | ETL-mirrored into liberty_link_stage: no

**Purpose** — Run-history/audit log for automated report jobs defined in `rxqAutoReport` (inferred): each row records one execution instance (`DateRun`), its outcome (`RunStatus`), and any error text (`Error`) for a given `cAutoReport` job definition. Functions as an operational log rather than a business/clinical table, which likely explains why it is not mirrored by the ETL pipeline.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `cAutoReportAudit` | int | NO | PK | identity |
| `cAutoReport` | int | YES | → `rxqAutoReport` | — |
| `DateRun` | datetime | YES | | timestamp of the report run (inferred) |
| `RunStatus` | int | YES | | coded status; sampled values: `1` (2,547 rows), `2` (2,029 rows) — meaning not decoded in source data (inferred: e.g. success/failure) |
| `Error` | varchar(max) | YES | | error message/detail text when run fails (inferred) |
| `LastModified` | datetime | YES | | last-modified timestamp |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**:
  - `cAutoReport` → `rxqAutoReport` (join col `cAutoReport`) — inferred, **high** confidence (100.0% referential match, 4,576/4,576 non-null values, 0 orphans).
- **Inbound (inferred)**: none.

These edges are inferred purely from column naming and then data-validated against actual key values — they are not enforced database constraints.

**Indexes** — none defined (empty index list; no declared indexes beyond the PK).

**Gotchas**
- No indexes exist beyond the PK/identity, so lookups by `cAutoReport` or `DateRun` (e.g. "last run per report job") would require full scans.
- `RunStatus` is an undecoded int enum (only values `1` and `2` observed); treat as opaque status codes pending confirmation from application code or `rxqAutoReport`.
- Not ETL-mirrored — this data is unavailable in liberty_link_stage for any downstream eMed reporting/monitoring use.

---

## `rxqAutoRunItem`

Rows (RXCS): 7 | Columns: 10 | PK: `cAutoRunItemId` | ETL-mirrored into liberty_link_stage: no

**Purpose** — Stores a small configuration list of scheduled/automated jobs ("auto-run" tasks) for a Liberty store, each keyed by `StoreNumber` with a `Type` code, a `Frequency` code, a scheduled `Day` and `EntryTime`, free-form `Options`, and last-execution tracking via `LastDateRun` and `Status` (inferred — this shape is standard for a job-scheduler/task-runner config table). Only 7 rows exist in RXCS, consistent with a small fixed list of recurring background jobs (e.g., nightly batch tasks, reports, or interface runs) rather than a per-transaction table (inferred). No columns reference patient, drug, or prescription entities, so it appears to be store-operational/administrative configuration rather than clinical data (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `cAutoRunItemId` | int | NO | PK | identity; sampled values 111–117 (7 rows, contiguous) |
| `StoreNumber` | varchar(50) | YES | | no implicit_ref detected |
| `Type` | int | YES | | coded; sampled values: 20 (×2), 10 (×1), 77 (×1), 70 (×1), 52 (×1), 40 (×1) |
| `Frequency` | int | YES | | coded; sampled values: 10 (×6), 20 (×1) |
| `Day` | int | YES | | likely day-of-week/month code (inferred); no lookup sample captured |
| `EntryTime` | time(7) | YES | | scheduled time-of-day for the run (inferred) |
| `Options` | varchar(150) | YES | | free-form job options/parameters string (inferred) |
| `LastDateRun` | datetime | YES | | timestamp of last execution (inferred) |
| `Status` | int | YES | | coded; sampled values: 20 (×4), 1 (×3) |
| `Notes` | varchar(50) | YES | | free-form notes |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no `implicit_ref` or inferred_relationships entries were detected for any column (including `StoreNumber`, which is not validated against a store table in this extract).
- **Inbound (inferred):** none — no other table's columns were inferred to reference `rxqAutoRunItem`.

**Indexes** — none reported (empty `indexes[]`; no non-clustered join/lookup paths visible in this extract).

**Gotchas**
- Extremely small table (7 rows) — likely a static per-store job-schedule config list, not transactional data; treat any analysis as configuration-level, not volume-representative.
- `Type`, `Frequency`, and `Status` are opaque integer codes with no lookup/decoder table identified in this extract — the sampled values above are the only known enum domain, not a confirmed full set.
- No inferred relationships at all (outbound or inbound) — `StoreNumber` is a strong naming candidate for a store/location dimension but was not data-validated here (absent from `inferred_relationships`), so treat any cross-table join on `StoreNumber` as unconfirmed.
- Not mirrored by ETL into liberty_link_stage, so this table is invisible to downstream eMed reporting/consumers.

---

## `AutoPilotSchedule`

Rows (RXCS): 1 · Columns: 2 · PK: `StoreNumber` · ETL-mirrored into liberty_link_stage: no

**Purpose** — A tiny, per-store configuration/settings table keyed by `StoreNumber`, holding a single freeform `Value` payload (varchar(max)). With exactly one row in the RXCS instance and no lookups or FK constraints, it reads as a store-level singleton config record — likely a serialized/blob setting for an "AutoPilot" scheduling feature (inferred; name suggests automated task/refill scheduling, but no columns here describe schedule cadence, time, or job type directly). The column name `Value` matching `DiscountCard` is very likely a naming coincidence rather than a real relationship (inferred, see Relationships).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| StoreNumber | nvarchar(128) | NO | PK | Store identifier; sole primary key |
| Value | varchar(max) | YES | — | Freeform payload/config value; no sample values available (not a coded/lookup column) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):**
  - `Value` → `DiscountCard` — inferred from column naming only, **unvalidated** confidence (parent table `DiscountCard` is empty, so the match could not be data-validated; treat as a weak/unconfirmed guess, likely a false positive given `Value` is a generic column name).
- **Inbound (inferred):** none.

**Indexes** — None beyond the implicit PK constraint on `StoreNumber`.

**Gotchas**
- Single-row table in RXCS — behavior/shape here may not generalize even though schema is identical across tenants; could hold different values (or more rows) per pharmacy tenant.
- `Value` is untyped freeform text (varchar(max)) with no lookup domain captured — likely serialized JSON/XML/delimited config rather than a scalar; do not assume it's a simple foreign key value despite the `implicit_ref` hint.
- The inferred `DiscountCard` relationship is unvalidated (empty parent) and should not be treated as reliable — likely a naming coincidence given `Value` is a very generic column name.

---

## `RxqWorkflowDevice`

Rows (RXCS): 20 · Columns: 9 · PK: `DeviceKey` · ETL-mirrored into liberty_link_stage: no

**Purpose** — Registry of physical/network devices participating in the pharmacy workflow (e.g. workstations, scanners, or terminals used in fill/verification steps), tracked by a coded `DeviceType`, an assigned `StoreNumber`, and connectivity/geolocation telemetry (`LastLat`/`LastLng`, `LastConnected`, `LastIpAddress`/`LastIpAddressDate`) (inferred). The small row count (20) and per-device last-seen fields suggest this is an operational device inventory/heartbeat table rather than a transactional workflow table (inferred). No columns or relationships tie it explicitly to patients, prescriptions, or orders in this table alone.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| DeviceKey | int | NO | PK | |
| DeviceName | nvarchar(max) | YES | | |
| LastLng | decimal(8,8) | YES | | last known longitude |
| LastLat | decimal(8,8) | YES | | last known latitude |
| LastConnected | datetime | YES | | |
| DeviceType | int | YES | | coded domain — sampled values: 4 (11), 0 (5), 1 (2), 5 (1), 2 (1) |
| StoreNumber | nvarchar(max) | YES | | |
| LastIpAddressDate | datetime | YES | | timestamp of LastIpAddress capture |
| LastIpAddress | nvarchar(50) | YES | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

No outbound or inbound edges were inferred for this table — `StoreNumber` and `DeviceType` are stored as loose typed/coded values with no naming-based match to another table's key in this extract. Note this only reflects column-naming heuristics validated against sampled data; a real relationship (e.g. `StoreNumber` → a store/location table) may still exist in the full schema outside this analysis's detection.

**Indexes** — none defined.

**Gotchas**
- `DeviceType` is an undocumented coded int (values seen: 0,1,2,4,5); meaning must be inferred from Liberty app config/UI, not present in this DB.
- `StoreNumber` is `nvarchar(max)` rather than a numeric/FK-shaped type, despite the name implying a link to a store/location entity — no inferred relationship was detected, so treat any join to a store table as unconfirmed.
- Only 20 rows total — this is a small device-registry/config table, not per-transaction workflow data; not mirrored by ETL into liberty_link_stage.

---

## `rxqScaleSetup`

Rows (RXCS): 7 | Columns: 14 | PK: `cScaleSetupId` | ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores serial-port communication configuration for physical prescription scales connected to the pharmacy workstation(s) — port (`Comport`), line protocol parameters (`BaudRate`, `DataBits`, `Parity`, `StopBits`, `Handshake`), and a small protocol for parsing the scale's serial output stream (`PrintCode`, `TareCode`, `TerminateKey`, `SplitIndicator`, `WeightPosition`, `UOMPosition`). (inferred) This is a device-integration/setup table, not a clinical or transactional one — it configures how the pharmacy system reads live weight readings from a compounding/counting scale during fill verification, one row likely per scale/workstation given the low row count (7). No lookups were sampled (no small coded columns captured), so the specific integer encodings for `Parity`, `Handshake`, etc. are unknown from this metadata alone — these plausibly map to standard serial-port enumerations (inferred, not confirmed by data).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cScaleSetupId | int | NO | PK | identity |
| Comport | varchar(max) | YES | | serial port identifier (e.g. COM1) |
| BaudRate | int | YES | | serial line speed |
| DataBits | int | YES | | serial protocol param |
| Parity | int | YES | | serial protocol param, likely coded enum (no sampled values) |
| StopBits | int | YES | | serial protocol param |
| Handshake | int | YES | | serial protocol param, likely coded enum (no sampled values) |
| PrintCode | varchar(max) | YES | | scale output marker/token |
| TareCode | varchar(max) | YES | | scale output marker/token for tare weight |
| TerminateKey | varchar(max) | YES | | delimiter/terminator for scale data stream |
| SplitIndicator | varchar(max) | YES | | marker for split/segmented readings |
| WeightPosition | int | YES | | offset/index of weight value within parsed scale string |
| UOMPosition | int | YES | | offset/index of unit-of-measure value within parsed scale string |
| LastModified | datetime | YES | | audit timestamp |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

No column-naming based relationships were inferred to or from this table; it appears to be a standalone configuration table.

**Indexes**
None reported (only the PK on `cScaleSetupId`).

**Gotchas**
- Zero declared and zero inferred relationships — this table is fully isolated in the join graph as extracted; any link to a workstation/device/store table would need to be established by other means (e.g. app code) rather than data.
- `lookups` is empty, so no coded-value legend is available for `Parity`/`Handshake`/`WeightPosition`/`UOMPosition`; do not assume specific integer meanings without checking application code.
- Not ETL-mirrored — this table is not available in liberty_link_stage for downstream reporting/analytics.

---

## `rxqCentralInterface`

Rows: 20 (RXCS) · Columns: 8 · PK: `id`, `StoreNumber` (composite) · ETL-mirrored into `liberty_link_stage`: no

**Purpose** — A small (20-row) registry of named, versioned, enable/disable-able integration jobs ("interfaces") scoped per store, each with a `LastRan` timestamp. This is (inferred) a control/config table for Liberty's central-interface/sync subsystem — e.g. scheduled outbound jobs or connectors that run per `StoreNumber` and can be toggled on/off (`Enabled`), tracked for last-execution time (`LastRan`), and versioned (`Version`). `id` is a varchar identifier (not a surrogate int), suggesting interface names/codes rather than auto-numbered rows (inferred). Not mirrored by ETL, so it is invisible to eMed/liberty_link_stage — purely an internal Liberty operational table.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| id | nvarchar(50) | NO | PK (composite) | Interface identifier/code (inferred) |
| StoreNumber | nvarchar(50) | NO | PK (composite) | Per-tenant store scope; varchar, not FK-declared |
| Name | nvarchar(max) | YES | | Interface display name (inferred) |
| Logo | nvarchar(max) | YES | | Likely image path/URL or base64 blob (inferred) |
| Enabled | bit | YES | | On/off flag for the interface job |
| LastRan | datetime | YES | | Timestamp of last execution (inferred) |
| Description | nvarchar(max) | YES | | Free-text description |
| Version | int | YES | | Interface/config version number |

No columns appear in `lookups` (table has no sampled coded-value data captured).

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**: none — no inferred_relationships detected (no column naming matched a candidate parent table, or none validated).
- **Inbound (inferred)**: none — no other table's columns were inferred to reference this table.

All relationship inference for this table came back empty; `StoreNumber` is a plausible tenant/store-scoping key by convention elsewhere in the schema, but no inbound/outbound edge was data-validated here, so treat any cross-table linkage via `StoreNumber` or `id` as unconfirmed.

**Indexes** — none reported (empty `indexes[]`).

**Gotchas**
- Composite varchar PK (`id` + `StoreNumber`) rather than a surrogate key — joins/lookups must match both columns.
- `id` is nvarchar(50), not an integer code, despite naming convention elsewhere in Liberty using numeric IDs — likely a short mnemonic/interface-code string (inferred, unverified since no lookups/sample values were captured).
- Very low row count (20) and no ETL mirror confirm this is a small internal config table, not transactional/business data — low priority for eMed integration.
- No sampled values exist for `Enabled`/`Version`/etc., so the coded domain (e.g., what version numbers or how many interfaces are actually enabled) cannot be documented from this extract.

---

## `rxqWebhookSubscription`

Rows (RXCS): 12 · Columns: 8 · PK: `StoreNumber, ApiUser, Event` · ETL-mirrored into liberty_link_stage: no.

**Purpose**

Stores webhook subscription/registration records that pair a store, API user, and event type with an outbound POST endpoint (`PostUri`) and its auth key (`PostApiKey`) — i.e. it configures where Liberty should push event notifications for a given store/user/event combination (inferred). `IsActive` gates whether the subscription is currently live (all 12 sampled rows are active). The composite PK (`StoreNumber`, `ApiUser`, `Event`) implies at most one subscription per store+API-user+event-type triple. Not mirrored by ETL, so eMed has no visibility into which webhooks are configured — this is purely an internal Liberty pharmacy-system configuration table (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| StoreNumber | varchar(50) | NO | PK | part of composite key |
| ApiUser | varchar(50) | NO | PK | part of composite key |
| Event | varchar(50) | NO | PK | part of composite key; referenced by naming from `InventoryEventLog.Event`, `rxqCentralInterfaceHistory.Event`, `WorkflowEventLog.Event` (no-data — see Relationships) |
| IsActive | bit | NO | | sampled values: `true` (12/12) |
| PostUri | varchar(255) | NO | | webhook destination URL (no lookup data — free-text/URL) |
| PostApiKey | varchar(255) | NO | | auth key/secret for the POST callback (no lookup data — sensitive/free-text) |
| DateCreated | datetime | NO | | |
| DateLastModified | datetime | NO | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none.
- **Inbound (inferred):**
  - `InventoryEventLog.Event` → this table's `Event` — inferred, **no-data** confidence (no match rate computed; likely empty/unvalidatable source table).
  - `rxqCentralInterfaceHistory.Event` → this table's `Event` — inferred, **no-data** confidence (no match rate computed).
  - `WorkflowEventLog.Event` → this table's `Event` — inferred, **no-data** confidence (no match rate computed).

These inbound edges are naming-based guesses only (shared column name `Event`) and were NOT data-validated (no-data = the metadata extractor could not compute a match rate, e.g. empty or type-mismatched source). Treat as weak/unconfirmed — do not assume a real join without independent verification.

**Indexes**

None reported.

**Gotchas**

- Composite natural-key PK using three varchar(50) columns (`StoreNumber`, `ApiUser`, `Event`) rather than a surrogate ID — typical of Liberty's config tables.
- `PostApiKey` is stored in plaintext varchar in this table (per schema; no encryption indicated) — treat as sensitive if ever queried directly against Liberty.
- All three inbound "Event" relationships are unvalidated (no-data); the `Event` column's actual value domain (event type names) is unknown since it's not in `lookups` — do not assume it matches those other tables' `Event` domains without checking.
- Not ETL-mirrored, so this table is invisible to eMed/liberty_link_stage entirely; any question about webhook configuration must be answered by querying the Liberty pharmacy-system DB directly per tenant (rxcs/mmed/mdvo each has its own row set despite identical schema).

---

## `rxqAppointments`

Rows (RXCS): 12 | Columns: 16 | PK: `UniqueID` | ETL-mirrored into liberty_link_stage: no

**Purpose**: Stores calendar/scheduling entries (appointments) — start/end datetimes, all-day flag, subject/location/description text, a resource assignment, reminder and recurrence payloads, and a time zone. The column shape (`StartDate`/`EndDate`/`AllDay`/`Subject`/`Location`/`Description`/`Label`/`ResourceID`/`ResourceIDs`/`ReminderInfo`/`RecurrenceInfo`/`TimeZoneId`) closely matches the schema of a generic scheduler/calendar UI component (inferred — e.g. a DevExpress Scheduler-style control embedded in the Liberty pharmacy front-end for staff/resource appointment booking, not a patient-facing pharmacy workflow object like fills or refills). With only 12 rows sampled, this appears to be a lightly-used feature in the RXCS tenant. Not mirrored by ETL, so eMed has no visibility into this data.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| UniqueID | int | NO | PK | identity |
| Type | int | YES | | lookups: `0` (12) — only value sampled |
| StartDate | smalldatetime | YES | | |
| EndDate | smalldatetime | YES | | |
| AllDay | bit | YES | | |
| Subject | nvarchar(50) | YES | | |
| Location | nvarchar(50) | YES | | |
| Description | nvarchar(max) | YES | | |
| Status | int | YES | | lookups: `0` (12) — only value sampled |
| Label | int | YES | | |
| ResourceID | int | YES | | lookups: `0` (12) — only value sampled |
| ResourceIDs | nvarchar(max) | YES | | likely delimited/serialized list of multiple resource IDs (inferred) |
| ReminderInfo | nvarchar(max) | YES | | likely serialized reminder settings (inferred) |
| RecurrenceInfo | nvarchar(max) | YES | | likely serialized recurrence rule (inferred) |
| TimeZoneId | nvarchar(max) | YES | | |
| CustomField1 | nvarchar(max) | YES | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**: none — no inferred_relationships detected for this table (no candidate columns matched a naming/data pattern to a parent table, e.g. `ResourceID` was not resolved to a resource table).
- **Inbound (inferred)**: none — no other table's columns were inferred to reference `rxqAppointments`.

**Indexes**: none reported (no indexes defined on this table beyond the implicit PK).

**Gotchas**
- All three sampled coded columns (`Type`, `Status`, `ResourceID`) show only the value `0` across all 12 rows — the enum domain is effectively unconfirmed/degenerate at this row count; do not treat `0` as the full domain.
- No indexes exist beyond the PK, and no FK/inferred relationships tie `ResourceID`/`ResourceIDs` to any resource or staff table — joins involving this table would need to be guessed from application code, not the schema.
- Not ETL-mirrored, so this table is invisible to eMed/liberty_link_stage entirely.

---

## `rxqAppointmentsResources`

Rows: 172 (RXCS) · Columns: 6 · PK: `UniqueID` · ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores the definitions of schedulable "resources" (e.g. staff members, rooms, equipment, or delivery slots — inferred) used by Liberty's appointment/scheduling module, keyed by `ResourceID` with a display `ResourceName`, a UI `Color` for calendar rendering, and an optional `Image`/`CustomField1` for further customization. This table appears to hold the resource catalog itself, not the appointments (there is no date/time or appointment-linkage column in this table), so it is likely referenced by an `rxqAppointments`-style table elsewhere in the schema via `ResourceID` (inferred — no such relationship could be validated here since `inferred_relationships`/`inferred_referenced_by` are both empty).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| UniqueID | int | No | PK | identity |
| ResourceID | int | No | | logical resource identifier (inferred join target for appointment records; no validated inbound/outbound edges found) |
| ResourceName | nvarchar(50) | Yes | | display label for the resource |
| Color | int | Yes | | UI calendar color code; sampled values: all 172 rows NULL |
| Image | image | Yes | | binary image blob (icon/photo for the resource) |
| CustomField1 | nvarchar(max) | Yes | | free-text custom attribute |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

No naming-based relationships were inferred or data-validated for this table in either direction — `ResourceID` is a strong candidate join key to an appointments table by convention, but that link is unconfirmed/absent from the extracted metadata and should be treated as a guess, not a validated edge.

**Indexes**

None defined (empty index list beyond the implicit PK).

**Gotchas**

- `Color` is 100% NULL across all 172 sampled rows — effectively unused/dead in this tenant's data, despite being a non-nullable-looking design intent.
- No FK-like columns besides `ResourceID` were found, and even that has zero validated relationships in this extract — treat any join to an appointments table as speculative.
- `Image` (SQL Server `image` type, deprecated) suggests this table predates modern Liberty schema conventions.
- Not ETL-mirrored, so this table is invisible to downstream eMed/liberty_link_stage consumers; any appointment-resource scheduling logic in eMed would need a separate/direct read of this table if ever required.

---
