# Liberty schema — Prescribers, eScript & SureScripts

Prescriber directory (rxqDoctor) plus electronic prescribing / SureScripts messaging — inbound eScripts and responses, new-Rx and CancelRx requests, and the eScript problem queue.

> Part of the [Liberty/RxQ schema reference](../README.md). Liberty declares **no foreign-key constraints** (verified via `sys.foreign_keys`), so all relationships shown are **inferred from column naming and then data-validated** by referential match rate — each is tagged high / medium / low / no-data / unvalidated confidence. Row counts and sampled enum values are from the RXCS instance (point-in-time); the schema itself is identical across the rxcs / mmed / mdvo tenants.

**Tables in this module (8):** [`rxqDoctor`](#rxqdoctor) · [`rxqEScript`](#rxqescript) · [`rxqEscriptResponse`](#rxqescriptresponse) · [`rxqEScriptResponseTime`](#rxqescriptresponsetime) · [`rxqProblemQueue`](#rxqproblemqueue) · [`PrescriptionRequests`](#prescriptionrequests) · [`PrescriptionRequestEscripts`](#prescriptionrequestescripts) · [`rxqCancelRx`](#rxqcancelrx)

---

## `rxqDoctor`

Rows: 3,191 (RXCS) | Columns: 44 | PK: `DoctorId` | ETL-mirrored: yes (into `liberty_link_stage`, 44/44 columns mirrored — full 1:1 mirror)

**Purpose**
Master directory of prescribers (doctors) known to the pharmacy — one row per prescriber, holding demographic/practice info (name, address, contact), regulatory identifiers (DEA/DEA suffix/state license/NPI/UPIN/SPI/HIN), SureScripts e-prescribing metadata (`SPI`, `SureScriptServiceLevelCode`), and rollup activity stats (`NewRx`, `RxCount`, `LastDate`) (inferred: these look like denormalized counters updated as scripts are processed, not raw transactional data). It is referenced by prescription/order tables (`PrescriptionRequests`, `rxqScriptBase`, `rxqProfileOnlyScripts`, `rxqNewRxRequest`) via `DoctorId`, making it the prescriber lookup table for the whole scripts workflow (inferred, from inbound relationships). `SupervisingPhysicianID` and `Is340B`/`XDeaNumber` suggest support for mid-level prescribers requiring a supervising physician and for 340B-program drug eligibility tracking (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cDoctorId | int | NOT NULL | | identity |
| DoctorId | varchar(50) | NOT NULL | PK | |
| LastName | varchar(50) | NULL | | indexed (IX_cDoctor_1) |
| FirstName | varchar(50) | NULL | | indexed (IX_cDoctor) |
| MiddleInit | varchar(50) | NULL | | |
| DeaNumber | varchar(50) | NULL | | |
| StateNumber | varchar(50) | NULL | | state license number (inferred) |
| HIN | varchar(50) | NULL | | Health Industry Number (inferred) |
| UPIN | varchar(50) | NULL | | legacy Medicare prescriber ID (inferred) |
| Other | varchar(50) | NULL | | |
| Street | varchar(50) | NULL | | |
| City | varchar(50) | NULL | | |
| State | varchar(50) | NULL | | |
| Zip | varchar(50) | NULL | | |
| ZipPlus | varchar(50) | NULL | | ZIP+4 |
| Phone | varchar(50) | NULL | | |
| AlternatePhone | varchar(50) | NULL | | |
| NPI | varchar(50) | NULL | | indexed (IX_GPI); National Provider Identifier |
| LocationCode | varchar(50) | NULL | | |
| DeaSuffix | varchar(50) | NULL | | |
| Fax | varchar(50) | NULL | | |
| Contact | varchar(50) | NULL | | |
| Specialty | varchar(50) | NULL | | |
| SubDrug | varchar(50) | NULL | | |
| NewRx | int | NULL | | activity counter (inferred) |
| RxCount | int | NULL | | activity counter (inferred) |
| LastDate | date | NULL | | date of last script/activity (inferred) |
| Title | varchar(50) | NULL | | e.g. MD/DO/NP (inferred) |
| SPI | varchar(50) | NULL | | SureScripts Provider Identifier (inferred) |
| SureScriptServiceLevelCode | int | NULL | | sampled: `null` (3,191/3,191 — always null in RXCS sample) |
| LastModified | datetime | NULL | | audit timestamp |
| IsValid | bit | NULL | | sampled: `true` (3,191/3,191 — always true in RXCS sample) |
| PhoneType | char(2) | NULL | | coded phone-type, no sampled domain captured |
| AlternatePhoneType | char(2) | NULL | | coded phone-type, no sampled domain captured |
| ClinicName | varchar(50) | NULL | | |
| CustomField1 | varchar(50) | NULL | | |
| CustomField2 | varchar(50) | NULL | | |
| CustomField3 | varchar(50) | NULL | | |
| CustomField4 | varchar(50) | NULL | | |
| SupervisingPhysicianID | varchar(50) | NULL | | likely references another `rxqDoctor.DoctorId` (inferred; not data-validated — no inferred_relationships edge reported) |
| InActive | bit | NULL | | sampled: `false` (3,177), `true` (14) |
| Suite | varchar(50) | NULL | | |
| Is340B | bit | NULL | | 340B drug-program flag (inferred) |
| XDeaNumber | varchar(50) | NULL | | secondary/expired(?) DEA number (inferred) |

**Relationships**
Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

These are all INFERRED from column naming and DATA-VALIDATED against actual key values — NOT declared constraints.

- **Outbound (inferred):** none reported (no outbound edges found from `rxqDoctor`'s own columns to other tables, including `SupervisingPhysicianID`, which is a plausible self-reference but was not captured as a validated edge).
- **Inbound (inferred):**
  - `PrescriptionRequests.DoctorId` → `rxqDoctor` — inferred, **high** confidence (100.0% referential match)
  - `rxqProfileOnlyScripts.DoctorId` → `rxqDoctor` — inferred, **high** confidence (100.0% referential match)
  - `rxqScriptBase.DoctorId` → `rxqDoctor` — inferred, **high** confidence (100.0% referential match)
  - `HistoricalAppointment.DoctorId` → `rxqDoctor` — **no-data** confidence (no rows to validate against)
  - `rxqNewRxRequest.DoctorId` → `rxqDoctor` — **no-data** confidence (no rows to validate against)

**Indexes**
- `IX_cDoctor` (NONCLUSTERED) on `FirstName` — name lookup.
- `IX_cDoctor_1` (NONCLUSTERED) on `LastName` — name lookup.
- `IX_GPI` (NONCLUSTERED) on `NPI` — prescriber lookup by National Provider Identifier (name is misleading — not GPI drug-code related).

**Gotchas**
- PK `DoctorId` is `varchar(50)`, not the identity `cDoctorId` int column — joins from other Liberty tables use the varchar `DoctorId`, not the surrogate int.
- `SupervisingPhysicianID` strongly suggests a self-referencing hierarchy (mid-level prescriber → supervising MD) but no validated edge exists in the metadata; treat as unconfirmed.
- `SureScriptServiceLevelCode` and `IsValid` are constant across the entire RXCS sample (all null / all true respectively) — likely not actively used/varied in this tenant, or only populated for a subset never sampled.
- `PhoneType`/`AlternatePhoneType` are coded `char(2)` fields with no captured lookup domain — decode meaning from application code or SureScripts spec if needed.
- Table name is internally called out as `IX_GPI` despite indexing `NPI` — naming does not reflect content; don't assume a GPI (drug classification) relationship.

---

## `rxqEScript`

Rows (RXCS): 103,753 · Columns: 19 · PK: `eScriptId` · ETL-mirrored: yes (into `liberty_link_stage`)

**Purpose**

Stores incoming NCPDP SCRIPT (SureScripts) electronic-prescription messages, one row per e-prescription message received, including the raw message XML (`XmlData`), SureScripts transport metadata (`MessageId`, `LibertyMessageNumber`, `RxReferenceNumber`, `RefillRequestReferenceNumber`), and validity/processing flags (`IsValid`, `AlertSent`). It links (loosely) to the patient the message concerns (`PatientId` → `rxqPatient`) and to the internal script it resolves to (`ScriptNumber` → `rxqScriptBase`). `CreatedYYYYMMDD`/`CreatedHHMMSS` (inferred: split date/time strings from the inbound message header) and `eScriptCreated` (a proper datetime) both timestamp message receipt. `Source` is an uncoded int flag, currently all-NULL in sampled data, likely distinguishing New-Rx vs RefillResponse vs other e-script message types (inferred). Downstream, `PrescriptionRequestEscripts` and `rxqProblemQueue` reference rows here almost universally, indicating this table is the durable inbound queue/log that prescription-intake and exception-handling workflows are built on top of.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cEScriptId | int | NO | | identity (surrogate row counter, not the PK) |
| eScriptId | int | NO | PK | business/message key, non-identity |
| ScriptNumber | int | YES | → rxqScriptBase | |
| CreatedYYYYMMDD | varchar(50) | YES | | inferred: message-header date string |
| CreatedHHMMSS | varchar(50) | YES | | inferred: message-header time string |
| XmlData | text | YES | | raw NCPDP SCRIPT XML payload |
| MINREC_LEN | int | YES | | inferred: message length metadata (record-length bounds) |
| MAXREC_LEN | int | YES | | inferred: message length metadata (record-length bounds) |
| LastModified | datetime | YES | | row-modification audit timestamp |
| IsValid | bit | YES | | sampled values: `true` (103,753 / 103,753 — 100% of sampled rows) |
| LibertyMessageNumber | int | NO | | indexed (IX_rxqEScript_LibertyMessageNumber); internal Liberty message sequence number |
| LibertySignature | text | YES | | inferred: digital-signature/integrity payload for the message |
| AlertSent | varchar(1) | YES | | inferred: Y/N-style flag, no sampled values captured |
| RxReferenceNumber | varchar(max) | YES | | SureScripts reference number for the Rx |
| MessageId | varchar(50) | YES | | SureScripts message GUID/identifier |
| PatientId | varchar(50) | YES | → rxqPatient | varchar-typed key |
| eScriptCreated | datetime | YES | | message receipt/creation timestamp |
| Source | int | YES | | sampled values: `NULL` (103,753 / 103,753 — column all-NULL in this table's data) |
| RefillRequestReferenceNumber | varchar(100) | YES | | SureScripts reference number for a refill request message |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

These edges are inferred from column naming and DATA-VALIDATED against actual key values — not declared constraints. Treat low/no-data/unvalidated confidence as weak/unconfirmed guesses.

- **Outbound (inferred)**
  - `PatientId` → `rxqPatient` — inferred, **high** confidence (95.7% referential match; 51,596 non-null values checked, 2,213 orphans).
  - `ScriptNumber` → `rxqScriptBase` — inferred, **medium** confidence (78.8% referential match; 103,753 non-null values checked, 22,052 orphans).

- **Inbound (inferred)**
  - `PrescriptionRequestEscripts.eScriptId` → this table — inferred, **high** confidence (100.0% referential match).
  - `rxqProblemQueue.eScriptId` → this table — inferred, **high** confidence (99.2% referential match).
  - `LtcMessage.eScriptId` → this table — inferred, **no-data** confidence (no rows to validate).
  - `rxqNewRxRequest.eScriptId` → this table — inferred, **no-data** confidence (no rows to validate).

**Indexes**

- `IX_rxqEScript_LibertyMessageNumber` (NONCLUSTERED, non-unique) on `LibertyMessageNumber` — supports lookup by Liberty's internal message sequence number, likely used for message-processing/dedup workflows.

**Gotchas**

- `PatientId` is `varchar(50)` (not int) despite most patient keys elsewhere typically being numeric — join carefully, mind implicit string/int conversions.
- `ScriptNumber` orphan rate (~21%) is materially higher than `PatientId`'s (~4%) — a meaningful fraction of e-script messages don't yet (or never) resolve to a `rxqScriptBase` row; don't assume every e-script became a fillable script.
- `Source` and `AlertSent` are present but uncoded/empty in sampled data — their intended enum domains are undocumented here; don't infer meaning beyond "inferred" guesses above.
- `cEScriptId` (identity surrogate) vs `eScriptId` (actual PK) is a classic Liberty double-key pattern — don't confuse the two when joining.
- `XmlData`/`LibertySignature` are unbounded text — full message payload and signature live here, not in the ETL-mirrored column set (only `XmlData` is mirrored; `LibertySignature` is not, per `mirrored_columns`).

---

## `rxqEscriptResponse`

Rows (RXCS): 738 | Columns: 2 | PK: `ResponseEscriptId` | ETL-mirrored into liberty_link_stage: no

**Purpose** — A minimal linking table pairing a "response" e-script record (`ResponseEscriptId`, PK) with a "request" e-script record (`RequestEscriptId`). (inferred) This shape is consistent with SureScripts/NCPDP SCRIPT transaction handling, where an inbound e-prescription request (e.g., NewRx, RxRenewalRequest) is matched to its corresponding outbound response (e.g., RxRenewalResponse, Status/Verify) — but no other columns (timestamps, status codes, message types) exist here to confirm the specific transaction semantics beyond the request/response pairing itself.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| ResponseEscriptId | int | NOT NULL | PK | |
| RequestEscriptId | int | NOT NULL | (no implicit_ref detected) | Likely references a request-side escript table (e.g. `rxqEscriptRequest`) by naming convention, but this was not confirmed by the inference pass — no `implicit_ref` recorded. |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — `inferred_relationships` is empty for this table (no data-validated outbound edges detected, despite `RequestEscriptId`'s naming suggesting a link to a request-side escript table).
- **Inbound (inferred):** none — `inferred_referenced_by` is empty (no other table's columns were data-validated as pointing into this table).

**Indexes** — none reported (no indexes defined beyond the implicit PK).

**Gotchas**
- Only 2 columns total; this is a pure junction/pairing record with no status, timestamp, or message-type metadata — any workflow meaning (e.g., which NCPDP transaction type) must come from joining to other escript tables, not from this table alone.
- `RequestEscriptId` has no confirmed inferred relationship despite the naming symmetry with `ResponseEscriptId` — treat any assumed link to a request table as unconfirmed until validated.
- Not mirrored by ETL into liberty_link_stage, so this pairing is not available in the eMed application's mirrored data; any downstream consumer needing request/response escript linkage must query Liberty directly.

---

## `rxqEScriptResponseTime`

Rows (RXCS): 2 · Columns: 6 · PK: `cEScriptResponseTimeId` · ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores aggregate response-time metrics — a count of responses (`Responses`) and an average turnaround (`AverageMinutes`) — keyed by a generic `LookUpId`/`LookUpType` pair (inferred). The name and column shape suggest it tracks how quickly e-prescribing (eScript/SureScript) responses come back for a given lookup entity, likely for SLA/performance monitoring rather than per-transaction detail (inferred). With only 2 rows and a non-unique, weakly-matched `LookUpId`, this looks like a small rollup/summary table rather than a high-volume operational log (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cEScriptResponseTimeId | int | NO | PK | identity |
| LookUpId | varchar(50) | YES | → rxqPatientPreferences (weak, see Relationships) | generic lookup key, not necessarily a patient reference |
| LookUpType | int | YES | | coded domain, sampled values: `1` (count 1), `0` (count 1) |
| Responses | int | YES | | likely a count of eScript responses received (inferred) |
| AverageMinutes | int | YES | | likely average response latency in minutes (inferred) |
| LastModified | datetime | YES | | last-updated timestamp |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):**
  - `LookUpId` → `rxqPatientPreferences` (join col `LookUpId`) — inferred, **low** confidence (50.0% referential match, not sampled). Only 2 non-null values checked, 1 orphan; the generic `LookUpId`/`LookUpType` naming pattern suggests this column is a polymorphic key that may point to different parent tables depending on `LookUpType`, not exclusively `rxqPatientPreferences` — treat this edge as an unconfirmed guess.
- **Inbound (inferred):** none.

**Indexes**

None declared beyond the implicit PK constraint.

**Gotchas**

- Tiny table (2 rows) — any match-rate/confidence stats here are not statistically meaningful; don't treat the "low confidence" verdict as proof the relationship doesn't exist, just that there isn't enough data to confirm it.
- `LookUpId`/`LookUpType` is a classic polymorphic-key pattern (generic name + type discriminator + varchar id) — the single inferred edge to `rxqPatientPreferences` is likely only one of several possible target tables depending on `LookUpType`'s value; do not assume it's the sole referent.
- Not ETL-mirrored to liberty_link_stage, so this data is not available to eMed application code — any consumer needs direct Liberty DB access.

---

## `rxqProblemQueue`

Rows (RXCS): 1,156 | Columns: 9 | PK: `cProblemQueueId` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores a queue of flagged problems/exceptions tied to e-prescriptions, each carrying a category, free-text note, and timestamps (inferred). The dominant linkage is `eScriptId` → `rxqEScript` (99.2% match), indicating this queue is primarily an eScript-processing exception log — e.g. eScript intake/adjudication issues surfaced for pharmacist review (inferred). `ScriptNumber` is also present but only matches `rxqScriptBase` at 0.69%, so despite its name it is NOT a reliable link to the dispensed-script table in this dataset (inferred: likely holds a different numbering scheme, e.g. the eScript's own script/order number, or is frequently populated after the queue entry is created and before a script is filled). `UserId` (nvarchar) suggests the record also tracks which user/operator is associated with or resolved the problem (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `cProblemQueueId` | int | NO | PK | identity |
| `ScriptNumber` | int | YES | → `rxqScriptBase` (weak) | inferred ref, but only 0.69% match rate — see Relationships |
| `RefillNumber` | int | YES | | |
| `UserId` | nvarchar(50) | YES | | |
| `ProblemCategory` | varchar(100) | YES | | no lookups sampled — coded domain unknown |
| `ProblemNotes` | varchar(max) | YES | | free text |
| `ProblemDate` | datetime | YES | | |
| `LastModified` | datetime | YES | | |
| `eScriptId` | int | YES | → `rxqEScript` | inferred ref, high confidence — see Relationships |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**
  - `eScriptId` → `rxqEScript` — inferred, **high** confidence (99.2% referential match; 1,156 non-null, 9 orphans).
  - `ScriptNumber` → `rxqScriptBase` — inferred, **low** confidence (0.69% referential match; 1,156 non-null, 1,148 orphans). Naming suggests a link, but the data does not support it as a reliable join to `rxqScriptBase`; treat as unconfirmed/likely a different identifier space.
- **Inbound (inferred)**
  - none.

**Indexes**

None reported (empty index list — no declared indexes beyond the implicit PK clustering, if any).

**Gotchas**

- `ScriptNumber` is misleading by name: it does not reliably join to `rxqScriptBase.ScriptNumber` (0.69% match). Do not use it as a join key without independent verification; prefer `eScriptId` for linking to eScript data.
- `ProblemCategory` has no sampled lookup values in this extract, so its coded domain (e.g. eligibility/DUR/insurance/etc.) is undocumented here — confirm against application code or a live data pull before assuming specific category values.
- No indexes were reported, which is notable for a queue table expected to be polled/filtered by category or date (inferred operational risk, not confirmed).
- Not ETL-mirrored into liberty_link_stage — any eMed-side reporting or reconciliation needs a separate extraction path for this table.

---

## `PrescriptionRequests`

Rows (RXCS): 36 | Columns: 16 | PK: `ID` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Tracks refill/renewal-request outreach for a script — i.e. requests sent to (or generated for) a prescriber's office to authorize continuing therapy. It links a `ScriptNumber` (medium-confidence, `rxqScriptBase`), `PatientId` (`rxqPatient`), `DrugKey` (`rxqDrug`), and `DoctorId` (`rxqDoctor`), and records `FirstRequest`/`LastRequest` timestamps, an `Attempts` counter, a `Completed` flag, and a `DateDenied` timestamp — consistent with a workflow that retries contacting a prescriber until the request is answered (approved/completed) or denied (inferred). `Method` (values 1/2/3, e.g. fax/phone/eScript — inferred, not confirmed by metadata) and `eScriptTransactionId` suggest requests can be sent via multiple channels, with the latter tying a request to a SureScripts/eScript renewal-response transaction (inferred). `History` (varchar(max)) likely holds a free-text or serialized log of the request's attempt history (inferred). `Type` (0/1) and `Status` (coded int, values 2/3/4/6/10) are unlabeled coded fields — domain meaning not derivable from metadata alone.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| ID | int | NO | PK | identity |
| ScriptNumber | int | YES | → `rxqScriptBase` | |
| PatientId | varchar(50) | YES | → `rxqPatient` | |
| DrugKey | varchar(50) | YES | → `rxqDrug` | |
| DoctorId | varchar(50) | YES | → `rxqDoctor` | |
| Method | int | YES | | coded domain: 1 (26), 2 (7), 3 (3) |
| Type | int | NO | | coded domain: 0 (34), 1 (2) |
| Status | int | YES | | coded domain: 2 (14), 10 (9), 4 (5), 6 (4), 3 (4) |
| FirstRequest | datetime | YES | | indexed |
| LastRequest | datetime | YES | | indexed |
| Attempts | int | YES | | |
| History | varchar(max) | YES | | |
| StoreNumber | varchar(2) | YES | | |
| Completed | bit | NO | | |
| eScriptTransactionId | int | YES | | |
| DateDenied | datetime | YES | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

These are column-name-inferred edges, data-validated against actual key values in each parent table — not enforced constraints.

- Outbound (inferred):
  - `PatientId` → `rxqPatient` — inferred, **high** confidence (100.0% referential match)
  - `DrugKey` → `rxqDrug` (join on `DrugId`) — inferred, **high** confidence (100.0% referential match)
  - `DoctorId` → `rxqDoctor` — inferred, **high** confidence (100.0% referential match)
  - `ScriptNumber` → `rxqScriptBase` — inferred, **medium** confidence (94.4% referential match, 2 orphans of 36 non-null)
- Inbound (inferred): none

**Indexes**

- `IX_PrescriptionRequests_FirstRequest` (NONCLUSTERED, key: `FirstRequest`) — supports lookups/sweeps by initial request date.
- `IX_PrescriptionRequests_LastRequest` (NONCLUSTERED, key: `LastRequest`) — supports lookups/sweeps by most recent request date (e.g. retry/aging queries).

**Gotchas**

- `PatientId` and `DoctorId` are varchar(50) despite being identifier-like — join carefully against parent PK types.
- `ScriptNumber` has 2 orphaned rows (5.6%) against `rxqScriptBase` — don't assume every request row resolves to a live script.
- `Status`/`Type`/`Method` are unlabeled integer codes with no lookup/reference table in this metadata; treat listed values as the observed domain only, not a confirmed enum — meanings above are inferred from naming, not verified.
- Table is small (36 rows) and NOT ETL-mirrored, so any consuming logic must query Liberty/RxQ directly rather than via liberty_link_stage.

---

## `PrescriptionRequestEscripts`

Rows (RXCS): 26 | Columns: 3 | PK: `MessageId` | ETL-mirrored into liberty_link_stage: no

**Purpose**
Junction table linking a pharmacy-side prescription request (`PrescriptionRequestId`) to an inbound e-prescribing message (`eScriptId`, → `rxqEScript`), keyed by a 32-char message identifier (`MessageId`) — likely the SureScripts/NCPDP SCRIPT message GUID (inferred). Its small row count (26) and lack of ETL mirroring suggest a low-volume or legacy/edge-case linkage table rather than the primary e-script ingestion path (inferred).

**Columns**
| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| MessageId | char(32) | NOT NULL | PK | Fixed-length 32-char identifier, likely an e-script message GUID/hash (inferred) |
| PrescriptionRequestId | int | NOT NULL | | No inferred reference resolved to a parent table despite the naming pattern |
| eScriptId | int | NOT NULL | → `rxqEScript` | Inferred FK to `rxqEScript.eScriptId` |

**Relationships**
Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**:
  - `eScriptId` → `rxqEScript` (join col `eScriptId`) — inferred, **high** confidence (100.0% referential match, 26/26 non-null values resolved, 0 orphans; not sampled — full check).
  - `PrescriptionRequestId` — no inferred relationship detected/recorded despite the name implying a link to a prescription-request parent table; treat as unconfirmed/unmodeled.
- **Inbound (inferred)**: none recorded.

**Indexes**
None reported (indexes list empty in metadata — only the implicit PK constraint on `MessageId` is known to exist).

**Gotchas**
- `MessageId` is a char(32) primary key, not a surrogate int — likely an externally-sourced e-script message ID; watch for padding/case-sensitivity issues in joins.
- `PrescriptionRequestId` has no inferred/validated parent despite its name — do not assume it reliably joins to a `rxqPrescriptionRequest`-style table without independent verification.
- Not ETL-mirrored, so this table is invisible to liberty_link_stage-based reporting/queries; any analysis needing it must query the Liberty DB directly.
- Only 26 rows total — too small a sample to generalize confidence beyond this table; low-volume tables like this are more prone to being legacy/dead code paths.

---

## `rxqCancelRx`

Rows (RXCS): 837 · Columns: 7 · PK: `RequestEscriptId` · ETL-mirrored into liberty_link_stage: no

**Purpose**

Tracks CancelRx transactions — SureScripts/NCPDP electronic requests (typically from a prescriber's EHR) to cancel a previously transmitted prescription (inferred, from column naming and NCPDP CancelRx domain knowledge). `ScriptNumber` optionally links the cancel request to a specific script in `rxqScriptBase`; `PendingScriptTransactionId` suggests a queued/pending-transaction workflow (inferred, meaning of the column not otherwise evidenced). `Status` is a small coded workflow state (values 0, 1, 2 sampled) tracking the cancel request's processing/resolution state (inferred — exact state semantics not given). `DateCreated`/`LastModified` provide standard audit timestamps.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| RequestEscriptId | int | NOT NULL | PK | |
| StoreNumber | varchar(2) | NOT NULL | | store/tenant location code |
| ScriptNumber | int | NULL | → rxqScriptBase | inferred ref (medium confidence, see Relationships) |
| PendingScriptTransactionId | int | NULL | | no inferred ref; likely links to a pending-transaction queue (inferred) |
| DateCreated | datetime | NOT NULL | | audit: row creation |
| LastModified | datetime | NOT NULL | | audit: last update |
| Status | int | NOT NULL | | coded workflow status. Sampled values: `0` (count 481), `1` (count 352), `2` (count 4) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**:
  - `ScriptNumber` → `rxqScriptBase` (join on `ScriptNumber`) — inferred, **medium** confidence (91.8% referential match; 207 non-null values checked, 17 orphans; not sampled)
- **Inbound (inferred)**: none

These edges are inferred purely from column naming and then data-validated against actual parent-table values — not enforced/declared constraints. The medium-confidence outbound edge (91.8% match, 17 orphans) should be treated as a likely-but-unconfirmed relationship, not a guaranteed join.

**Indexes**

None reported (index list empty in metadata).

**Gotchas**

- `ScriptNumber` is nullable and only ~91.8% resolves to `rxqScriptBase` — 17 orphaned values in the sampled non-null set, so joins should tolerate misses rather than assuming full referential integrity.
- `PendingScriptTransactionId` has no inferred reference target despite its name suggesting a link to another transaction/queue table — treat its relationship as unknown, not absent.
- Not mirrored by ETL into liberty_link_stage, so this data is unavailable to downstream eMed reporting/analytics without a direct pharmacy-DB query.
- `Status` is a bare int with no lookup/label table found; only the 3 sampled values (0, 1, 2) are confirmed to occur — meaning of each code is not evidenced (inferred workflow-state only).

---
