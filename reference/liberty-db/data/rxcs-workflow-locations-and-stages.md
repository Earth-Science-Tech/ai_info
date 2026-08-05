# RXCS workflow locations & stages — full contents

Full row-level contents of two small Liberty **configuration / lookup** tables:
[`rxqWorkflowLocation`](#rxqworkflowlocation--full-contents-26-rows) (the
`cWorkflowLocationId` → `Location` mapping) and
[`rxqWorkflowStages`](#rxqworkflowstages--full-contents-35-rows) (the pharmacy
workbench's stage/queue definitions). Both are pure config with **no PHI**, so
they are captured here in full — unlike the transactional tables in this
reference, which only carry schema + counts.

> **⚠️ Derived from the RXCS Liberty instance — IDs are per-tenant and DO drift.**
> These values come from the **Rx Compound Store (`rxcs`)** Liberty database
> (`RxqRxCompoundStore` on `LibertyServer`), captured **2026-08-05** (read-only).
> `cWorkflowLocationId` and `cWorkflowStageId` are `IDENTITY` columns, and each
> pharmacy tenant (`rxcs` / `mmed` / `mdvo`) runs its **own separate** Liberty
> database. **The same numeric ID means different things in different tenants,**
> and a location added to one tenant gets a new ID independently of the others —
> so these two lists will diverge over time. **This mapping is RXCS-only.** When a
> new location is added to RXCS (or the set changes), re-pull it — see
> [Regeneration](#regeneration). For `mmed` / `mdvo`, query that tenant's own
> table; do not assume ID `1019` is "Clarifications" there.

## How this maps into `liberty_link_stage` (the eMed DB)

`rxqWorkflowLocation` **is** mirrored by the ETL, **per-tenant and prefixed**:
`rxcs_rxqWorkflowLocation`, `mmed_rxqWorkflowLocation`, `mdvo_rxqWorkflowLocation`
(three separate tables, each with that tenant's own IDs). To decode which location
a script/order is sitting at, join the transaction's location column to the
**same-prefix** location table:

```sql
-- Decode a script transaction's workflow location (RXCS)
SELECT t.ScriptNumber, t.WorkflowLocation, l.Location
FROM   rxcs_rxqScriptTransaction t
LEFT JOIN rxcs_rxqWorkflowLocation l
       ON l.cWorkflowLocationId = t.WorkflowLocation;   -- int → int
```

Never cross prefixes (e.g. `rxcs_rxqScriptTransaction.WorkflowLocation` →
`mmed_rxqWorkflowLocation`) — the IDs are unrelated across tenants.

`rxqWorkflowStages` is **NOT** mirrored into `liberty_link_stage` (it isn't in
`liberty_etl_config.json`); it lives only in the source Liberty DB. It is included
here because its `FilterString` expressions are the authoritative definition of
what each workbench stage/queue actually selects — and they reference the
`WorkflowLocationId` values in the table above.

---

## `rxqWorkflowLocation` — full contents (26 rows)

The location-picker / bin values a script or order can be parked at in the
pharmacy workflow. `Parent` is the self-referential `ParentWorkflowLocationId`
(**`-1` = no parent / top-level** — a sentinel, not NULL). `Show` =
`ShowInDropdown`, `Interv` = `Intervention`.

| cWorkflowLocationId | Location | Parent (ParentWorkflowLocationId) | Show | Interv |
|--:|---|---|:--:|:--:|
| 10 | Pharmacy Use | `-1` (top-level) | ✔ | |
| 50 | Will Call | `-1` (top-level) | ✔ | |
| 60 | Auto Assign Bin | `-1` (top-level) | | |
| 1000 | Refrigerator | `50` → Will Call | ✔ | |
| 1001 | Reconstitute | `50` → Will Call | ✔ | |
| 1002 | Oversized Area | `50` → Will Call | ✔ | |
| 1003 | Paid | `-1` (top-level) | ✔ | |
| 1008 | ETST Subs | `-1` (top-level) | ✔ | |
| 1009 | Write off | `-1` (top-level) | ✔ | |
| 1010 | BZQ | `-1` (top-level) | ✔ | |
| 1015 | Bad Tirz | `-1` (top-level) | ✔ | |
| 1016 | Missing Notes | `-1` (top-level) | ✔ | |
| 1017 | `Pending ` *(trailing space — real)* | `-1` (top-level) | ✔ | |
| 1018 | PRE PAY | `-1` (top-level) | ✔ | |
| 1019 | Clarifications | `-1` (top-level) | ✔ | |
| 1020 | Ready | `-1` (top-level) | ✔ | |
| 1021 | Infinipharm Rejected | `-1` (top-level) | ✔ | |
| 1025 | Replacement | `-1` (top-level) | ✔ | |
| 1027 | RTS | `1019` → Clarifications | ✔ | ✔ |
| 1029 | Verified Clarification | `1019` → Clarifications | ✔ | |
| 1031 | In Progress | `1019` → Clarifications | ✔ | |
| 1032 | Olympia/IV | `-1` (top-level) | ✔ | ✔ |
| 1033 | JPV | `1019` → Clarifications | ✔ | |
| 1035 | ETST In Progress | `-1` (top-level) | ✔ | ✔ |
| 1037 | MA/LOT | `-1` (top-level) | ✔ | ✔ |
| 1038 | Billing | `1019` → Clarifications | ✔ | |

**Hierarchy (only two locations have children):**

- **50 Will Call** → 1000 Refrigerator · 1001 Reconstitute · 1002 Oversized Area
- **1019 Clarifications** → 1027 RTS · 1029 Verified Clarification · 1031 In Progress · 1033 JPV · 1038 Billing
- Every other location is top-level (`ParentWorkflowLocationId = -1`).

**Notes**
- `ShowInDropdown = false` for exactly one row: **60 Auto Assign Bin** (system/auto bin, hidden from the manual picker). All others show in the dropdown.
- `Intervention = true` for four rows: **1027 RTS**, **1032 Olympia/IV**, **1035 ETST In Progress**, **1037 MA/LOT** — flagged as intervention/attention steps.
- **1017 `"Pending "` has a trailing space** in the stored value — match with care (`RTRIM`) if you filter on the label.
- IDs are sparse/non-contiguous (10, 50, 60, then the 1000-block) — historical additions, not a dense sequence.

### Prod mirror freshness (captured 2026-08-05)

`rxcs_rxqWorkflowLocation` in `liberty_link_stage` matched the source on all rows
**except ID 1035**: the source reads **"ETST In Progress"** while the prod mirror
still showed **"In Progress"** at capture time. `rxqWorkflowLocation` is a
full-reload table (ETL type 2, hourly `Run-All-ETL-RXCS`), so a label rename can
lag the mirror by up to one ETL cycle. The source values above are canonical; the
mirror catches up on the next successful sync.

---

## `rxqWorkflowStages` — full contents (35 rows)

The named stages/queues in the pharmacy workbench. `Name` is the pharmacy's
display label; **`WorkflowStage`** is the built-in Liberty stage bucket the custom
stage groups under (`RPhCheck`, `Count`, `Verify`, `Ready`, `NewFills`, `Refills`,
`HasProblems`, `Rejection`, `All`, or `Unknown`). `StageType` is a coded int whose
observed grouping is: **1** = built-in top-level views (All/Refills/New Fills/
Problem/Rejections/Filled), **3** = immunization sub-views, **4** =
manually-added/generated sub-views, **0** = custom RXCS-authored stages (inferred
from the data; not documented in Liberty metadata). `LastModified` is date-only.

| cWorkflowStageId | Name | WorkflowStage | StageType | InActive | Other flags | LastModified |
|--:|---|---|:--:|:--:|---|---|
| 1 | RPhCheck | Unknown | 0 | | | 2026-07-06 |
| 2 | Count | Unknown | 0 | | | 2026-02-06 |
| 3 | Verify | Unknown | 0 | | | 2024-12-18 |
| 4 | Ready | Unknown | 0 | | | — |
| 5 | All Items | All | 1 | | | 2024-10-09 |
| 6 | Refills | Refills | 1 | | | — |
| 7 | New Fills | NewFills | 1 | | | — |
| 8 | Problem Que | HasProblems | 1 | | | 2024-10-09 |
| 9 | Rejections | Rejection | 1 | | | — |
| 10 | All Items | Count | 3 | | | — |
| 11 | Pending Administration | Count | 3 | | | — |
| 12 | Administered | Count | 3 | | | — |
| 13 | All Items | Count | 4 | | | 2022-06-30 |
| 14 | Manually Added | Count | 4 | | | 2022-06-30 |
| 15 | Generated | Count | 4 | | | 2022-06-30 |
| 16 | `.` | Count | 0 | ✔ | | 2023-12-27 |
| 17 | Prefills | RPhCheck | 0 | ✔ | | 2025-03-01 |
| 18 | Clarification | HasProblems | 1 | ✔ | *desc: "Script needs corrections"* | 2024-03-29 |
| 19 | PrePay A | RPhCheck | 0 | | | 2025-03-12 |
| 20 | Clarifications | NewFills | 1 | ✔ | | 2024-12-04 |
| 21 | Clarification A | RPhCheck | 0 | | | 2025-10-03 |
| 22 | Pick Ups | Ready | 0 | ✔ | IncludeOnHoldScripts ✔ | 2024-12-10 |
| 23 | Out of Stock | Count | 0 | ✔ | LocationChange ✔ | 2024-12-12 |
| 24 | Clarification B | Verify | 0 | | | 2025-12-02 |
| 25 | PrePay B | Count | 0 | | | 2025-03-12 |
| 26 | Infinipharm Rejected | RPhCheck | 0 | | | 2025-02-25 |
| 27 | Prefill RPh Check | RPhCheck | 0 | | | 2025-09-25 |
| 28 | Prefill Ready | Count | 0 | | | 2025-03-01 |
| 29 | RxCS RPh Check | RPhCheck | 0 | | | 2025-03-14 |
| 30 | Clarification C | Count | 0 | | | 2025-10-03 |
| 31 | Filled | NewFills | 1 | | | 2025-03-18 |
| 32 | ETST / CMP Count | Count | 0 | | | 2025-09-25 |
| 33 | Clarification | RPhCheck | 0 | ✔ | LocationChange ✔ | 2025-09-18 |
| 34 | Auto Inject Rph Check | RPhCheck | 0 | | | 2026-01-21 |
| 35 | Auto Injector Ready | Count | 0 | | | 2026-01-21 |

`StoreNumber` is NULL and `UnitDoseExport` is NULL for all 35 rows. `IncludeOnHoldScripts` is true only for **22 Pick Ups**; `LocationChange` is true only for **23 Out of Stock** and **33 Clarification**. Seven stages are inactive (16, 17, 18, 20, 22, 23, 33).

### Stage `FilterString` expressions

The workbench filter each stage applies, verbatim. These are the payoff of
capturing this table: they reference `WorkflowLocationId` / `ParentWorkflowLocationId`
(the location IDs above), `cQueueId` (→ `rxqQueue`), and drug custom fields
(`drugCustomField1..4` = `rxqDrug.CustomField1..4`) — i.e. a stage is defined by
where a script sits, which queue it's in, and its drug's custom flags. Stages not
listed here have an **empty** `FilterString` (they select purely by
`WorkflowStage` + `StageType` + the date window): 4, 5, 6, 7, 9, 10, 13, 16, 18, 20, 23.

- **1 · RPhCheck** — `[cQueueId] <> 4 And [cQueueId] <> 7 And [cQueueId] <> 13 And [cQueueId] <> 14 And [cQueueId] <> ? And Not [WorkflowLocationId] In (1021, 1019, 1031, 1033, 1027, 1038) And [drugCustomField1] <> 'RxCS RPh Check'`  *(the bare `?` is stored literally — a malformed/placeholder clause)*
- **2 · Count** — `Not [ParentWorkflowLocationId] In (1018, 1019, 1021) And [drugCustomField4] <> 'PEAKS' And Not [WorkflowLocationId] In (1017, 1008) And [drugCustomField2] <> 'CMPD' And Not [cQueueId] In (4, 7, 11, 13)`
- **3 · Verify** — `[NeedsCompounded] <> True And Not [ParentWorkflowLocationId] In (1019, 1018)`
- **8 · Problem Que** — `[Source] = 'Problem Que'`
- **11 · Pending Administration** — `[ImmunizationInfo.Administered] = False`
- **12 · Administered** — `[ImmunizationInfo.Administered] = True`
- **14 · Manually Added** — `[ManuallyAdded] = True`
- **15 · Generated** — `[ManuallyAdded] = False`
- **17 · Prefills** — `[cQueueId] In (4, 7) And [WorkflowLocationId] <> 1017 And Not [ParentWorkflowLocationId] In (1018, 1019)`
- **19 · PrePay A** — `[ParentWorkflowLocationId] = 1018`  *(1018 = PRE PAY)*
- **21 · Clarification A** — `[ParentWorkflowLocationId] = 1019`  *(1019 = Clarifications)*
- **22 · Pick Ups** — `[cQueueId] = 2`
- **24 · Clarification B** — `[ParentWorkflowLocationId] = 1019`
- **25 · PrePay B** — `[ParentWorkflowLocationId] = 1018`
- **26 · Infinipharm Rejected** — `[WorkflowLocationId] = 1021`  *(1021 = Infinipharm Rejected)*
- **27 · Prefill RPh Check** — `(Not [ParentWorkflowLocationId] In (1019, 1018) Or [WorkflowLocationId] = 1019) And [WorkflowLocationId] <> 1017 And [cQueueId] In (4, 7)`
- **28 · Prefill Ready** — `[cQueueId] In (4, 7) And Not [ParentWorkflowLocationId] In (1018, 1019) And [WorkflowLocationId] <> 1017`
- **29 · RxCS RPh Check** — `[WorkflowLocationId] <> 1017 And [drugCustomField1] = 'RxCS RPh Check' And [ParentWorkflowLocationId] <> 1019`
- **30 · Clarification C** — `[ParentWorkflowLocationId] = 1019`
- **31 · Filled** — `[WorkflowStatusText] = 'Filled'`
- **32 · ETST / CMP Count** — `([drugCustomField2] = 'CMPD' Or [cQueueId] = 11 Or [WorkflowLocationId] = 1008) And [WorkflowLocationId] <> 1017`  *(1008 = ETST Subs)*
- **33 · Clarification** — `[WorkflowLocationId] = 1019`
- **34 · Auto Inject Rph Check** — `[cQueueId] In (13, 14)`
- **35 · Auto Injector Ready** — `[cQueueId] In (13, 14) And Not [ParentWorkflowLocationId] In (1018, 1019) And [WorkflowLocationId] <> 1017`

`FilterDate` (not shown per-row) is a serialized JSON blob using .NET
`/Date(ms)/` epochs. Most stages store the min-date sentinel
(`/Date(-62135578800000)/` ≈ year 0001) meaning **no date filter**; the built-in
`StageType = 1` views (5, 8, 18, 20, 31) store a concrete rolling **"Last 30 days"**
window instead.

---

## Regeneration

Re-pull whenever RXCS locations/stages change (both are tiny — full `SELECT *`).
Read-only, from the office LAN only. **Gotcha:** `SRC_PASSWORD` in `emed_etl/.env`
contains a `#`, and `dotenv` truncates unquoted values at the first `#` — parse the
`.env` line manually (split on the first `=`, keep the rest verbatim) or the login
fails with "Login failed for user 'RXCS'". Connect on-prem SQL Server with
`options: { encrypt: false, trustServerCertificate: true }` (not the Azure
`encrypt:true` pattern), using the `SRC_*` creds and
`NODE_PATH=<emed_app>/node_modules`.

```sql
SELECT cWorkflowLocationId, Location, ParentWorkflowLocationId, ShowInDropdown, Intervention
FROM   dbo.rxqWorkflowLocation ORDER BY cWorkflowLocationId;

SELECT cWorkflowStageId, Name, WorkflowStage, Description, StageType, InActive,
       LocationChange, IncludeOnHoldScripts, ImageId, LastModified,
       CAST(FilterString AS varchar(max)) AS FilterString
FROM   dbo.rxqWorkflowStages ORDER BY cWorkflowStageId;
```

See also: [`modules/09-workflow-queues-tasks.md`](../modules/09-workflow-queues-tasks.md)
(narrative table docs) and [`ddl/rxqWorkflowLocation.sql`](../ddl/rxqWorkflowLocation.sql) /
[`ddl/rxqWorkflowStages.sql`](../ddl/rxqWorkflowStages.sql) (DDL).
