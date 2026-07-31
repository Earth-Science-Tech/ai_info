# Liberty schema — Notes, Messaging, SMS & Fax

Free-text notes and custom-field types, patient messaging (with script links and attachments), SMS, internal staff messaging, fax center, and the shared image/document store.

> Part of the [Liberty/RxQ schema reference](../README.md). Liberty declares **no foreign-key constraints** (verified via `sys.foreign_keys`), so all relationships shown are **inferred from column naming and then data-validated** by referential match rate — each is tagged high / medium / low / no-data / unvalidated confidence. Row counts and sampled enum values are from the RXCS instance (point-in-time); the schema itself is identical across the rxcs / mmed / mdvo tenants.

**Tables in this module (12):** [`rxqNotes`](#rxqnotes) · [`rxqCustomFields`](#rxqcustomfields) · [`rxqPatientMessage`](#rxqpatientmessage) · [`rxqPatientMessageScriptTransactions`](#rxqpatientmessagescripttransactions) · [`rxqPatientMessageAttachment`](#rxqpatientmessageattachment) · [`rxqSMSMessage`](#rxqsmsmessage) · [`rxqFaxCenter`](#rxqfaxcenter) · [`rxqImageControl`](#rxqimagecontrol) · [`rxqMessages`](#rxqmessages) · [`rxqInternalMessaging`](#rxqinternalmessaging) · [`rxqInternalMessagingUserMessage`](#rxqinternalmessagingusermessage) · [`rxqInternalMessagingGroup`](#rxqinternalmessaginggroup)

---

## `rxqNotes`

Rows (RXCS): 407,166 | Columns: 14 | PK: `cNotesId` | ETL-mirrored: yes (into `liberty_link_stage`, all 14 columns)

**Purpose**
A generic, polymorphic notes/annotation table used across the Liberty system: each row is a free-text `Message` attached to some parent entity via a `(Type, TypeKey)` pair rather than a typed foreign key (inferred — `TypeKey` is varchar and validation against `rxqCustomFields` failed on type conversion, so the actual parent table varies by `Type` value and is not reliably `rxqCustomFields`). Notes carry both an `OriginalDate`/`OriginalTech` (creation) and `LastDate`/`LastTech`/`LastModified` (last-edit) audit trail, a soft-delete/active flag (`IsValid`), a display `Behavior` code controlling how/where the note surfaces, an optional `CategoryId` grouping, and UI flags for pinning (`Pinned`) and register-visibility (`ShowAtRegister`). The clustered index and the mirrored column set both key off `(Type, TypeKey)`, confirming that is the primary lookup path for retrieving all notes on a given parent record (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cNotesId | int | NO | PK | identity |
| Type | varchar(50) | NO | | discriminator naming the parent entity/context (e.g. which table/screen `TypeKey` points into); no sampled values available |
| TypeKey | varchar(50) | NO | → rxqCustomFields (unvalidated) | polymorphic parent key, paired with `Type`; string-typed even when parent PK is int (see Gotchas) |
| OriginalDate | datetime | YES | | note creation timestamp (inferred) |
| LastDate | datetime | YES | | last-edit timestamp (inferred) |
| Message | text | YES | | free-text note body |
| LastModified | datetime | YES | | modification audit timestamp, distinct from `LastDate` (inferred) |
| IsValid | bit | YES | | active/soft-delete flag — sampled: `true`=395,486, `false`=11,680 |
| Behavior | char(1) | YES | | display/behavior code — sampled: `D`=288,224, `N`=117,417, `' '`(blank)=1,514, `C`=5, `P`=4, `NULL`=2 |
| CategoryId | int | YES | | note category grouping — sampled: `0`=407,164 (i.e. effectively always 0), `NULL`=2; suggests categorization is largely unused in this tenant |
| OriginalTech | varchar(50) | YES | | tech/user id who created the note (inferred) |
| LastTech | varchar(50) | YES | | tech/user id who last modified the note (inferred) |
| ShowAtRegister | bit | YES | | UI flag: surface note at POS register (inferred) |
| Pinned | datetime | YES | | pin timestamp/flag; datetime-typed rather than bit, so likely stores "pinned since" rather than a boolean (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**
  - `TypeKey` → `rxqCustomFields` (join on `TypeKey`) — inferred, **unvalidated** confidence: data-validation errored out (`Conversion failed when converting the varchar value 'ADPW' to data type int`), meaning `TypeKey`'s actual values (e.g. `'ADPW'`) are not integers and don't match `rxqCustomFields`'s key type. This is a naming-based guess only — treat as unconfirmed/likely wrong for at least some `Type` values, since `TypeKey` is polymorphic and its true parent table depends on the co-occurring `Type` value.
- **Inbound (inferred)**: none.

**Indexes**
- `IX_rxqNotes` (CLUSTERED) on `(Type, TypeKey)` — primary access path for fetching all notes for a given parent entity.
- `IDX_rxqNotes_Type_IsValid` (NONCLUSTERED) on `(Type, IsValid)` including `TypeKey` — supports filtering active/valid notes by type without a key lookup.

**Gotchas**
- `TypeKey` is varchar despite likely referencing integer parent PKs in many cases — the sampled failure value `'ADPW'` shows it's not purely numeric, confirming true polymorphism (parent table/key format varies by `Type`). Do not assume a single join target.
- No declared or reliably data-validated FK exists for `TypeKey` — any join to a parent table must first filter/branch on `Type` and validate types before joining.
- Three near-duplicate audit fields (`OriginalDate`, `LastDate`, `LastModified`) exist with no metadata distinguishing them precisely — semantics are inferred, not confirmed.
- `CategoryId` is populated with `0` for effectively all rows (407,164/407,166) — treat as a non-discriminating/legacy column in this tenant, not a meaningful category dimension.
- `Behavior` is a single-char code with a long-tail/rare values (`C`, `P`, blank, NULL) alongside two dominant codes (`D`, `N`) — meaning of each code is not documented in metadata (inferred only from frequency).

---

## `rxqCustomFields`

Rows: 14 (RXCS) · Columns: 5 · PK: `Type`, `TypeKey` · ETL-mirrored into `liberty_link_stage`: no

**Purpose**
Defines custom/user-configurable field definitions (name + choice list) keyed by a `Type` code and a `TypeKey` discriminator, functioning as a small metadata/config table rather than transactional data. Each row supplies a `FieldName` label and a `FieldChoices` value list, suggesting it drives dropdown/custom-attribute definitions surfaced elsewhere in the Liberty UI (inferred). The composite PK (`Type`, `TypeKey`) rather than the identity column `cCustomFieldsId` being primary indicates rows are addressed by category+subtype rather than by surrogate id (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cCustomFieldsId | int | No | | identity |
| Type | char(1) | No | PK | sampled values: `D` (4), `A` (4), `P` (4), `I` (2) |
| TypeKey | int | No | PK | sampled values: `2` (4), `1` (4), `4` (3), `3` (3) |
| FieldName | varchar(50) | Yes | | |
| FieldChoices | varchar(max) | Yes | | |

**Relationships**
Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none.
- **Inbound (inferred):**
  - `rxqNotes.TypeKey` → this table's `TypeKey` — inferred, **unvalidated** confidence (parent/child relationship not data-validated; match rate not computed).

**Indexes**
None reported (indexes list is empty).

**Gotchas**
- No declared or validated FK edges at all in either direction (the one inbound edge is `unvalidated`) — treat any join from `rxqNotes` (or elsewhere) to this table via `TypeKey` alone as a weak/unconfirmed guess, since `TypeKey` is a bare int with no compound match to `Type` verified.
- Composite/coded PK (`Type` + `TypeKey`) rather than the identity `cCustomFieldsId` — joins likely need both columns together, not just `TypeKey`, to disambiguate rows (e.g. `rxqNotes` would need its own type code to safely match).
- Tiny table (14 rows) with only 4 distinct `Type` codes (`D`, `A`, `P`, `I`) and 4 distinct `TypeKey` values (1–4) sampled — consistent with a small enumerated config/lookup set rather than growing operational data; no data dictionary observed for what `D`/`A`/`P`/`I` denote (not asserted beyond sampled letters).

---

## `rxqPatientMessage`

Rows (RXCS): 68,412 | Columns: 21 | PK: `id` | ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores outbound/inbound patient communication events (SMS/email/portal-style messages) — subject, body (plain and `EncodedMessageBody`), send status/result/retry tracking, and read/attachment flags — tied to a patient via `PatientId` (inferred). Columns like `MessageSent`, `MessageSuccess`, `MessageRetryCount`, `MessageReferenceNumber`, and `SentBy`/`LoggedInUser` indicate this is an operational delivery log for a messaging subsystem (inferred), with `Outbound` distinguishing direction and `AlertType`/`MessageType` coding the message category (inferred — AlertType domain sampled below, MessageType not sampled). Not currently pulled by ETL into the eMed mirror, so this data is Liberty-side only.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| id | varchar(50) | NO | PK | |
| MessageBody | nvarchar(max) | YES | | plain-text message content |
| MessageSubject | varchar(255) | YES | | |
| MessageCreatedOn | datetime | YES | | indexed (`MessageCreateDateIndex`) |
| MessageSent | bit | YES | | send-attempted flag |
| MessageTo | varchar(max) | YES | | recipient address(es) |
| MessageSuccess | bit | YES | | delivery success flag |
| MessageType | int | YES | | coded message type; no sampled values available |
| PatientId | varchar(50) | YES | → rxqPatient | indexed (`PatientIdIndex`) |
| MessageResult | varchar(max) | YES | | raw result/response text from send attempt |
| MessageReferenceNumber | varchar(max) | YES | | external/provider message reference id |
| SentBy | varchar(50) | YES | | sender identifier (user/system) |
| MessageRetryCount | int | YES | | number of send retries |
| AlertType | int | YES | | coded alert category — sampled values: `5` (62,376), `-1` (5,757), `12` (279) |
| StoreNumber | varchar(50) | YES | | indexed (composite w/ MessageRead, Outbound) |
| MessageRead | bit | YES | | read/unread flag |
| Outbound | bit | YES | | direction flag (outbound vs inbound) |
| MessageFrom | varchar(max) | YES | | sender address(es) |
| EncodedMessageBody | varchar(max) | YES | | encoded/escaped copy of message body |
| HasAttachments | bit | YES | | attachment presence flag |
| LoggedInUser | varchar(200) | YES | | user session context at message creation/send |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**
  - `PatientId` → `rxqPatient` — inferred, **high** confidence (98.6% referential match; 987 orphans out of 68,412 non-null values).
- **Inbound (inferred)**
  - none

**Indexes**
- `IX_PatientMessage_StoreNumber, MessageRead, Outbound` (nonclustered, composite) — supports per-store unread/outbound message queues.
- `MessageCreateDateIndex` (nonclustered, `MessageCreatedOn`) — supports date-range/chronological message retrieval.
- `PatientIdIndex` (nonclustered, `PatientId`) — supports per-patient message history lookup.

**Gotchas**
- `id` PK is `varchar(50)`, not an integer identity — likely an externally-generated or composite string key (not sampled here).
- `MessageType` is int-typed but has no sampled lookup values in this extract — treat its domain as unknown, do not assume overlap with `AlertType`.
- ~1.4% of `PatientId` values (987 rows) don't resolve to `rxqPatient` — likely deleted/purged patients or system-generated messages not tied to a live patient record.
- Body is duplicated across `MessageBody` and `EncodedMessageBody` — likely raw vs. transport-encoded copies of the same content (inferred); confirm which is canonical before using either for display.
- Table not mirrored by ETL — any eMed-side use of patient messaging history would require a new extraction path.

---

## `rxqPatientMessageScriptTransactions`

Rows (RXCS): 62,421 | Columns: 3 | PK: `PatientMessageId, ScriptNumber, RefillNumber` | ETL-mirrored into liberty_link_stage: no

**Purpose**

A pure junction/link table associating a patient message (`PatientMessageId`) with one or more script/refill transactions (`ScriptNumber` + `RefillNumber`). It has no descriptive columns of its own — no timestamps, status, or content — so it functions solely as a many-to-many bridge letting a single patient message reference one or more specific fill events on `rxqScriptBase` (inferred). This is consistent with pharmacy messaging workflows where an outbound/inbound patient communication (e.g. refill-ready notice, IVR/text alert) is tied back to the triggering script transaction (inferred). The composite PK including `RefillNumber` implies a message can be scoped to a specific refill of a script, not just the script as a whole (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| PatientMessageId | varchar(50) | NO | PK | varchar surrogate key, likely generated by the messaging subsystem rather than DB identity (no identity/default set) |
| ScriptNumber | int | NO | PK, → `rxqScriptBase` | inferred FK to `rxqScriptBase.ScriptNumber` |
| RefillNumber | int | NO | PK | no inferred parent; likely composite with ScriptNumber to identify a specific fill/refill instance of the script (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**
  - `ScriptNumber` → `rxqScriptBase` — inferred, **high** confidence (99.97% referential match, 62,421 non-null / 19 orphans, not sampled).

- **Inbound (inferred)**
  - `rxqPatientBulkMessage.PatientMessageId` → this table — **no-data** confidence (parent/child had no rows to validate against; unconfirmed).
  - `rxqPatientMessageAttachment.PatientMessageId` → this table — **low** confidence (0.0% referential match) — treat as an unconfirmed/likely-spurious naming coincidence, not a real link.

**Indexes**

None reported (indexes list empty aside from the implicit composite PK).

**Gotchas**

- `PatientMessageId` is a varchar(50) key, not an int/identity — joins against it must match on string equality; confirm formatting (e.g. leading zeros, GUID-like values) before joining.
- No content/status/timestamp columns exist here — any message text, channel, or send-status must be looked up on `rxqPatientBulkMessage` (or another message table) via `PatientMessageId`, but that inbound edge is currently **no-data** (unvalidated) in this extract.
- The `rxqPatientMessageAttachment` inbound edge is a near-zero match (low confidence) — do not assume attachments join through this table without re-validating on fresh data.
- Not ETL-mirrored to liberty_link_stage — this table is invisible to eMed's normal data pipeline; any consumer needing patient-message/refill linkage must query Liberty directly.

---

## `rxqPatientMessageAttachment`

Rows (RXCS): 96 | Columns: 4 | PK: `id` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores binary/text attachment payloads (`Data`) associated with a patient message, keyed by `PatientMessageId` and typed by `DataType` (inferred). The name and shape strongly suggest this is the attachment/blob table for a patient-messaging feature (e.g. an image or document attached to an SMS/portal/refill-related message) (inferred). All 96 sampled rows carry `DataType = 1`, suggesting a single attachment kind (e.g. image) is in active use, or the coded domain (inferred) is otherwise underexploited in this instance. The `PatientMessageId` column does not match any value in the table its name implies it should reference (0% match, see Relationships), so its actual parent table/entity cannot be confirmed from data alone.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `id` | nvarchar(50) | NO | PK | Primary key, string-typed (not identity) |
| `PatientMessageId` | nvarchar(50) | YES | → `rxqPatientMessageScriptTransactions` (unconfirmed, see below) | Named-implied FK to a patient-message entity; 0% data match against `rxqPatientMessageScriptTransactions` |
| `Data` | nvarchar(max) | YES | | Attachment payload (likely base64/text-encoded binary or document content) (inferred) |
| `DataType` | int | YES | | Coded attachment-type domain; sampled values: `1` (count 96 — only value observed) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):**
  - `PatientMessageId` → `rxqPatientMessageScriptTransactions` (join col `PatientMessageId`) — inferred from column naming, but **low** confidence: 0.0% referential match (96 non-null values, 96 orphans, not sampled). This is effectively an unconfirmed guess — the real parent table for `PatientMessageId` is not established by this data and may be a different/renamed patient-message table not captured here.
- **Inbound (inferred):** none.

**Indexes**

None reported (no indexes defined on this table beyond the implicit PK constraint, if any).

**Gotchas**

- `id` and `PatientMessageId` are both `nvarchar(50)` — string surrogate keys, not integer identities; typical of Liberty's GUID-like string PKs.
- The one inferred relationship (`PatientMessageId` → `rxqPatientMessageScriptTransactions`) has a **0% match rate** — do not treat this as a real join path without further investigation; the true parent entity is unresolved.
- `DataType` currently has only one observed value (`1`) across all 96 rows, so its other coded meanings (if any) are unknown from this sample — do not assume it's a boolean/single-valued column beyond what's observed.
- Not mirrored by ETL into liberty_link_stage, so this data is invisible to downstream eMed reporting/consumers.

---

## `rxqSMSMessage`

Rows: 50 (RXCS) | Columns: 9 | PK: `Id` | ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores individual SMS text messages tied to a patient, with direction (`IncomingOutgoing`), free-text body (`MessageText`), sender phone number/identifier (`Number`), a viewed/read flag, and a timestamp. `SentBy` (inferred) likely records the staff user or system process that sent an outgoing message. `MessageID` is a separate integer column indexed on its own (`IX_MessageID`), distinct from the PK `Id` — (inferred) possibly a correlation ID to an external SMS-gateway provider's message ID, since it does not reference any local table by naming. Row count (50) is small relative to typical pharmacy-communication volume, suggesting this table may be a recent feature, a low-adoption channel, or a rolling/purged log (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| Id | int | NOT NULL | PK | identity |
| PatientId | varchar(50) | NULL | → rxqPatient (inferred, unconfirmed — see Relationships) | |
| IncomingOutgoing | char(10) | NULL | | direction flag; no lookups sampled (values not present in coded-domain sample) |
| ViewedFlag | bit | NULL | | sampled values: `true` (50/50, i.e. 100% of sampled rows) |
| DateTimeCreated | datetime | NULL | | indexed (`IX_DateTimeCreated`) |
| MessageText | varchar(500) | NULL | | free-text SMS body |
| Number | varchar(50) | NULL | | phone number/identifier associated with the message |
| SentBy | varchar(50) | NULL | | likely staff/user or system sender identifier (inferred) |
| MessageID | int | NULL | | indexed separately (`IX_MessageID`); likely external gateway/provider correlation ID (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

These are all INFERRED from column naming and then DATA-VALIDATED against actual key values — not declared constraints.

- **Outbound (inferred):**
  - `PatientId` → `rxqPatient` — inferred, **low** confidence (0.0% referential match; 50/50 sampled values are orphans, not sampled further). Despite the naming match, none of the current non-null `PatientId` values resolve to `rxqPatient`'s key — treat this edge as unconfirmed/likely wrong as currently populated (e.g. `PatientId` may hold a different ID space, such as a family/account ID, consistent with the index name `IX_FamilyId` on this column).

- **Inbound (inferred):** none.

**Indexes**
- `IX_DateTimeCreated` (NONCLUSTERED, `DateTimeCreated`) — supports chronological/message-history queries.
- `IX_FamilyId` (NONCLUSTERED, `PatientId`) — note the index name references "FamilyId" rather than "PatientId", despite keying the `PatientId` column; suggests `PatientId` may actually store a family/account-level ID rather than a strict per-patient ID (see Gotchas).
- `IX_MessageID` (NONCLUSTERED, `MessageID`) — supports lookup by external/correlation message ID, separate from the internal PK.

**Gotchas**
- `IX_FamilyId` is built on the `PatientId` column — the index name and the column name disagree, and the data backs the index name: `PatientId` shows a 0% match rate against `rxqPatient`, meaning it is NOT reliably a patient-level foreign key despite its name. Treat `PatientId` in this table as likely a family/account identifier rather than an individual patient ID until proven otherwise.
- `MessageID` and `Id` are two different integer identifiers on this table (PK `Id` is an identity column; `MessageID` is a separately-indexed, nullable int) — do not conflate them when joining or deduplicating.
- Not ETL-mirrored to liberty_link_stage, so eMed-side reporting/joins cannot reference this table directly; any SMS-message data needed downstream would require a new ETL pull.
- Small sample size (50 rows) — lookup/enum values (e.g., `ViewedFlag` always `true`) and the 0% `PatientId` match rate may not generalize; re-validate before relying on these patterns at scale or across the mmed/mdvo tenants.

---

## `rxqFaxCenter`

Rows (RXCS): 1 | Columns: 13 | PK: `cFaxCenterId` | ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores a log/queue of faxes handled by the pharmacy system (send and/or receive), one row per fax event: a type code (`FaxType`), the counterparty number and recipient name (`FaxNumber`, `FaxRecipient`), send/create timestamps (`FaxSent`, `FaxCreated`), a read flag (`FaxRead`), a soft-delete flag (`Trash`), and a link to an imaged document via `ImageKeyType`/`ImageKey` (inferred). `WFISequenceNumber` suggests integration with a workflow/fax-interface sequencing mechanism (inferred). `StoreNumber` scopes the row to a pharmacy location/store. Only 1 row is present in this RXCS snapshot, so table usage/volume can't be characterized from data alone (point-in-time).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cFaxCenterId | int | NO | PK | identity |
| FaxType | int | YES | | no lookup values sampled (table has only 1 row) |
| FaxNumber | varchar(max) | YES | | fax number of sender/recipient (inferred) |
| FaxRecipient | varchar(max) | YES | | recipient name/label (inferred) |
| FaxSent | datetime | YES | | timestamp fax was sent (inferred) |
| WFISequenceNumber | int | YES | | likely workflow-interface sequence number (inferred) |
| ImageKeyType | varchar(1) | YES | → rxqImageControl | implicit ref to rxqImageControl.ImageKeyType; part of a composite image-lookup key with ImageKey (inferred) |
| ImageKey | varchar(200) | YES | | image document key, paired with ImageKeyType (inferred) |
| FaxCreated | datetime | YES | | timestamp fax record was created (inferred) |
| Trash | bit | YES | | soft-delete flag (inferred) |
| LastModified | datetime | YES | | audit timestamp |
| FaxRead | bit | YES | | read/unread flag (inferred) |
| StoreNumber | varchar(50) | NO | | pharmacy store/location scope (inferred) |

**Relationships**
Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**
  - `ImageKeyType` → `rxqImageControl` (join col `ImageKeyType`) — inferred, **high** confidence (100.0% referential match, not sampled). Based on only 1 non-null value in this snapshot, so the match is not statistically strong despite the high label.
- **Inbound (inferred)**
  - none

**Indexes**
- `IDX_rxqFaxCenter_faxType_FaxRead` (nonclustered, non-unique) on (`FaxType`, `FaxRead`) including `Trash` — supports queue-style lookups filtering by fax type and read/unread status (with trash filtering via the included column), consistent with a fax inbox/worklist access pattern.

**Gotchas**
- Table has only 1 row in this RXCS snapshot — all column semantics beyond names/types are inferred; no lookup enum values could be sampled (`FaxType` domain unknown).
- Not ETL-mirrored into liberty_link_stage, so this data isn't available to eMed via the standard mirror; any eMed feature needing fax history would need a new extract.
- `ImageKeyType`/`ImageKey` forms a composite pseudo-key into `rxqImageControl` with no declared constraint — standard Liberty pattern of implicit, unenforced cross-table references.

---

## `rxqImageControl`

Rows: 754,142 (RXCS) | Columns: 11 | PK: `ImageKeyType`, `ImageKey` | ETL-mirrored into liberty_link_stage: no

**Purpose**
Generic scanned-document/image registry: a polymorphic key (`ImageKeyType` + `ImageKey`) points at an owning record elsewhere in Liberty (e.g. a fax, an rx image, a patient document — inferred), with the physical file located via `Directory`/`FileName`, a `ScanDate`/`LastModified` audit trail, an `IsValid` flag, free-text `Annotations`, and an optional `DocumentCategory` classifier. It is a shared attachment store rather than a single-domain child table (inferred from the polymorphic composite key and lack of any single dominant referencing table).

**Columns**
| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cImageControlId | int | NO | | identity |
| ImageKeyType | char(1) | NO | PK | polymorphic type discriminant for the owning entity (referenced by `rxqFaxCenter.ImageKeyType`) |
| ImageKey | varchar(200) | NO | PK | polymorphic key value of the owning entity (varchar, not typed FK) |
| Description | varchar(200) | YES | | |
| ScanDate | datetime | YES | | |
| FileName | varchar(200) | YES | | |
| LastModified | datetime | YES | | |
| IsValid | bit | YES | | sampled values: `true` (754,142 / 754,142 — 100%, i.e. every sampled row is valid) |
| Directory | varchar(200) | YES | | |
| Annotations | varchar(max) | YES | | |
| DocumentCategory | nvarchar(30) | YES | | sampled values: `null` (754,142 / 754,142 — column is NULL in every sampled row; no populated domain observed) |

**Relationships**
Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none.
- **Inbound (inferred):**
  - `rxqFaxCenter.ImageKeyType` → this table's `ImageKeyType` — inferred, **high** confidence (100.0% referential match).
  - `rxqPrintableAttachment.cImageControlId` → this table's `cImageControlId` — inferred, **no-data** confidence (no match_rate computed; parent/child data insufficient to validate — treat as an unconfirmed guess).

**Indexes**
- `IX_cImageControl` (NONCLUSTERED, non-unique) on `ImageKeyType` — supports polymorphic-type lookups (e.g. by `rxqFaxCenter`).
- `IX_cImageControl_1` (NONCLUSTERED, non-unique) on `ImageKey` — supports direct key lookups independent of type.

**Gotchas**
- Composite PK is entirely varchar/char (`ImageKeyType` char(1), `ImageKey` varchar(200)) with no declared constraint tying it to any specific parent table — the polymorphic "key type" pattern means `ImageKey` values are only meaningful in the context of `ImageKeyType`, and joins must always filter on both columns together.
- `DocumentCategory` is present in the schema but null across all 754,142 sampled rows — likely an added-but-unused or not-yet-adopted classification field; do not assume it carries data.
- `IsValid` is true for every sampled row — no observed use of it as a soft-delete/invalidation flag in this sample; its false-path semantics are unconfirmed.
- Not mirrored by ETL into liberty_link_stage, so this table is invisible to downstream eMed reporting/joins that rely on the mirror.

---

## `rxqMessages`

Rows (RXCS): 1 | Columns: 12 | PK: `cMessageId` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores internal in-app messages/notes sent between pharmacy staff users (an internal messaging/notification mailbox, inferred). Columns support both individual addressing (`AddressedToInd`) and group addressing (`IsGrpMsg`, `AddressedToGrp`, `IsGrpReadAck`), plus a `Priority` flag and a per-message read receipt (`IsRead`). No columns carry patient, script, or order identifiers, so this table appears to be a staff-communication/workflow-notes feature rather than a clinical or fulfillment record (inferred). Table has only 1 row in RXCS at extract time, so patterns below are structural (from schema), not statistically derived from data.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cMessageId | int | NO | PK | identity |
| Subject | nvarchar(1024) | NO | | message subject line |
| MessageBody | nvarchar(1024) | NO | | message text |
| Priority | nvarchar(50) | NO | | coded priority level (no sampled values captured — table has only 1 row, lookups not populated) |
| AddressedFrom | varchar(50) | YES | | sender identifier (likely a staff username, inferred) |
| IsGrpMsg | bit | NO | | flag: message addressed to a group vs. an individual |
| AddressedToGrp | int | YES | | target group identifier, used when `IsGrpMsg` = true (inferred) |
| AddressedToInd | varchar(50) | YES | | target individual identifier, used when `IsGrpMsg` = false (inferred) |
| CreatedDateYYYYMMHH | datetime | NO | | message creation timestamp (column name suggests YYYYMMHH granularity but type is full `datetime`) |
| CreatedBy | varchar(50) | YES | | staff username/id that created the message (inferred) |
| IsRead | bit | NO | | read/unread flag |
| IsGrpReadAck | varchar(50) | NO | | group read-acknowledgment tracking (likely a delimited list of user IDs who acknowledged, inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no `implicit_ref` values populated and no inferred_relationships detected for this table.
- **Inbound (inferred):** none — no other table's inferred relationships point to `rxqMessages`.

Note: `AddressedFrom`, `AddressedToGrp`, `AddressedToInd`, and `CreatedBy` look like they'd reference a staff/user or group table, but no naming-based inference or data validation was recorded against this table (likely because the referenced user/group table wasn't part of this extract, or match confidence was too low/no-data to surface) — treat any such linkage as unconfirmed.

**Indexes**

None declared (indexes list is empty).

**Gotchas**

- Not ETL-mirrored into liberty_link_stage — this data is not available downstream in eMed.
- Only 1 row sampled in RXCS; lookups/coded-domain values for `Priority` and `IsGrpReadAck` are unknown from this extract.
- No FK constraints and no inferred relationships recorded at all — the addressing columns (`AddressedFrom`, `AddressedToGrp`, `AddressedToInd`, `CreatedBy`) are plausible references to a staff/user or group table but cannot be confirmed from this metadata.
- `CreatedDateYYYYMMHH` name suggests coarser granularity than the actual `datetime` type — likely a legacy/misleading column name, not a formatting constraint.

---

## `rxqInternalMessaging`

Rows (RXCS): 3 · Columns: 6 · PK: `cInternalMessagingId` · ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores internal (staff-to-staff) messages within the Liberty pharmacy system — a free-text `Message` body, a `FromUser` sender, an `AllUsers` field, and `MessageDate`/`LastModified` timestamps (inferred). It appears to be a lightweight internal-messaging/announcement mechanism rather than a patient-communication or NCPDP/SureScripts-related workflow, since no columns reference patients, prescriptions, or orders. The very low row count (3) suggests it is either lightly used, periodically purged, or a legacy/rarely-exercised feature (inferred). `FromUser` and `AllUsers` are untyped varchar fields rather than foreign keys to a users table, so sender/recipient identity is stored as free text, not a structured reference (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cInternalMessagingId | int | NO | PK | identity |
| Message | varchar(max) | YES | | message body text |
| FromUser | varchar(400) | YES | | free-text sender identifier, not a typed FK |
| AllUsers | varchar(max) | YES | | likely recipient list / broadcast flag (inferred) |
| MessageDate | datetime | YES | | message creation timestamp (inferred) |
| LastModified | datetime | YES | | last-update timestamp (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

**Indexes**
None defined.

**Gotchas**
- No inferred or declared relationships at all — `FromUser`/`AllUsers` are plain varchar fields with no `implicit_ref`, so there is no data-validated link to a users/staff table; any join to identify senders/recipients would need to be done by matching username strings manually.
- Not mirrored by ETL, so this table is invisible to liberty_link_stage/eMed reporting — it is purely an operational Liberty-side artifact.
- Extremely small row count (3) relative to typical operational tables — treat any conclusions about usage patterns as low-confidence given the sample size.

---

## `rxqInternalMessagingUserMessage`

Rows (RXCS): 5 | Columns: 5 | PK: `cInternalMessagingUserMessageId` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores per-user read-state/receipt records for an internal messaging system, linking a message (`InternalMessagingId`) to a recipient (`MessageUser`) with a read flag (`MessageRead`) and a last-modified timestamp (inferred — the naming pattern `InternalMessaging` + `UserMessage` and the read-flag column together suggest this is the recipient/read-receipt join table for a parent `InternalMessaging` (or similarly named) message table, not the message body itself). No columns are declared or inferred as foreign keys, and `InternalMessagingId` has no matching parent table found in this extract, so the link to the parent message record cannot be data-validated here (inferred). Only 5 rows exist in RXCS, suggesting this internal messaging feature is lightly used or mostly historical/test data (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cInternalMessagingUserMessageId | int | NO | PK | identity |
| InternalMessagingId | int | YES | | likely FK to a parent messaging table (not present/resolvable in this extract) |
| MessageUser | varchar(400) | YES | | recipient identifier (format not sampled — no lookup data available) |
| MessageRead | bit | YES | | read/unread flag; no sampled values available (table has only 5 rows, not in lookups) |
| LastModified | datetime | YES | | last update timestamp |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no inferred_relationships were detected/validated for this table (in particular, `InternalMessagingId` did not resolve to a parent table in this extract; treat any assumed link to a messaging-thread table as an unconfirmed guess).
- **Inbound (inferred):** none — no other table's columns were detected/validated as referencing this table.

**Indexes**

None captured (no indexes reported for this table beyond the implicit PK constraint).

**Gotchas**

- `InternalMessagingId` strongly implies a parent `rxqInternalMessaging` (or similar) table by naming convention, but it is absent from both declared and inferred relationships in this extract — likely because that parent table either wasn't captured in this metadata pull or has no data-validated match; don't assume the join without checking.
- Extremely low row count (5) means any statistics here are not representative — treat this table as effectively unsampled for behavioral patterns.
- Not mirrored by ETL, so this data is not available in liberty_link_stage for reporting/joins.

---

## `rxqInternalMessagingGroup`

Rows: 2 (RXCS) | Columns: 5 | PK: `cInternalMessagingGroupId` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores internal-messaging "group" definitions used by Liberty's staff messaging feature — each row represents one named/pinnable group with an associated set of member users. `GroupUser` and `AllUsers` (varchar(400) / varchar(max)) suggest one column holds a single/primary user identifier and the other a delimited list of all member users for the group (inferred — no FK/relationship data confirms the storage format or a link to a users table). `Pinned` lets a group be pinned (e.g., to the top of a messaging UI), and `LastModified` timestamps the last change. With only 2 rows, this is a small, low-cardinality configuration table rather than transactional data.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cInternalMessagingGroupId | int | NO | PK | identity |
| GroupUser | varchar(400) | YES | | no lookups sampled |
| AllUsers | varchar(max) | YES | | likely delimited list of member users (inferred); no lookups sampled |
| Pinned | bit | YES | | sampled values: `true` (1), `null` (1) |
| LastModified | datetime | YES | | no lookups sampled |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

No naming-based or data-validated relationships were inferred for this table in either direction — it appears isolated from the rest of the schema by these heuristics (though `GroupUser`/`AllUsers` may reference a users table in practice; not confirmed here).

**Indexes**

None reported.

**Gotchas**

- `AllUsers` is `varchar(max)` with no delimiter/format documented — likely a serialized/delimited list of user identifiers rather than a normalized relationship; treat any parsing as inferred until confirmed against a real value.
- Only 2 rows and no relationships/indexes — table is effectively unvalidated by data; conclusions above are structural inference only.

---
