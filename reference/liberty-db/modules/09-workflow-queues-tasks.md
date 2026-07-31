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

**Purpose** — Defines the fixed set of named workflow stages (e.g. queue/bucket definitions) that a pharmacy's order/script processing pipeline moves items through (inferred). Each row is a configured stage with a display `Name`/`Description`, a `FilterString`/`FilterDate` (likely a query/filter expression used to select which items belong in the stage, inferred), flags controlling behavior (`LocationChange`, `InActive`, `IncludeOnHoldScripts`, `IncludeTransmitLater`), a `StageType` code, and an optional `StoreNumber`/`ImageId` for per-store or iconography customization. With only 35 rows and no ETL mirroring, this is a small, largely static configuration table rather than transactional data.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cWorkflowStageId | int | NO | PK | identity |
| Name | varchar(50) | YES | | display name of the stage |
| WorkflowStage | varchar(50) | YES | → rxqStorePrintOptions (unconfirmed, see Relationships) | |
| Description | varchar(250) | YES | | |
| LastUpdatedText | varchar(50) | YES | | free-text audit note (inferred) |
| FilterString | varchar(max) | YES | | likely a filter/query expression selecting items for this stage (inferred) |
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
- `WorkflowStage` (varchar) is distinct from the PK `cWorkflowStageId` (int) — despite the similar name, `WorkflowStage` is a separate string field whose inferred link to `rxqStorePrintOptions` shows a 0% match rate, so it is likely not a real reference to that table (or the join column guess is wrong).
- `UnitDoseExport` is null for all 35 sampled rows — cannot infer its coded domain or purpose from data alone.
- `FilterString`/`FilterDate` are unbounded/long varchar fields that likely hold query or expression logic rather than plain values — worth inspecting actual contents before relying on them programmatically.
- No indexes exist on this table per the extract; joins against it (e.g. from `rxqWorkflowCustomStage`) would rely on the PK's implicit clustered index only.

---

## `rxqWorkflowLocation`

Rows (RXCS): 26 | Columns: 5 | PK: `cWorkflowLocationId` | ETL-mirrored: yes (into liberty_link_stage; all 5 columns mirrored)

**Purpose**
Small reference/lookup table enumerating the discrete "workflow locations" (stations/queues) that a prescription order or task can be sitting at in the pharmacy's production workflow (e.g. data entry, verification, will-call, etc.) (inferred — table has no descriptive columns beyond `Location` and no sample values were captured, so exact station names are not confirmed here). `ParentWorkflowLocationId` establishes a self-referential hierarchy among locations, letting locations be grouped under a parent location (inferred, based on column name and the fact that most values match sibling `cWorkflowLocationId` values in the sampled data — see Gotchas). `ShowInDropdown` and `Intervention` are boolean flags controlling UI presentation (whether the location appears in a location-picker dropdown) and whether the location represents an "intervention" step in workflow (inferred from column names; no sample values captured to confirm semantics).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `cWorkflowLocationId` | int | NO | PK | identity; sampled values include 10, 50, 60, 1000–1038 (sparse, non-contiguous IDs) |
| `Location` | varchar(50) | YES | | free-text/label column (no sample values captured — excluded from lookups, likely treated as sensitive/free text or simply not in the small-coded-column sample set) |
| `ParentWorkflowLocationId` | int | YES | | no declared/inferred FK; sampled values: -1 (18 rows), 1019 (5 rows), 50 (3 rows) — see Gotchas |
| `ShowInDropdown` | bit | YES | | boolean flag; no sample values captured |
| `Intervention` | bit | YES | | boolean flag; no sample values captured |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — the extractor recorded no inferred_relationships for this table. Note `ParentWorkflowLocationId` is a strong naming/data candidate for a self-referential link to this table's own `cWorkflowLocationId` (values -1, 50, 1019 all either match sampled `cWorkflowLocationId` values or use -1 as a sentinel for "no parent"), but this was **not** validated/reported by the extractor as an edge — treat it as an unconfirmed guess only.
- **Inbound (inferred):** none reported by the extractor for this table.

**Indexes**

None reported (empty index list — no explicit indexes beyond the PK constraint were captured).

**Gotchas**
- `ParentWorkflowLocationId` uses `-1` as an apparent "no parent" sentinel (18 of 26 rows) rather than NULL, despite the column being nullable — don't assume NULL means top-level and -1 means something else; both patterns may need to be treated as "root" nodes.
- The extractor found no `inferred_relationships`/`inferred_referenced_by` edges at all for this table, even though `ParentWorkflowLocationId` is naming-suggestive of self-reference — likely because self-referential FKs to the same table's own PK weren't in scope for the inference pass. Don't read the empty edge lists as proof no relationship exists.
- `Location` (the human-readable name) has no captured sample values in this extract, so the actual set of workflow-location names (data entry, verification, will-call, etc.) is unknown from this metadata alone.
- IDs are sparse/non-contiguous (10, 50, 60, then 1000s), suggesting historical additions/deletions or reserved ID ranges rather than a simple sequential list.

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
