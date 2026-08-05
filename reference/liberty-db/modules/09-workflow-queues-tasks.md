# Liberty schema — Workflow, Queues & Tasks

The pharmacy workflow engine — processing queues, workflow items and stages, workflow locations/options, and staff task management with recurrence.

> Part of the [Liberty/RxQ schema reference](../README.md). Liberty declares **no foreign-key constraints** (verified via `sys.foreign_keys`), so all relationships shown are **inferred from column naming and then data-validated** by referential match rate — each is tagged high / medium / low / no-data / unvalidated confidence. Row counts and sampled enum values are from the RXCS instance (point-in-time); the schema itself is identical across the rxcs / mmed / mdvo tenants.

**Tables in this module (7):** [`rxqQueue`](#rxqqueue) · [`rxqWorkFlowItem`](#rxqworkflowitem) · [`rxqWorkflowStages`](#rxqworkflowstages) · [`rxqWorkflowLocation`](#rxqworkflowlocation) · [`rxqWorkflowOptions`](#rxqworkflowoptions) · [`rxqTasks`](#rxqtasks) · [`rxqTasksRecurrence`](#rxqtasksrecurrence)

---

## `rxqQueue`

RXCS rows: 16 | Columns: 9 | PK: `cQueueId` | ETL-mirrored into `liberty_link_stage`: yes (all 9 columns mirrored)

**Purpose**
Small lookup/config table defining the fixed set of processing "queues" (workflow lanes/buckets) that scripts move through in the pharmacy fulfillment workflow — e.g. for routing, display, and prioritization in the workbench UI (inferred). Each row is a named queue (`QueueName`) with a `DisplayOrder` (UI sort position), `PriorityOrder` (processing priority), a `Color` (UI color code, stored as a signed int — inferred to be an ARGB/OLE color value), a `Delivery` flag (whether this queue is delivery-related), an optional `DeliveryCharge`, a `CustomerDefault` flag (default queue assigned to customers), and `IsValid` (active/soft-delete flag). With only 16 rows this is clearly a static reference/config table rather than a transactional one.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cQueueId | int | NOT NULL | PK | identity |
| QueueName | varchar(50) | NULL | | queue display name |
| DisplayOrder | int | NULL | | UI sort order; sampled values 0–12 (some duplicates, e.g. 9/2/1 each appear twice) |
| PriorityOrder | int | NULL | | processing priority rank; sampled values 0–11, value `1` dominant (6 of 16 rows) |
| Color | int | NULL | | signed int color code (ARGB/OLE-style, inferred); sampled: -393211 (×5), null (×2), -14730650 (×2), -128, -14878, -16406762, -557312, -4144960, -9887902, -12080649 (each ×1) |
| Delivery | bit | NOT NULL | | flag: is this a delivery queue (no lookup sample captured) |
| DeliveryCharge | decimal(9,2) | NULL | | charge amount associated with delivery queues |
| CustomerDefault | bit | NOT NULL | | default queue for customers; sampled: false (×15), true (×1) |
| IsValid | bit | NOT NULL | | active/soft-delete flag; sampled: true (×14), false (×2) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none.
- **Inbound (inferred):** these are inferred purely from column naming (`cQueueId`) in other tables and then data-validated against this table's key values — NOT declared constraints:
  - `rxqScriptTransaction.cQueueId` → `rxqQueue` — inferred, **high** confidence (100.0% referential match). Strong, confirmed edge: script transactions are stamped with the queue they're/were routed through.
  - `rxqWorkFlowItem.cQueueId` → `rxqQueue` — inferred, **low** confidence (4.8% referential match). Weak/unconfirmed — most `WorkFlowItem.cQueueId` values don't resolve to a valid `rxqQueue` row; treat as unreliable or a differently-scoped column.
  - `rxqPatient.cQueueId` → `rxqQueue` — inferred, **low** confidence (0.0% referential match). No valid matches found; likely coincidental naming or column repurposed/unused.
  - `rxqPendingScript.cQueueId` → `rxqQueue` — inferred, **low** confidence (0.0% referential match). No valid matches found; same caution as above.

**Indexes**

None declared (indexes list is empty in metadata).

**Gotchas**
- Only the `rxqScriptTransaction` inbound link is trustworthy (100% match); the other three same-named `cQueueId` columns (`rxqWorkFlowItem`, `rxqPatient`, `rxqPendingScript`) mostly or entirely fail to resolve against this table — don't assume naming implies a valid live relationship.
- `Color` is a raw signed 32-bit int (negative values), not a hex string or human-readable label — needs bit-level decoding (e.g. ARGB) to render.
- Static config table (16 rows) — safe to fully cache; changes are rare and likely admin-driven.

---

## `rxqWorkFlowItem`

Rows (RXCS): 755 | Columns: 46 | PK: `SequenceNumber` | ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores discrete pharmacy workflow tasks/queue items (e.g. calls, pickups, fax follow-ups) tracked against a script/refill and optionally a patient, with lifecycle timestamps (`Added`, `Due`, `Completed`), assignment fields (`AddedByName`, `AssignedToName`, `CompletedByName`), a task/status coding pair (`TaskCode`, `StatusCode`), and a soft-delete/validity flag (`IsValid`) plus `DeleteNotes` (inferred). It links to a specific script fill via `ScriptNumber`+`RefillNumber` (high-confidence match to `rxqScriptBase`) and carries "guest patient" fields (`GuestPatientFirstName/LastName/DOB`) suggesting some workflow items exist for patients not yet reconciled to a full `rxqPatient` record (inferred, consistent with the medium-confidence `PatientId` match rate). `cQueueId` appears to route items to a work queue (`rxqQueue`) but is overwhelmingly `0` (unassigned/default queue) in this sample, so the join is weakly populated. Appointment-related columns (`AppointmentId`, `AppointmentDoctorId`, `AppointmentDrugId`, `PatientWaiting`) suggest this table also backs a clinic/appointment-scheduling workflow (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cWorkFlowItemId | int | NOT NULL | | identity |
| SequenceNumber | int | NOT NULL | PK | |
| TaskCode | varchar(50) | NULL | | indexed (IX_WF_task, IDX_rxqWorkflowItem_TaskCode_Due) |
| StatusCode | varchar(50) | NULL | | indexed (IX_WF_status) |
| ScriptNumber | int | NULL | → rxqScriptBase | indexed (IX_WF_ScriptNumber) |
| RefillNumber | int | NULL | | |
| PatientId | varchar(50) | NULL | → rxqPatient | indexed (WorkFlowItem_FamilyId) |
| Comments | varchar(max) | NULL | | |
| DeliveryMethod | varchar(50) | NULL | | |
| AddedByName | varchar(50) | NULL | | |
| AssignedToName | varchar(50) | NULL | | |
| CompletedByName | varchar(50) | NULL | | |
| Added | datetime | NULL | | indexed (NonClusteredIndex-20171227-130600) |
| Due | datetime | NULL | | indexed (IX_WF_DueDate, IX_WF_Completed_IsValid_Due_TaskCode, IDX_rxqWorkflowItem_TaskCode_Due) |
| Completed | datetime | NULL | | indexed (IX_WF_Completed_IsValid_Due_TaskCode) |
| Agency | varchar(50) | NULL | | |
| NursingHome | varchar(50) | NULL | | |
| OtcCost | float | NULL | | |
| PickupType | varchar(50) | NULL | | |
| CallDate | varchar(50) | NULL | | text-typed date field |
| CallTime | varchar(50) | NULL | | |
| PickupDate | datetime | NULL | | |
| PickupTimeType | varchar(50) | NULL | | |
| PayMethod | varchar(50) | NULL | | |
| CallbackNumber | varchar(50) | NULL | | |
| Notes | varchar(50) | NULL | | |
| eScriptTransactionId | int | NULL | | |
| FaxDoctorId | varchar(50) | NULL | | |
| LastModified | datetime | NULL | | |
| IsValid | bit | NULL | | lookup values: true=475, false=280 |
| cQueueId | int | NULL | → rxqQueue | lookup values: 0=719, 2=24, 8=5, 10=4, 3=2, 7=1 |
| ActivityStarted | bit | NULL | | indexed (NonClusteredIndex-20171227-130600) |
| DeleteNotes | varchar(200) | NULL | | |
| DueTimeType | varchar(50) | NULL | | |
| ReferenceId | varchar(50) | NULL | | |
| RequestType | int | NULL | | sampled values: null=755 (always null in this sample) |
| Confirmed | int | NULL | | |
| StoreNumber | varchar(2) | NULL | | |
| CycleType | int | NOT NULL | | lookup values: 0=433, 1=247, 4=73, 2=2 |
| AppointmentId | uniqueidentifier | NULL | | |
| GuestPatientFirstName | nvarchar(max) | NULL | | |
| GuestPatientLastName | nvarchar(max) | NULL | | |
| GuestPatientDOB | datetime | NULL | | |
| PatientWaiting | bit | NULL | | |
| AppointmentDoctorId | varchar(50) | NULL | | |
| AppointmentDrugId | varchar(50) | NULL | | |

**Relationships**
Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- Outbound (inferred):
  - `ScriptNumber` → `rxqScriptBase` (join col `ScriptNumber`) — inferred, **high** confidence (99.5% referential match, 755 non-null / 4 orphans).
  - `PatientId` → `rxqPatient` (join col `PatientId`) — inferred, **medium** confidence (60.9% referential match, 755 non-null / 295 orphans).
  - `cQueueId` → `rxqQueue` (join col `cQueueId`) — inferred, **low** confidence (4.8% referential match, 755 non-null / 719 orphans; dominated by default value 0).

- Inbound (inferred): none.

These edges are inferred purely from column naming plus data-validated match rates against the candidate parent table's key — they are NOT declared database constraints, and the low/medium-confidence edges (`PatientId`, `cQueueId`) should be treated as weak/unconfirmed until corroborated by application logic.

**Indexes**
- `IX_WF_ScriptNumber` (ScriptNumber) — supports the `rxqScriptBase` join / script-centric task lookups.
- `WorkFlowItem_FamilyId` (PatientId) — supports the `rxqPatient` join despite the misleading name (no separate FamilyId column exists).
- `IX_WF_task` (TaskCode), `IX_WF_status` (StatusCode) — support task/status filtering.
- `IDX_rxqWorkflowItem_TaskCode_Due` (TaskCode, Due; includes StatusCode, ScriptNumber) — covering index for the primary "tasks due by type" worklist query.
- `IX_WF_Completed_IsValid_Due_TaskCode` (Completed, IsValid, Due, TaskCode) — supports open/completed task queue queries filtered by validity.
- `IX_WF_DueDate` (Due) — due-date scans.
- `NonClusteredIndex-20171227-130600` (Added, ActivityStarted) — likely supports an "in-progress since" activity view.

**Gotchas**
- `PatientId` is `varchar(50)`, not int — a non-standard key type for a patient identifier; joins to `rxqPatient` must match on string.
- `cQueueId` is 95%+ the default value `0` (unassigned), so `rxqQueue` join coverage is sparse/low-confidence — most workflow items are not routed to a distinct queue in this sample.
- `RequestType` is always `NULL` in this sample (755/755) — likely unused/vestigial column or feature not yet active for RXCS.
- `CallDate`/`CallTime` are stored as `varchar(50)` rather than datetime — no native date validation at the DB layer.
- Guest-patient fields (`GuestPatientFirstName/LastName/DOB`) exist alongside `PatientId`, implying dual patient-identification paths (registered vs. walk-in/guest) that may explain part of the `PatientId` orphan rate (inferred).
- Not mirrored by ETL into liberty_link_stage — any eMed-side workflow reporting would need a direct Liberty read, not the mirror.

---

## `rxqWorkflowStages`

Rows: 35 (RXCS) | Columns: 16 | PK: `cWorkflowStageId` | ETL-mirrored into liberty_link_stage: no

> **Full RXCS contents — including every stage's `FilterString` — are in
> [`../data/rxcs-workflow-locations-and-stages.md`](../data/rxcs-workflow-locations-and-stages.md).**
> Not mirrored by the ETL, so this table lives only in the source Liberty DB.

**Purpose** — Defines the named workbench stages/queues an order/script pipeline moves through. Captured in full 2026-08-05. Each row has a display `Name` (the pharmacy's label, e.g. "PrePay A", "Clarification A", "Auto Injector Ready"), a `WorkflowStage` (the built-in Liberty bucket it groups under), a `FilterString` (a **confirmed** grid-filter expression referencing `[WorkflowLocationId]`/`[ParentWorkflowLocationId]` (→ `rxqWorkflowLocation`), `[cQueueId]` (→ `rxqQueue`), and `[drugCustomField1..4]` (→ `rxqDrug.CustomField1..4`)), a `FilterDate` (serialized .NET-epoch date window; usually a min-date sentinel = no filter), behavior flags (`LocationChange`, `InActive`, `IncludeOnHoldScripts`, `IncludeTransmitLater`), a `StageType` code, and an `ImageId` icon. Small static config (35 rows, 7 inactive), no ETL mirror.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cWorkflowStageId | int | NO | PK | identity |
| Name | varchar(50) | YES | | display name of the stage (e.g. "PrePay A", "Clarification B", "RxCS RPh Check") |
| WorkflowStage | varchar(50) | YES | | built-in Liberty stage bucket, NOT an FK; observed values: `RPhCheck`, `Count`, `Verify`, `Ready`, `NewFills`, `Refills`, `HasProblems`, `Rejection`, `All`, `Unknown` |
| Description | varchar(250) | YES | | almost always empty (only stage 18 has "Script needs corrections") |
| LastUpdatedText | varchar(50) | YES | | free-text audit note, e.g. "3/12/2025 4:09:27 PM by VL" |
| FilterString | varchar(max) | YES | | **confirmed** grid-filter expression; references `[WorkflowLocationId]`/`[ParentWorkflowLocationId]`, `[cQueueId]`, `[drugCustomField1..4]`, etc. Empty for 11 stages (full text in the [data file](../data/rxcs-workflow-locations-and-stages.md)) |
| LocationChange | bit | YES | | sampled: `false` (33), `true` (2) |
| InActive | bit | YES | | sampled: `false` (28), `true` (7) |
| IncludeOnHoldScripts | bit | YES | | sampled: `false` (34), `true` (1) |
| StoreNumber | varchar(50) | YES | | per-store scoping (inferred) |
| ImageId | int | YES | | likely references an icon/image asset (inferred) |
| StageType | int | YES | | sampled: `0` (21), `1` (8), `4` (3), `3` (3) — coded domain, meaning not documented in metadata |
| IncludeTransmitLater | bit | YES | | no lookup sample captured |
| FilterDate | varchar(2000) | YES | | likely a date-range filter expression companion to FilterString (inferred) |
| LastModified | date | YES | | |
| UnitDoseExport | int | YES | | sampled: `null` (35) — always null in this dataset |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):**
  - `WorkflowStage` → `rxqStorePrintOptions` (join col `WorkflowStage`) — inferred, **low** confidence (0.0% referential match, 35/35 orphans, not sampled). This is a naming-based guess only; the data does not actually corroborate the link, so treat it as unconfirmed/likely spurious.
- **Inbound (inferred):**
  - `rxqWorkflowCustomStage.cWorkflowStageId` — inferred, **no-data** confidence (parent/child match rate not computed; treat as an unconfirmed naming-based guess).

**Indexes** — none reported (indexes array empty in metadata).

**Gotchas**
- `WorkflowStage` (varchar) is distinct from the PK `cWorkflowStageId` (int) — and, confirmed against the full contents, it is **not an FK** to `rxqStorePrintOptions` (the extractor's 0% match rate was correct). It is a fixed enum of built-in Liberty stage buckets (`RPhCheck`, `Count`, `Verify`, `Ready`, `NewFills`, `Refills`, `HasProblems`, `Rejection`, `All`, `Unknown`) that groups the custom stage.
- `UnitDoseExport` is null for all 35 sampled rows — cannot infer its coded domain or purpose from data alone.
- `FilterString`/`FilterDate` are unbounded/long varchar fields that likely hold query or expression logic rather than plain values — worth inspecting actual contents before relying on them programmatically.
- No indexes exist on this table per the extract; joins against it (e.g. from `rxqWorkflowCustomStage`) would rely on the PK's implicit clustered index only.

---

## `rxqWorkflowLocation`

Rows (RXCS): 26 | Columns: 5 | PK: `cWorkflowLocationId` | ETL-mirrored: yes (into liberty_link_stage; all 5 columns mirrored)

> **Full RXCS contents (the `cWorkflowLocationId` → `Location` mapping) are captured in
> [`../data/rxcs-workflow-locations-and-stages.md`](../data/rxcs-workflow-locations-and-stages.md).**
> IDs are per-tenant `IDENTITY` values — the RXCS list does **not** carry over to `mmed`/`mdvo`.

**Purpose**
Small reference/lookup table enumerating the discrete "workflow locations" (stations/bins) a prescription order or task can be parked at in the pharmacy's production workflow. The full RXCS set was captured 2026-08-05 — actual labels include `Will Call`, `Pharmacy Use`, `Clarifications`, `PRE PAY`, `Ready`, `Infinipharm Rejected`, `Refrigerator`, and more (see the data file). `ParentWorkflowLocationId` establishes a **confirmed self-referential hierarchy** (`-1` = no parent / top-level): only two locations have children — `50 Will Call` (→ Refrigerator/Reconstitute/Oversized Area) and `1019 Clarifications` (→ RTS/Verified Clarification/In Progress/JPV/Billing). `ShowInDropdown` toggles whether the location appears in the manual location-picker (false only for `60 Auto Assign Bin`), and `Intervention` flags an attention/intervention step (true for RTS, Olympia/IV, ETST In Progress, MA/LOT).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `cWorkflowLocationId` | int | NO | PK | identity; values 10, 50, 60, then the 1000-block up to 1038 (sparse, non-contiguous) |
| `Location` | varchar(50) | YES | | station/bin label; 26 distinct values (full list in the [data file](../data/rxcs-workflow-locations-and-stages.md)). NB: `1017` is `"Pending "` with a trailing space |
| `ParentWorkflowLocationId` | int | YES | | self-reference → `cWorkflowLocationId`; `-1` = top-level (18 rows). Children: 3 under `50` Will Call, 5 under `1019` Clarifications |
| `ShowInDropdown` | bit | YES | | show in manual location-picker; `true` for 25/26 rows, `false` only for `60` Auto Assign Bin |
| `Intervention` | bit | YES | | intervention/attention step; `true` for 4 rows (1027 RTS, 1032 Olympia/IV, 1035 ETST In Progress, 1037 MA/LOT) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (self-referential, data-confirmed):** `ParentWorkflowLocationId` → this table's own `cWorkflowLocationId`. Every non-`-1` parent value (`50`, `1019`) resolves to a real row; `-1` is the "no parent / top-level" sentinel. This was verified against the full 26-row contents (2026-08-05), not just the extractor's inference pass.
- **Inbound (inferred):** `rxqScriptTransaction.WorkflowLocation` (int) → `cWorkflowLocationId` — the join eMed uses to decode where a script sits (naming + type consistent). In `liberty_link_stage` this is a **same-prefix** join, e.g. `rxcs_rxqScriptTransaction.WorkflowLocation → rxcs_rxqWorkflowLocation.cWorkflowLocationId`. Stage `FilterString`s in `rxqWorkflowStages` also reference these IDs via `[WorkflowLocationId]` / `[ParentWorkflowLocationId]`.

**Indexes**

None reported (empty index list — no explicit indexes beyond the PK constraint were captured).

**Gotchas**
- **Per-tenant IDs — do NOT reuse the RXCS mapping for `mmed`/`mdvo`.** `cWorkflowLocationId` is an `IDENTITY` and each tenant runs its own Liberty DB, so the same numeric ID means different things across `rxcs`/`mmed`/`mdvo`, and new locations drift independently. The captured mapping is RXCS-only — query the tenant's own `{pfx}_rxqWorkflowLocation` for the others.
- `ParentWorkflowLocationId` uses `-1` (not NULL) as the "no parent" sentinel (18 of 26 rows) despite being nullable — treat `-1` as root, same as NULL.
- `Location` values include trailing whitespace in at least one row (`1017` = `"Pending "`) and duplicate-ish labels across the hierarchy (`1031` "In Progress" vs `1035` "ETST In Progress") — `RTRIM` and don't match on label alone.
- The prod mirror can lag the source on label renames (full-reload hourly ETL) — see the freshness note in the data file (`1035` differed at capture).
- IDs are sparse/non-contiguous (10, 50, 60, then 1000s) — historical additions/reserved ranges, not a dense sequence.

---

## `rxqWorkflowOptions`

Rows (RXCS): 19 · Columns: 6 · PK: `cWorkflowOptionsId` · ETL-mirrored into liberty_link_stage: no

**Purpose** — A small store-level configuration table, one row per workflow stage (19 rows for what appears to be a fixed, enumerated set of pharmacy workflow stages), controlling display behavior for the fill-queue UI: `ShowQueue` (bit) toggles whether a stage's queue is shown (16 of 19 stages shown, 3 hidden), `SortOrder` presumably orders stages in the UI, and `StoreNumber` scopes the config per store (inferred). `WorkflowStage` names/references the workflow-stage concept but is typed `int` while the plausible related table (`rxqStorePrintOptions`) stores it as text (e.g. `'Entry'`), so no live cross-table link could be validated (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `cWorkflowOptionsId` | int | NO | PK | identity; sampled values 1–19 (one row per id, count=1 each) — looks like a fixed enum of workflow stages |
| `WorkflowStage` | int | YES | → `rxqStorePrintOptions` (unvalidated) | inferred link only by column name; join failed type conversion (see Relationships) |
| `SortOrder` | int | YES | | display/order sequence (inferred) |
| `ShowQueue` | bit | YES | | coded domain: `true` (16), `false` (3) |
| `StoreNumber` | varchar(50) | YES | | likely store-scoping key (inferred); no validated relationship found |
| `LastModified` | datetime | YES | | audit timestamp |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):**
  - `WorkflowStage` → `rxqStorePrintOptions` (join col `WorkflowStage`) — inferred from column naming only, **unvalidated** confidence: the data-validation attempt errored ("Conversion failed when converting the varchar value 'Entry' to data type int"), meaning `rxqStorePrintOptions.WorkflowStage` is stored as text (e.g. `'Entry'`) while this table's `WorkflowStage` is `int`. No match rate could be computed — treat as an unconfirmed, type-mismatched guess, not a real join path.
- **Inbound (inferred):** none.

**Indexes** — none declared/reported.

**Gotchas**
- `WorkflowStage` type mismatch across tables (int here vs. varchar in `rxqStorePrintOptions`) blocks any direct join validation — if a relationship exists, it likely requires a lookup/translation table or code mapping, not a raw equi-join.
- Only 19 rows and no ETL mirror — this is pure store-side UI configuration, not transactional/operational data of interest to eMed reporting.
- No indexes beyond the PK; table is tiny and effectively a static config list.

---

## `rxqTasks`

Rows (RXCS): 1,353 | Columns: 16 | PK: `cTaskId` | ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores internal pharmacy staff to-do items / follow-up tasks — a name, due date, assignee, completion state, and free-text notes (inferred, from `TaskName`/`DueDate`/`Assigned`/`Completed`/`Notes`). Tasks can optionally link to a patient (`PatientId`) and a specific script (`LinkedScript`), and can recur (`IsRecurrence`, with child rows in `rxqTasksRecurrence`). `CategoryId` codes the task type/queue, dominated by category 13 (91% of rows). Not ETL-mirrored, so this is operational/internal Liberty workflow data with no current visibility in liberty_link_stage.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cTaskId | int | NO | PK | identity |
| TaskName | varchar(50) | YES | | task label/title |
| DueDate | datetime | YES | | |
| Assigned | varchar(50) | YES | | free-text assignee (likely username/staff name), no FK |
| CategoryId | int | YES | | coded domain (sampled): 13 (1230), 0 (94), 9 (15), 10 (6), 11 (6), 14 (1), 17 (1) |
| Completed | bit | YES | | indexed (IX_Tasks_Completed_Assigned) |
| Notes | varchar(500) | YES | | free text |
| CreatedBy | varchar(50) | YES | | |
| CreatedDateTime | datetime | YES | | |
| CompletedBy | varchar(50) | YES | | |
| CompletedDateTime | datetime | YES | | |
| LinkedScript | int | YES | | indexed (IX_Tasks_LinkedScript); no naming match to a script table found — target unresolved, not in inferred_relationships |
| PatientId | varchar(50) | YES | → rxqPatient | inferred join column, but 0% match rate against sampled rxqPatient (see Relationships) |
| IsRecurrence | bit | NO | | flags recurring tasks |
| IsAcknowledge | varchar(256) | NO | | despite name, non-nullable varchar(256) — likely stores an acknowledgment note/flag string rather than a boolean (inferred) |
| StoreNumber | varchar(3) | YES | | store/site code, no FK |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**
  - `PatientId` → `rxqPatient` — inferred, **low** confidence (0.0% referential match, all 1,353 non-null values orphaned, not sampled). Naming suggests intent but the data does not currently substantiate this link — treat as unconfirmed/likely stale or referencing a different patient-key namespace.
- **Inbound (inferred)**
  - `rxqTasksRecurrence.cTaskId` → this table's `cTaskId` — inferred, **high** confidence (100.0% referential match). Child recurrence rows reliably resolve to a parent task.

**Indexes**
- `IX_Tasks_Completed_Assigned` (nonclustered, non-unique) on (`Completed`, `Assigned`) — supports staff worklist queries (e.g., "my open tasks").
- `IX_Tasks_LinkedScript` (nonclustered, non-unique) on (`LinkedScript`) — supports lookup of tasks tied to a given script, though the referenced table is not identifiable from naming/data alone.

**Gotchas**
- `PatientId` is `varchar(50)` (not int) and its inferred link to `rxqPatient` has a 0% match rate in sampled data — do not assume this join is reliable without further investigation.
- `LinkedScript` is indexed but has no resolvable inferred target table; its meaning (which script table/system) is ambiguous from metadata alone.
- `IsAcknowledge` is typed as `varchar(256)` NOT NULL despite an "Is-" boolean-style name — likely holds acknowledgment text/metadata, not a flag (inferred).
- `Assigned`, `CreatedBy`, `CompletedBy` are free-text varchar(50) with no FK to a users/staff table — matching to identities would require external join logic.
- Category domain is heavily skewed to `CategoryId = 13` (91% of rows), suggesting one dominant task type/queue drives most volume.

---

## `rxqTasksRecurrence`

Rows (RXCS): 5 | Columns: 20 | PK: `cTaskRecurrenceId` | ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores recurrence-rule definitions for scheduled/recurring tasks in Liberty's internal task system, one row per recurring rule linked to a task in `rxqTasks` via `cTaskId` (inferred, 100% referential match). Columns mirror a classic calendar-recurrence model (RecurrenceType, Periodicity, DayNumber, WeekDays, WeekOfMonth, FirstDayOfWeek, Month, StartDate, Range, OccurrenceCount, EndDate) resembling Outlook/iCal-style recurrence patterns — daily/weekly/monthly/yearly cadences with day-of-week and week-of-month qualifiers (inferred). `CompletedRecurrenceDate` (nvarchar(max)) likely holds a serialized list/log of dates on which an occurrence was completed (inferred). Standard audit columns (`CreatedBy`/`CreatedDateTime`/`ModifiedBy`/`ModifiedDateTime`/`VersionNumber`) track authorship and optimistic-concurrency versioning. This table is not mirrored by the ETL into liberty_link_stage, so it is invisible to eMed-side reporting/consumers — it is purely an internal Liberty pharmacy-workflow scheduling artifact, not a pharmacy/clinical record.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cTaskRecurrenceId | int | NO | PK | identity |
| cTaskId | int | NO | → rxqTasks | |
| RecurrenceType | smallint | YES | | sampled values: 0 (count 3), 2 (count 2) — coded recurrence-type enum (inferred, e.g. daily/weekly/monthly/yearly; exact mapping not in metadata) |
| Periodicity | int | YES | | interval multiplier for the recurrence (inferred, e.g. "every N days/weeks") |
| AllDay | bit | YES | | all-day flag (inferred) |
| DayNumber | int | YES | | day-of-month qualifier (inferred) |
| WeekDays | varchar(20) | YES | | likely delimited weekday list (inferred) |
| WeekOfMonth | varchar(20) | YES | | e.g. "first/second/last" week qualifier (inferred) |
| FirstDayOfWeek | varchar(20) | YES | | calendar start-of-week setting (inferred) |
| Month | int | YES | | month qualifier for yearly recurrence (inferred) |
| StartDate | datetime | YES | | recurrence range start |
| Range | int | YES | | coded range-type (e.g. no-end / end-by-date / end-after-N-occurrences) (inferred) |
| OccurrenceCount | int | YES | | max number of occurrences (inferred) |
| EndDate | datetime | YES | | recurrence range end |
| CreatedBy | varchar(50) | YES | | audit |
| CreatedDateTime | datetime | YES | | audit |
| ModifiedBy | varchar(50) | YES | | audit |
| ModifiedDateTime | datetime | YES | | audit |
| VersionNumber | int | YES | | optimistic-concurrency/version counter (inferred) |
| CompletedRecurrenceDate | nvarchar(max) | YES | | serialized completed-occurrence date(s) (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):**
  - `cTaskId` → `rxqTasks` (join col `cTaskId`) — inferred, **high** confidence (100.0% referential match, not sampled — full check across all 5 rows).
- **Inbound (inferred):** none.

**Indexes**
None declared (indexes list empty).

**Gotchas**
- Not ETL-mirrored — no visibility in liberty_link_stage; any eMed-side task-scheduling reporting cannot use this table today.
- Only 5 rows in RXCS — too small a sample to derive reliable lookup domains beyond `RecurrenceType` (0/2 seen); other coded-looking columns (`Range`, `WeekOfMonth`, `FirstDayOfWeek`) have no lookups captured and their value domains are unconfirmed.
- `CompletedRecurrenceDate` is nvarchar(max) despite its name implying a date — suggests it stores a delimited/serialized collection rather than a single date value (inferred).
- No declared FK and no unique/index on `cTaskId` — referential integrity to `rxqTasks` is enforced only at the application layer, if at all.

---
