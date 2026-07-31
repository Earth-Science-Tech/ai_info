# Liberty schema — Clinical Safety & Care

Clinical safety and care management — allergies, drug-interaction/DUR alerts and Rx-alert settings, patient disease and ICD-9/ICD-10 coding, immunization records, eCare/MTM care plans, and lab results.

> Part of the [Liberty/RxQ schema reference](../README.md). Liberty declares **no foreign-key constraints** (verified via `sys.foreign_keys`), so all relationships shown are **inferred from column naming and then data-validated** by referential match rate — each is tagged high / medium / low / no-data / unvalidated confidence. Row counts and sampled enum values are from the RXCS instance (point-in-time); the schema itself is identical across the rxcs / mmed / mdvo tenants.

**Tables in this module (16):** [`rxqPatientAllergies`](#rxqpatientallergies) · [`rxqClinicalInteractionsAndAlerts`](#rxqclinicalinteractionsandalerts) · [`rxqClinicalInteractionsAndAlertsNotes`](#rxqclinicalinteractionsandalertsnotes) · [`rxqRxAlert`](#rxqrxalert) · [`rxqRxAlertSettings`](#rxqrxalertsettings) · [`rxqRxAlertCustomSettings`](#rxqrxalertcustomsettings) · [`rxqPatientDisease`](#rxqpatientdisease) · [`rxqIcd9`](#rxqicd9) · [`rxqIcd10`](#rxqicd10) · [`rxqImmunizationInfo`](#rxqimmunizationinfo) · [`rxqEcarePlan`](#rxqecareplan) · [`rxqEcareTemplate`](#rxqecaretemplate) · [`rxqEcareCode`](#rxqecarecode) · [`RxqLabPatientRecord`](#rxqlabpatientrecord) · [`RxqLabType`](#rxqlabtype) · [`RxqLabCategories`](#rxqlabcategories)

---

## `rxqPatientAllergies`

Rows (RXCS): 142,771 | Columns: 9 | PK: `PatientId`, `Allergy`, `SystemType`, `AllergyType` | ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores the patient allergy list used by the pharmacy system — one row per (patient, allergy, system, allergy-type) combination, each carrying free-text notes (`AllergyNotes`), a display name (`AllergyName`), a source drug reference (`SourceDrugId`), and add/modify timestamps. (Inferred) This is the clinical allergy record checked during order/prescription entry for drug-allergy interaction screening, analogous to an NCPDP allergy segment. The composite PK (rather than a single surrogate `AllergyId`) implies allergies are keyed by the allergy identifier itself per patient/system/type, so a patient cannot have two rows for the identical allergy+system+type combination but can have parallel entries for the same allergy string under different `SystemType`/`AllergyType` classifications.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| PatientId | varchar(50) | NO | PK, → `rxqPatient` | part of composite PK |
| Allergy | varchar(50) | NO | PK | likely a coded/short allergy identifier (e.g. drug code or allergen code); part of composite PK |
| AllergyNotes | varchar(1250) | YES | | free-text clinical note |
| AllergyDateAdded | datetime | YES | | |
| LastModified | datetime | YES | | |
| SystemType | int | NO | PK | coded domain (sampled): `1` (141,755 rows), `0` (1,016 rows) — meaning of 0/1 not documented in metadata; part of composite PK |
| SourceDrugId | varchar(200) | YES | | likely references a drug/NDC identifier that originated the allergy entry (inferred); no validated FK target |
| AllergyName | varchar(200) | YES | | human-readable allergy/allergen name, distinct from the coded `Allergy` PK column |
| AllergyType | int | NO | PK | coded domain (sampled): `1` (139,563 rows), `0` (3,208 rows) — meaning of 0/1 not documented in metadata; part of composite PK |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

These edges are inferred from column naming and DATA-VALIDATED against actual parent-table values (not enforced constraints) — treat low/no-data/unvalidated confidence as weak, unconfirmed guesses.

- **Outbound (inferred):**
  - `PatientId` → `rxqPatient` — inferred, **high** confidence (99.98% referential match; 28 orphans out of 142,779 non-null values; not sampled — full check).
- **Inbound (inferred):** none.

**Indexes**
None recorded (empty index list in the extract).

**Gotchas**
- Composite 4-column varchar/int primary key (`PatientId`, `Allergy`, `SystemType`, `AllergyType`) — no surrogate key, so joins/lookups must match all four columns.
- `Allergy` (coded) vs `AllergyName` (display text) are separate columns — don't conflate them when reading/reporting allergy data.
- `SourceDrugId` looks like a drug reference by naming convention but has no validated inferred relationship (no candidate parent table matched in this extract) — treat any drug-table join as unverified.
- `SystemType` and `AllergyType` are undocumented binary-ish integer codes (0/1) with no lookup/reference table found; meaning must be confirmed against Liberty application code or vendor docs before relying on it.
- Not ETL-mirrored into liberty_link_stage — this data is not available to eMed via the standard mirror and would require a dedicated pull if needed downstream.
- 28 `PatientId` orphans (~0.02%) exist relative to `rxqPatient` — small but nonzero data-quality gap.

---

## `rxqClinicalInteractionsAndAlerts`

Rows (RXCS): 39,787 | Columns: 14 | PK: `cClinicalInteractionsAndAlertsId` | ETL-mirrored into liberty_link_stage: no

**Purpose** — Stores per-fill clinical decision-support alerts (drug interactions, DUR/utilization-review style warnings) generated during prescription processing and the pharmacist's disposition of them, keyed to a `ScriptNumber`/`RefillNumber` pair (inferred, NCPDP-style DUR alerting). `Significance`, `Type`, and `AlertLocation` are coded severity/category/origin flags, `RPhInitials`/`LoggedInUser` capture who reviewed/acknowledged the alert, and `Subject`/`Description` hold the human-readable alert text (inferred). `PrescriptionProcessingMode` (0/1/2/99) likely distinguishes the workflow context the alert fired in (e.g. new fill vs. refill vs. batch/override) (inferred — no lookup label data available to confirm). `ClinicalNoteId` (varchar(200)) suggests a link to a clinical-notes subsystem, but no matching ref table was inferred so its target is unknown.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cClinicalInteractionsAndAlertsId | int | NO | PK | identity |
| ScriptNumber | int | YES | → `rxqScriptBase` | inferred FK, 99.42% match |
| RefillNumber | int | YES | | no implicit_ref detected; likely composite with ScriptNumber to identify the specific fill (inferred) |
| Type | int | YES | | coded: 1=28393, 3=8371, 9=2571, 0=437, 2=14, 4=1 |
| Subject | varchar(400) | YES | | free text, alert title (inferred) |
| Description | varchar(max) | YES | | free text, alert detail (inferred) |
| Significance | int | YES | | coded severity, no lookup values sampled |
| RPhInitials | varchar(50) | YES | | reviewing pharmacist initials (inferred) |
| LoggedInUser | varchar(50) | YES | | user who logged/triggered the alert (inferred) |
| AlertDate | datetime | YES | | when alert fired |
| LastModified | datetime | YES | | last update timestamp |
| ClinicalNoteId | varchar(200) | YES | | varchar identifier, possible link to a clinical-notes table; no ref inferred |
| PrescriptionProcessingMode | int | YES | | coded: 0=32810, 2=4266, 1=2633, 99=78 |
| AlertLocation | int | YES | | coded: 0=39709, 1=78 |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**:
  - `ScriptNumber` → `rxqScriptBase` — inferred, **high** confidence (99.42% referential match, 230 orphans out of 39,787 non-null values; not sampled — full check).
- **Inbound (inferred)**: none.

These edges are inferred purely from column naming and then data-validated against actual parent-table values — they are not enforced database constraints, so orphaned/edge-case rows (230 here) are possible and expected.

**Indexes** — none reported (indexes list empty in metadata; no declared index structures surfaced for this table).

**Gotchas**
- Not ETL-mirrored into liberty_link_stage — this alert history is only queryable directly against the Liberty/RxQ database, not via the eMed mirror.
- `RefillNumber` has no inferred relationship despite the obvious pairing with `ScriptNumber`/`rxqScriptBase` fills — treat any RefillNumber-based join as unverified.
- `ClinicalNoteId` is a varchar(200) identifier with no inferred reference target; do not assume it joins cleanly to any note table without independent verification.
- `Significance`, `Type`, and `PrescriptionProcessingMode` are opaque integer codes; only `Type`, `PrescriptionProcessingMode`, and `AlertLocation` have sampled value distributions here — `Significance` has none, so its domain is unknown from this extract.
- 230 `ScriptNumber` values (0.58%) don't resolve to `rxqScriptBase` — small but non-zero orphan rate to account for in joins/reporting.

---

## `rxqClinicalInteractionsAndAlertsNotes`

Rows (RXCS): 34,626 | Columns: 9 | PK: `cClinicalInteractionsAndAlertsNoteId` | ETL-mirrored into liberty_link_stage: no

**Purpose** — Stores pharmacist free-text notes logged against a specific prescription (`ScriptNumber`) and, where applicable, a specific `RefillNumber`, timestamped (`NotesDate`, `LastModified`) and attributed to a pharmacist (`RPhInitials`) and system user (`LoggedInUser`). The table name and `ClinicalNoteId` column suggest these notes document clinical decision-making around drug-interaction/DUR alerts encountered during order verification (inferred) — i.e. the pharmacist's rationale for overriding or acting on a clinical alert — but no lookup/coded columns exist to confirm alert type, severity, or override reason; the content is entirely unstructured (`ClinicalNote` is `varchar(max)`).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cClinicalInteractionsAndAlertsNoteId | int | NO | PK | identity |
| ScriptNumber | int | YES | → rxqScriptBase | links note to a prescription |
| RefillNumber | int | YES | | which refill of the script the note applies to; no lookup data sampled |
| ClinicalNoteId | varchar(200) | YES | | likely an external/categorical note-type identifier (inferred); no lookup data sampled |
| NotesDate | datetime | YES | | date the clinical note was created |
| ClinicalNote | varchar(max) | YES | | free-text note body |
| LastModified | datetime | YES | | last edit timestamp |
| RPhInitials | varchar(50) | YES | | pharmacist initials (attribution) |
| LoggedInUser | varchar(50) | YES | | system user account that logged the note |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**
  - `ScriptNumber` → `rxqScriptBase` — inferred, **high** confidence (99.4% referential match, 34,626 non-null values checked, 197 orphans; not sampled — full check).
- **Inbound (inferred)**
  - none.

**Indexes** — none declared/observed (empty index list).

**Gotchas**
- No secondary indexes exist on `ScriptNumber` (or anything else) — lookups joining notes to a script likely require a full scan; consider this before using the table in any interactive query path.
- `RefillNumber` has no inferred relationship recorded (likely because there's no single natural parent key combining ScriptNumber+RefillNumber in this metadata pass) — treat script+refill as a composite logical key even though it isn't validated as one.
- `ClinicalNoteId` (varchar(200)) is a different column from the PK `cClinicalInteractionsAndAlertsNoteId` (int) — easy to confuse; its purpose/domain is unconfirmed since no lookup values were sampled and it has no inferred FK.
- 197 `ScriptNumber` values (0.57%) don't resolve to `rxqScriptBase` — likely deleted/purged scripts or historical data drift; don't assume 100% join coverage.
- Not ETL-mirrored into liberty_link_stage, so this data is only queryable directly against the Liberty/RxQ source, not via eMed's mirrored views.

---

## `rxqRxAlert`

Rows (RXCS): 164,804 | Columns: 12 | PK: `id` | ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores queued/sent alert records tied to a script fill (`ScriptNumber`/`RefillNumber`), a patient (`PatientId`), and optionally an appointment (`AppointmentId`/`AppointmentAlertSettingId`), with a coded `AlertType`, a send gate (`SendAfter`) and a dispatch flag (`Sent`). This looks like a notification/reminder queue driving patient- or appointment-related alerts (e.g. refill-due or appointment reminders) that a background process evaluates and marks `Sent` once dispatched (inferred). The dominant `AlertType` value (5, 99.8% of rows) suggests one alert type accounts for nearly all traffic, with a much rarer type 12 (inferred meaning of the codes themselves is not derivable from metadata alone).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| id | nvarchar(50) | NO | PK | |
| ScriptNumber | int | YES | → rxqScriptBase | |
| RefillNumber | int | YES | | pairs with ScriptNumber to identify a specific fill |
| AlertType | int | YES | | coded domain sampled: `5` (164,525 rows), `12` (279 rows) |
| PatientId | nvarchar(50) | YES | → rxqPatient | |
| CreatedOn | datetime | YES | | |
| Sent | bit | YES | | dispatch flag |
| SendAfter | datetime | YES | | gate/schedule time for sending |
| StoreNumber | varchar(3) | YES | | |
| AppointmentId | int | YES | | no validated inferred_relationship (target table not detected/joined) |
| AppointmentAlertSettingId | int | YES | | no validated inferred_relationship (target table not detected/joined) |
| LastModified | datetime | YES | | |

**Relationships**
Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- Outbound (inferred):
  - `PatientId` → `rxqPatient` — inferred, **high** confidence (99.99% referential match, 21 orphans out of 164,806 non-null).
  - `ScriptNumber` → `rxqScriptBase` — inferred, **high** confidence (99.81% referential match, 310 orphans out of 164,806 non-null).
- Inbound (inferred): none.

These edges are inferred from column naming plus data validation against actual parent-table values — they are not enforced/declared constraints, and the small orphan counts indicate a few dangling references (deleted patients/scripts or stale rows) rather than data-integrity guarantees.

**Indexes**
- `IDX_rxqRxAlert_alertType_Sent_store` (AlertType, Sent, StoreNumber) with wide INCLUDE list — supports the primary queue-scan pattern: find unsent alerts of a given type per store.
- `PatientIdIndex` (PatientId) — patient-scoped alert lookup.
- `ScriptFillIndex` (ScriptNumber, RefillNumber) — fill-scoped alert lookup, aligns with the outbound ScriptNumber relationship.
- `SentDateFlagIndex` (Sent, SendAfter) — supports scheduled-dispatch polling (find alerts due to send).

**Gotchas**
- PK `id` and FK-like `PatientId`/appointment ids mix nvarchar surrogate keys with int business keys — no declared constraints anywhere, so referential integrity relies entirely on app logic (consistent with the small orphan rates seen above).
- `AppointmentId` / `AppointmentAlertSettingId` have no inferred_relationships entry (no ref_table detected), so their target table is unconfirmed from this metadata alone — treat any appointment-table linkage as unverified.
- `AlertType` lookup only shows 2 distinct sampled values (5, 12); do not assume these are the full enum domain, only what was observed in this sample.

---

## `rxqRxAlertSettings`

Rows (RXCS): 1 | Columns: 103 | PK: `Id` | ETL-mirrored into liberty_link_stage: no

**Purpose** — Singleton (1-row, per-tenant) configuration table for the pharmacy's outbound patient-alert/notification system, covering channel toggles (text/email/voice), per-event message templates (subject/body per channel), timing rules, weekly send-schedule windows, and third-party messaging-provider credentials. Columns cover four alert types — Refill Reminder, Prescription Ready, On-Shelf Reminder, Birthday, New Patient, Shipping, and Med Sync — each with its own enable flag plus TextMessage/EmailSubject/EmailMessage/VoiceMessage template fields (inferred: templates support merge-field style patient/rx personalization, consistent with NCPDP-adjacent patient-communication workflows). Embeds live outbound-integration secrets: SMTP mail-server credentials (`MailServerUsername`/`MailServerPassword`), Twilio-style voice API creds (`VoiceAccountSid`/`VoiceAuthToken`/`MessagingServiceSid`), video-conference API creds, and machine-detection tuning for the voice channel — implying voice alerts are placed via a telephony API (e.g., Twilio) with answering-machine detection (inferred). A weekly per-day send-window schedule (`Schedule{Day}Send`/`Start`/`End` for Sun–Sat) throttles when reminders may go out. `StoreNumber` (varchar(3)) suggests this settings row can be scoped per store/location, though this tenant only has 1 row so multi-store use is unconfirmed (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| Id | int | NO | PK | identity |
| StoreNumber | varchar(3) | YES | | possible per-location scope key |
| TextMessaging | bit | YES | | master text-channel enable |
| EmailMessaging | bit | YES | | master email-channel enable |
| VoiceMessaging | bit | YES | | master voice-channel enable |
| RefillReminder | bit | YES | | enable flag |
| RefillReminderEmailSubject | nvarchar(max) | YES | | template |
| RefillReminderEmailMessage | nvarchar(max) | YES | | template |
| RefillReminderTextMessage | nvarchar(max) | YES | | template |
| RefillReminderVoiceMessage | nvarchar(max) | YES | | template |
| RefillReminderExcludeMedSync | bit | YES | | exclusion flag |
| RefillReminderExcludeAutoRefill | bit | YES | | exclusion flag |
| RefillReminderExcludeImmunizations | bit | YES | | exclusion flag |
| RefillReminderExcludeSchedule | bit | YES | | exclusion flag (vs. day/time send window) |
| DaysBeforeRefillDueBeforeSending | float | YES | | timing param |
| RefillDueLastChecked | datetime | YES | | job watermark |
| CooldownDays | float | YES | | anti-repeat throttle |
| PrescriptionReady | bit | YES | | enable flag |
| PrescriptionReadyEmailSubject | nvarchar(max) | YES | | template |
| PrescriptionReadyEmailMessage | nvarchar(max) | YES | | template |
| PrescriptionReadyTextMessage | nvarchar(max) | YES | | template |
| PrescriptionReadyVoiceMessage | nvarchar(max) | YES | | template |
| PrescriptionReadyWaitForAllVerified | bit | YES | | gating flag (multi-item order) |
| PrescriptionReadyExcludeMedSync | bit | YES | | exclusion flag |
| PrescriptionReadyExcludeImmunizations | bit | YES | | exclusion flag |
| MinutesAfterRxReadyBeforeSending | float | YES | | timing param |
| RxReadyWhen | int | YES | | coded timing/trigger selector (no sample data) |
| OnShelfReminder | bit | YES | | enable flag |
| OnShelfReminderTextMessage | nvarchar(max) | YES | | template |
| OnShelfReminderEmailMessage | nvarchar(max) | YES | | template |
| OnShelfReminderEmailSubject | nvarchar(max) | YES | | template |
| OnShelfReminderVoiceMessage | nvarchar(max) | YES | | template |
| OnShelfReminderExcludeImmunizations | bit | YES | | exclusion flag |
| OnShelfReminderSendXTimes | int | YES | | repeat-count param |
| OnShelfReminderWaitXDaysBetween | int | YES | | repeat-spacing param |
| DaysAfterOnShelfBeforeSending | float | YES | | timing param |
| OnShelfWhen | int | YES | | coded timing/trigger selector (no sample data) |
| Birthday | bit | YES | | enable flag |
| BirthdayTextMessage | nvarchar(max) | YES | | template |
| BirthdayEmailSubject | nvarchar(max) | YES | | template |
| BirthdayEmailMessage | nvarchar(max) | YES | | template |
| BirthdayVoiceMessage | nvarchar(max) | YES | | template |
| NewPatient | bit | YES | | enable flag |
| NewPatientTextMessage | nvarchar(max) | YES | | template |
| NewPatientEmailSubject | nvarchar(max) | YES | | template |
| NewPatientEmailMessage | nvarchar(max) | YES | | template |
| NewPatientVoiceMessage | nvarchar(max) | YES | | template |
| NewPatientDaysBefore | float | YES | | timing param |
| ShippingReminder | bit | YES | | enable flag |
| ShippingTextMessage | varchar(max) | YES | | template |
| ShippingEmailMessage | varchar(max) | YES | | template |
| ShippingEmailSubject | varchar(max) | YES | | template |
| ShippingVoiceMessage | varchar(max) | YES | | template |
| MedSyncEnabled | bit | YES | | enable flag |
| MedSyncTextMessage | nvarchar(max) | YES | | template |
| MedSyncEmailSubject | nvarchar(max) | YES | | template |
| MedSyncEmailMessage | nvarchar(max) | YES | | template |
| MedSyncVoiceMessage | nvarchar(max) | YES | | template |
| MedSyncReminderDays | int | YES | | timing param |
| TextEnrollmentAlert | bit | YES | | enable flag (text opt-in alert) |
| EmailTemplate | nvarchar(max) | YES | | generic/shared template field |
| ScheduleSunSend | bit | YES | | sampled: `false` (1) |
| ScheduleSunSendStart | nvarchar(50) | YES | | window start (string-formatted time) |
| ScheduleSunSendEnd | nvarchar(50) | YES | | window end |
| ScheduleMonSend | bit | YES | | sampled: `true` (1) |
| ScheduleMonSendStart | nvarchar(50) | YES | | window start |
| ScheduleMonSendEnd | nvarchar(50) | YES | | window end |
| ScheduleTueSend | bit | YES | | sampled: `true` (1) |
| ScheduleTueSendStart | nvarchar(50) | YES | | window start |
| ScheduleTueSendEnd | nvarchar(50) | YES | | window end |
| ScheduleWedSend | bit | YES | | sampled: `true` (1) |
| ScheduleWedSendStart | nvarchar(50) | YES | | window start |
| ScheduleWedSendEnd | nvarchar(50) | YES | | window end |
| ScheduleThurSend | bit | YES | | sampled: `true` (1) |
| ScheduleThurSendStart | nvarchar(50) | YES | | window start |
| ScheduleThurSendEnd | nvarchar(50) | YES | | window end |
| ScheduleFriSend | bit | YES | | sampled: `true` (1) |
| ScheduleFriSendStart | nvarchar(50) | YES | | window start |
| ScheduleFriSendEnd | nvarchar(50) | YES | | window end |
| ScheduleSatSend | bit | YES | | sampled: `false` (1) |
| ScheduleSatSendStart | nvarchar(50) | YES | | window start |
| ScheduleSatSendEnd | nvarchar(50) | YES | | window end |
| LookBackDays | int | YES | | job lookback window param |
| MailServerName | nvarchar(max) | YES | | SMTP host |
| MailServerSSLEnabled | bit | YES | | SMTP config |
| MailServerUsername | nvarchar(max) | YES | | SMTP credential |
| MailServerPassword | nvarchar(max) | YES | | SMTP credential (plaintext column, no hashing indicated) |
| MailServerPortNumber | int | YES | | SMTP config |
| MailServerFrom | nvarchar(max) | YES | | From address |
| VoiceAccountSid | nvarchar(50) | YES | | telephony API credential (Twilio-style SID) |
| VoiceAuthToken | nvarchar(50) | YES | | telephony API credential |
| VoicePhoneNumberFrom | nvarchar(50) | YES | | outbound caller ID |
| MessagingServiceSid | nvarchar(50) | YES | | telephony/messaging service ID |
| MessagingAccountPhoneNumber | varchar(max) | YES | | outbound SMS number |
| UseSmartSolutionsIVRForVoice | bit | YES | | third-party IVR routing flag |
| UseSmartSolutionsIVRForText | bit | YES | | third-party IVR routing flag |
| MachineDetection | bit | YES | | voice-call answering-machine detection toggle |
| MachineDetectionSilenceTimeout | int | YES | | voice AMD tuning param |
| MachineDetectionSpeechEndThreshold | int | YES | | voice AMD tuning param |
| MachineDetectionSpeechThreshold | int | YES | | voice AMD tuning param |
| MachineDetectionTimeout | int | YES | | voice AMD tuning param |
| VideoConferenceApiSid | varchar(max) | YES | | video-conference API credential |
| VideoConferenceApiSecret | varchar(max) | YES | | video-conference API credential |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no `implicit_ref` naming matches detected; `StoreNumber` reads as a plausible link to a store/location table but no inference/validation was recorded for it (unvalidated/no data).
- **Inbound (inferred):** none.

**Indexes** — none reported.

**Gotchas**
- Only 1 row in this tenant — this is effectively a global/singleton settings row, not a per-entity table; `StoreNumber` hints at intended multi-store scoping that isn't exercised here.
- Stores live third-party secrets in plaintext columns (SMTP password, Twilio auth token, video-conference API secret) directly in application data — sensitive from a security/compliance standpoint, not just PHI.
- Several coded `int` fields (`RxReadyWhen`, `OnShelfWhen`) have no sampled values/lookup domain — their enum meaning is undocumented in this extract.
- Not ETL-mirrored into liberty_link_stage, so eMed-side code cannot read/join this configuration; any alert-timing behavior must be inferred from pharmacy-side Liberty UI, not from the eMed warehouse.

---

## `rxqRxAlertCustomSettings`

Rows: 10 (RXCS) · Columns: 10 · PK: `CustomAlertTemplateId` · ETL-mirrored into liberty_link_stage: no

**Purpose** — Stores custom alert-template definitions used by Liberty's Rx alerting/workflow-notification engine: each row is a named template (`CustomAlertTemplateId`) with a description, an activation flag (`CustomAlertActivated`), per-channel message bodies (`CustomAlertEmailSubject`/`CustomAlertEmailMessage`, `CustomAlertTextMessage`, `CustomAlertVoiceMessage`), a time-span value (`CustomAlertTimeSpanValue`), a workflow action code (`CustomAlertWorkflowAction`), and a `StoreNumber` scoping the template to a pharmacy location. (inferred) This looks like a configuration/template table (not a transactional alert-instance log) — it defines what an alert says and how it fires across email/SMS/voice channels, likely triggered elsewhere by workflow events tied to `CustomAlertTimeSpanValue`/`CustomAlertWorkflowAction`. No sample lookup values were captured, so the exact domain of `CustomAlertWorkflowAction` and the unit of `CustomAlertTimeSpanValue` (seconds/minutes/hours) cannot be confirmed from metadata alone.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| CustomAlertTemplateId | nvarchar(50) | NO | PK | Varchar/string primary key (not identity) |
| CustomAlertDescription | nvarchar(max) | YES | | Free-text label/description of the template |
| CustomAlertActivated | bit | YES | | Boolean on/off flag; no sampled values captured |
| CustomAlertEmailMessage | nvarchar(max) | YES | | Email body template |
| CustomAlertEmailSubject | nvarchar(max) | YES | | Email subject template |
| CustomAlertTextMessage | nvarchar(max) | YES | | SMS/text body template |
| CustomAlertVoiceMessage | nvarchar(max) | YES | | Voice/IVR message template (likely TTS script) |
| CustomAlertTimeSpanValue | bigint | YES | | Numeric time-span parameter (unit not documented in metadata) |
| CustomAlertWorkflowAction | nvarchar(50) | YES | | Coded workflow-action identifier; no sampled values captured |
| StoreNumber | varchar(3) | YES | | Store/location scope code; likely a store-number identifier but no parent table inferred |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no inferred_relationships were detected for this table (no naming/data match found, including for `StoreNumber`).
- **Inbound (inferred):** none — no other table was found referencing this table's columns.

**Indexes** — none reported (no indexes beyond the implicit PK constraint).

**Gotchas**
- Primary key is a string (`nvarchar(50)`), not an identity/int — likely a business/generated code rather than a surrogate key.
- No FK or inferred-relationship evidence ties `StoreNumber` to a stores/locations table despite the naming; treat any such join as unconfirmed.
- All message-body columns are `nvarchar(max)` — may contain templating placeholders/merge fields, but no sample content was captured to verify.
- Only 10 rows total — this is almost certainly a small, hand-maintained configuration table rather than transactional data.

---

## `rxqPatientDisease`

Rows (RXCS): 2,403 | Columns: 11 | PK: `PatientId`, `CodeType`, `ICD9_CM_CODE` | ETL-mirrored into liberty_link_stage: no

**Purpose** — Stores diagnosis codes associated with a patient, one row per (patient, code type, code) (inferred from the composite PK). The column name `ICD9_CM_CODE` is legacy naming, but the actual sampled `CodeType` domain in this instance is exclusively `"ICD10"` — i.e. the field holds ICD-10-CM codes despite the ICD-9-era column name (inferred). `DiseaseDescription` carries a free-text label alongside the code, and `DiseaseCode` appears intended as a numeric FK to a disease lookup table (`rxqDisease`), though in this sampled data it is always `0` and that parent table is empty, so the link is currently inert. `IsValid`/`Inactive`/`Source`/`DateAdded`/`LastModified` support standard record lifecycle/audit tracking of a patient's diagnosis list (inferred) — plausibly used for SureScripts/NCPDP diagnosis-code transmission on prescriptions (inferred, not confirmed by any column here).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cPatientDiseaseId | int | NO | | identity |
| PatientId | varchar(50) | NO | PK, → rxqPatient | |
| ICD9_CM_CODE | varchar(50) | NO | PK | despite the name, all sampled CodeType values are ICD10 |
| DiseaseCode | int | YES | → rxqDisease | lookup values: `0` (2403) — always 0 in this sample |
| DiseaseDescription | varchar(500) | YES | | free-text diagnosis label |
| LastModified | datetime | YES | | |
| IsValid | bit | YES | | lookup values: `true` (2403) |
| CodeType | varchar(5) | NO | PK | lookup values: `"ICD10"` (2403) |
| DateAdded | date | YES | | |
| Source | int | YES | | lookup values: `1` (2399), `null` (4) |
| Inactive | bit | YES | | lookup values: `false` (2399), `null` (4) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**:
  - `PatientId` → `rxqPatient` — inferred, **high** confidence (96.0% referential match; 96 orphaned values out of 2,403 non-null).
  - `DiseaseCode` → `rxqDisease` — inferred, **unvalidated** (parent table `rxqDisease` is empty; cannot validate; sampled value is always `0`, suggesting the link is not actively populated).
- **Inbound (inferred)**: none.

**Indexes** — none declared (empty index list in metadata).

**Gotchas**
- Composite varchar PK (`PatientId`, `CodeType`, `ICD9_CM_CODE`) rather than a surrogate key, despite an unused identity column (`cPatientDiseaseId`) also being present — the identity column is not the PK.
- Column name `ICD9_CM_CODE` is misleading: the only observed `CodeType` in this tenant is `"ICD10"`, so the column stores ICD-10 codes under an ICD-9-named field.
- `DiseaseCode` FK-like column to `rxqDisease` is effectively dead in this sample (always `0`, and the parent lookup table is empty) — do not treat it as a reliable join path.
- Not mirrored by ETL into liberty_link_stage, so this data is not currently available downstream in eMed without a direct Liberty-side query.

---

## `rxqIcd9`

Rows (RXCS): 15,338 | Columns: 8 | PK: `Icd9Prefix`, `Icd9Code` (composite) | ETL-mirrored into `liberty_link_stage`: no

**Purpose**

Reference/lookup table of ICD-9 diagnosis codes, keyed by a composite `Icd9Prefix` + `Icd9Code` (not the identity column `cIcd9Id`), with a human-readable `DiseaseDescription`, a coded `ActivityCode`, and change-tracking columns (`LastChangeDateYYYYMMDD`, `LastModified`, `IsValid`). It is a static clinical code master used to attach/validate diagnosis codes on scripts (inferred, given `rxqScriptTransaction.Icd9Code` and `rxqIcd9CrossReference` reference it by name) rather than a transactional table itself. `IsValid` is true for all 15,338 sampled rows, consistent with a maintained active-codes reference list.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cIcd9Id | int | NOT NULL | | identity; surrogate row id, not part of the logical key |
| Icd9Prefix | varchar(50) | NOT NULL | PK | composite PK part 1 |
| Icd9Code | varchar(50) | NOT NULL | PK | composite PK part 2; referenced (weakly) from `rxqScriptTransaction.Icd9Code` |
| DiseaseDescription | varchar(50) | NULL | | diagnosis description text |
| ActivityCode | varchar(50) | NULL | | coded field; no sampled values available (not in lookups) |
| LastChangeDateYYYYMMDD | varchar(50) | NULL | | date stored as string, format YYYYMMDD |
| LastModified | datetime | NULL | | audit timestamp |
| IsValid | bit | NULL | | sampled domain: `true` (15,338/15,338 rows) — no `false` values observed in sample |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none.
- **Inbound (inferred):** these are column-name-based guesses, data-validated against actual values — not declared constraints:
  - `rxqIcd9CrossReference.Icd9Prefix` → `rxqIcd9` — inferred, **no-data** confidence (referential match could not be checked, no comparable data).
  - `rxqIcd9CrossReference.Icd9Code` → `rxqIcd9` — inferred, **no-data** confidence (referential match could not be checked, no comparable data).
  - `rxqScriptTransaction.Icd9Code` → `rxqIcd9` — inferred, **low** confidence (0.0% referential match) — treat as an unconfirmed/likely-false lead; values in `rxqScriptTransaction.Icd9Code` do not actually match `rxqIcd9` keys in the sample.

**Indexes**

None reported (no indexes returned beyond the composite PK constraint).

**Gotchas**

- Composite varchar PK (`Icd9Prefix` + `Icd9Code`) rather than the identity `cIcd9Id` — joins from other tables must use both parts, not the surrogate id.
- The one plausible consumer edge (`rxqScriptTransaction.Icd9Code`) has a 0% match rate in sampled data — despite the naming match, this is not a reliable join path as-is (possible format mismatch, e.g. code-only vs prefix+code, or ICD-10 migration leaving stale/unmatched codes).
- `ActivityCode` has no sampled lookup values, so its coded domain is unknown from this metadata.

---

## `rxqIcd10`

Rows (RXCS): 74,720 | Columns: 4 | PK: `Icd10Code` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Reference/lookup table of ICD-10 diagnosis codes and their descriptions (inferred: standard ICD-10-CM code set, given the code+description shape and ~74.7k row count consistent with a full ICD-10-CM code list). `IsValid` flags whether a code is currently active/usable, and in the sampled data every one of the 74,720 rows has `IsValid = true` (no inactive/retired codes currently in the table). `LastModified` tracks when each code row was last updated, suggesting this table is refreshed from an external ICD-10 code-set update feed (inferred) rather than being edited row-by-row by pharmacy staff. No inferred or declared relationships were found linking this table to other Liberty tables (e.g. patient diagnosis/visit records), so its consumption path (which table stores a patient's diagnosis code referencing this one) could not be confirmed from this metadata (inferred: likely referenced by free-text/varchar diagnosis-code columns elsewhere that don't match this table's naming pattern for inference).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `Icd10Code` | nvarchar(50) | NOT NULL | PK | The ICD-10 diagnosis code value |
| `Description` | nvarchar(max) | NOT NULL | | Free-text description of the diagnosis code |
| `LastModified` | datetime | NOT NULL | | Timestamp of last update to the row |
| `IsValid` | bit | NOT NULL | | Sampled values: `true` — count 74,720 (100% of rows; no `false` rows observed) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

No naming-based inferred relationships were detected in either direction for this table — treat it as a standalone code-reference table for this extract; any real linkage to visit/patient diagnosis fields is unconfirmed.

**Indexes**

- `_dta_index_rxqIcd10_195_587149137__K1_2` (NONCLUSTERED, non-unique) — key: `Icd10Code`, included: `Description`. Auto-generated (Database Tuning Advisor) covering index supporting lookups by `Icd10Code` with `Description` returned without a key lookup; confirms `Icd10Code` is the primary access path into this table.

**Gotchas**

- No inferred/declared relationships exist to any diagnosis field on patient/visit/order tables, so it's unclear from this metadata alone how consuming tables link to this code list (e.g. via a varchar column not matching this table's name) — treat any such linkage as unconfirmed until validated separately.
- All 74,720 sampled rows have `IsValid = true`; the column's `false` domain exists in schema but is not observed in current data, so its real-world usage (retiring deprecated ICD-10 codes) can't be demonstrated from this sample.
- `Icd10Code` is a varchar PK (not a surrogate int), typical for code-reference tables but worth noting for join-performance/typing consistency when referenced elsewhere.

---

## `rxqImmunizationInfo`

Rows (RXCS): 602,552 | Columns: 17 | PK: `ScriptNumber, RefillNumber` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores immunization-specific documentation attached to a dispensed script/refill — administration route, administering provider, administration timestamp/date, dose sequence number, and consent/reporting flags (e.g. consent to report to a state immunization registry, consent to share, comorbidity, positive serology) plus guardian identification for minor patients (inferred: pediatric vaccination consent requires a parent/guardian of record). One row per script+refill administration event, keyed 1:1 (or 1:many via RefillNumber) off `rxqScriptBase` (inferred). `PriorityGroup` and `PrimaryPhysicianId` suggest support for public-health prioritization tiers (e.g. COVID-era vaccine priority groups) and recording of a referring/primary physician independent of the prescriber on the script (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| ScriptNumber | int | NO | PK, → `rxqScriptBase` | part of composite PK |
| RefillNumber | int | NO | PK | part of composite PK |
| DoseNumber | int | NO | | sequence number within a multi-dose series (inferred) |
| AdminRoute | varchar(50) | YES | | e.g. IM, SC, oral (inferred; no sampled values) |
| ConsentToReport | bit | YES | | consent to report to immunization registry (inferred) |
| ConsentToShare | bit | YES | | consent to share immunization data (inferred) |
| Comorbidity | bit | YES | | flags presence of a comorbidity condition (inferred) |
| PositiveSerology | bit | YES | | flags a positive serology/antibody test result (inferred) |
| AdministeredBy | varchar(50) | NO | | administering provider identifier/name (inferred) |
| Administered | bit | YES | | whether the dose was actually administered (inferred) |
| GuardianFirstName | varchar(50) | YES | | guardian/parent first name (minor patients) |
| GuardianLastName | varchar(50) | YES | | guardian/parent last name |
| GuardianType | varchar(3) | YES | | coded relationship type (e.g. parent/guardian code); no sampled values present |
| PriorityGroup | varchar(50) | YES | | coded public-health priority tier (inferred); no sampled values present |
| PrimaryPhysicianId | varchar(50) | YES | | referring/primary physician identifier, distinct from script prescriber (inferred) |
| AdministeredAt | datetime | YES | | timestamp of administration |
| AdminDate | datetime | YES | | date of administration (possibly redundant with AdministeredAt) |

No columns have sampled lookup values (all coded columns — AdminRoute, GuardianType, PriorityGroup — came back with no lookup domain captured).

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):**
  - `ScriptNumber` → `rxqScriptBase` (join on `ScriptNumber`) — inferred, **high** confidence (99.5% referential match, 200,000 non-null sampled, 952 orphans) (sampled)
- **Inbound (inferred):** none

These are naming-based inferences that were data-validated against actual column values, not enforced database constraints — treat anything below high confidence as an unconfirmed guess. Here the single outbound edge is high confidence but not 100%: ~952 orphaned ScriptNumber values point to script records not found in `rxqScriptBase` (possibly purged/archived scripts).

**Indexes**

None reported (empty index list beyond the declared composite primary key).

**Gotchas**

- No ETL mirror into liberty_link_stage — this table's data is not currently available to eMed downstream.
- Composite PK is `(ScriptNumber, RefillNumber)` with no surrogate key; DoseNumber is NOT part of the key despite representing a dose sequence, so a given script+refill can only have one immunization row regardless of dose number.
- `AdministeredAt` and `AdminDate` are both datetime and likely overlapping/redundant — no data sampled to confirm which is authoritative.
- Guardian fields (`GuardianFirstName/LastName/Type`) are free-text/coded but have no declared link to a patient or guardian table — guardian identity here is not relationally verifiable, only descriptive.
- `PrimaryPhysicianId` is varchar(50), not an int FK to a physician table — likely an external/NPI-style identifier rather than an internal PK reference.
- 952 orphaned `ScriptNumber` values (0.48%) against `rxqScriptBase` — small but nonzero data-quality gap for anyone joining strictly.

---

## `rxqEcarePlan`

Rows (RXCS): 3 | Columns: 9 | PK: `PlanId` | ETL-mirrored into liberty_link_stage: no

**Purpose** — Stores patient "eCare plan" records, one row per plan identified by a `uniqueidentifier` `PlanId`, linked to a specific `PatientId`, dispensing `RphId` (pharmacist), and `StoreNumber`. Each row carries a `Status` and `SentDate`, and a `SubmissionId` that (inferred) associates the plan with an outbound immunization/care-plan submission (naming matches `rxqImmunizationSubmission`), suggesting this table backs a care-plan or clinical-documentation workflow tied to immunization reporting (inferred — e.g. SureScripts/NCPDP care-plan or immunization-history submission). The `Object` column (`varchar(max)`) likely holds a serialized (e.g. JSON/XML) payload of the full plan content (inferred — no schema detail beyond type/size supports more). Table is extremely low-volume (3 rows sampled), consistent with a newer or lightly-used Liberty module.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| PlanId | uniqueidentifier | NO | PK | |
| LastModified | datetime | NO | | |
| Status | varchar(50) | YES | | no sampled values (not in lookups) |
| SentDate | datetime | YES | | |
| SubmissionId | varchar(50) | YES | → `rxqImmunizationSubmission` | |
| PatientId | varchar(50) | NO | → `rxqPatient` | |
| RphId | varchar(50) | NO | | |
| StoreNumber | varchar(50) | NO | | |
| Object | varchar(max) | NO | | likely serialized plan payload (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**
  - `PatientId` → `rxqPatient` — inferred, **high** confidence (100.0% referential match).
  - `SubmissionId` → `rxqImmunizationSubmission` — inferred, **unvalidated** (parent table empty; no data to validate the join against — weak/unconfirmed).
- **Inbound (inferred)**
  - none

**Indexes** — none reported.

**Gotchas**
- Varchar(50) surrogate keys (`PatientId`, `RphId`, `StoreNumber`, `SubmissionId`) alongside a native `uniqueidentifier` PK — typical Liberty mixed key-typing.
- `SubmissionId` link to `rxqImmunizationSubmission` is unvalidated because that parent table has no rows at sample time; treat as a naming-based guess only, not a confirmed relationship.
- `Status` has no sampled lookup values, so its coded domain is unknown — do not assume specific status strings.
- Not mirrored by ETL, so this data is unavailable in liberty_link_stage / the eMed app; any use requires direct Liberty DB access.

---

## `rxqEcareTemplate`

Rows (RXCS): 1 | Columns: 14 | PK: `ceCareTemplateId` | ETL-mirrored into `liberty_link_stage`: no

**Purpose** — Stores reusable "e-care" documentation templates: named, store-scoped bundles of pre-canned text for a clinical/care encounter, keyed by `TemplateName` and `StoreNumber`, with separate free-text slots for encounter, procedures, conditions, observation, goals, communication, and immunization content (inferred: modeled after a SOAP/care-plan note structure, consistent with column naming). `eCareType` and `SaveOption` are small-int coded flags whose only observed values are `1` (inferred: likely single-value/boolean-style enums given the one-row sample — domain not confirmable beyond this). `SelctedTemplate` (bit) suggests a UI concept of a currently-selected/default template among several (inferred). With only 1 row in RXCS and no ETL mirroring, this appears to be a lightly-used or new/config-style Liberty feature table, not transactional patient data.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `ceCareTemplateId` | int | NOT NULL | PK | identity |
| `eCareType` | int | NULL | | sampled values: `1` (count 1) |
| `TemplateEncounter` | varchar(max) | NULL | | free text |
| `TemplateProcedures` | varchar(max) | NULL | | free text |
| `TemplateConditions` | varchar(max) | NULL | | free text |
| `TemplateObservation` | varchar(max) | NULL | | free text |
| `TemplateGoals` | varchar(max) | NULL | | free text |
| `TemplateCommunication` | varchar(max) | NULL | | free text |
| `TemplateImmunization` | varchar(max) | NULL | | free text |
| `TemplateName` | varchar(200) | NULL | → `ReportFilterTemplates` | implicit ref, unvalidated (see below) |
| `StoreNumber` | nvarchar(50) | NULL | | store scoping, no validated ref |
| `SelctedTemplate` | bit | NULL | | note: column name misspelled ("Selcted") in source schema |
| `SaveOption` | int | NULL | | sampled values: `1` (count 1) |
| `LastModified` | datetime | NULL | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**: `TemplateName` → `ReportFilterTemplates` (join col `TemplateName`) — inferred from column naming, **unvalidated** confidence (parent table empty, so referential match could not be checked; not sampled).
- **Inbound (inferred)**: none.

**Indexes** — none declared.

**Gotchas**
- Only 1 row present in RXCS at extraction time — any structural conclusions (e.g. enum domains for `eCareType`/`SaveOption`) are drawn from a single sample and unconfirmed as general domains.
- `SelctedTemplate` is a literal misspelling in the live schema ("Selcted" instead of "Selected") — preserve as-is when referencing the real column.
- The one inferred relationship (`TemplateName` → `ReportFilterTemplates`) could not be data-validated because the referenced table is empty; treat as a naming-based guess only, not a confirmed link.
- Not mirrored by ETL, so this table is invisible to `liberty_link_stage`/eMed-side reporting — any care-template feature work must query Liberty directly.

---

## `rxqEcareCode`

Rows: 333 (RXCS) · Columns: 6 · PK: (`SystemId`, `Code`, `Type`) · ETL-mirrored into liberty_link_stage: no

**Purpose**

A small coded-lookup/reference table storing code values (`Code`), grouped by a `Category` label, a `Type` classifier, and a human-readable `Description`, with an `Order` column controlling display/sort sequence — a typical "e-care" (electronic care / eCare messaging or clinical-flag) code list used to populate dropdowns or classify records elsewhere in Liberty (inferred). The composite PK of `SystemId`+`Code`+`Type` indicates the same `Code` value can recur across different multi-tenant `SystemId`s and different `Type` classifications without colliding (inferred). No outbound relationships were detected, consistent with this being a low-level, self-contained code/reference table rather than a table that itself references other entities.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| SystemId | char(1) | NOT NULL | PK | |
| Code | varchar(50) | NOT NULL | PK | referenced by `RxCompoundStoreCode.Code`, `rxqPriceFormula.Code`, `SupportedLanguages.Code` (inferred, see Relationships) |
| Type | int | NOT NULL | PK | coded domain, sampled values: 4 (195), 1 (60), 2 (59), 3 (17), 0 (2) |
| Category | varchar(50) | NULL | | grouping label for the code |
| Description | varchar(100) | NULL | | human-readable text for the code |
| Order | int | NOT NULL | | display/sort sequence |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none.
- **Inbound (inferred):**
  - `RxCompoundStoreCode.Code` → `rxqEcareCode` — inferred, **low** confidence (0.0% referential match)
  - `rxqPriceFormula.Code` → `rxqEcareCode` — inferred, **low** confidence (0.0% referential match)
  - `SupportedLanguages.Code` → `rxqEcareCode` — **no-data** confidence (parent/child had no comparable data to validate)

These inbound edges are naming-based guesses only, data-validated and found weak or unconfirmed (0% match rate for two, no data for the third) — treat them as unconfirmed, not real join paths.

**Indexes**

None reported.

**Gotchas**

- All three inbound "referenced_by" candidates data-validated at 0% match or no-data — despite the shared column name `Code`, there is no confirmed evidence these tables actually join to `rxqEcareCode`. Do not assume a real relationship without further investigation.
- Composite varchar+int PK (`SystemId`, `Code`, `Type`) rather than a surrogate key — joins/lookups against this table require all three columns, not just `Code`.
- Not ETL-mirrored to liberty_link_stage, so this reference data is not available in the eMed warehouse; any downstream use requires a live Liberty query or a new mirroring step.

---

## `RxqLabPatientRecord`

Rows (RXCS): 1,737 | Columns: 6 | PK: `LabId` | ETL-mirrored into liberty_link_stage: no

**Purpose**: Stores individual lab result values recorded against a patient (`PatientId` → `rxqPatient`), each typed by `TypeId` → `RxqLabType`, with a numeric result (`LabValue`), the date the lab was taken (`LabDate`), and an optional `AddedBy` audit field recording who entered the record. (inferred) In a pharmacy workflow this likely supports clinical checks tied to dispensing (e.g., monitoring labs like A1C/INR relevant to therapy) since it is scoped per-patient and per-lab-type with a decimal result value, though the specific lab types are only resolvable via the `RxqLabType` lookup table (not included in this extract).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| LabId | int | NO | PK | identity |
| TypeId | int | NO | → RxqLabType | sampled values: 117 (n=1241), 110 (n=448), 111 (n=24), 112 (n=24) |
| PatientId | varchar(50) | NO | → rxqPatient | |
| LabValue | decimal(18,3) | NO | | numeric lab result |
| LabDate | date | NO | | date lab was recorded/taken |
| AddedBy | varchar(200) | YES | | audit field, likely username/operator of record entry (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**:
  - `TypeId` → `RxqLabType` — inferred, **high** confidence (100.0% referential match)
  - `PatientId` → `rxqPatient` — inferred, **high** confidence (100.0% referential match)
- **Inbound (inferred)**: none

These edges are inferred from column naming and were data-validated against actual parent-key values (not declared database constraints).

**Indexes**

None reported (no indexes present on this table in the extract).

**Gotchas**

- `PatientId` is a varchar(50) key (not int), consistent with Liberty's general pattern of string-typed patient identifiers rather than surrogate int keys.
- `TypeId` domain is a small, concentrated set (4 distinct values sampled, dominated by 117 and 110) — the actual meaning of each type code lives only in `RxqLabType`, which is out of scope for this extract.
- No indexes exist beyond the PK — lookups by `PatientId` or `TypeId` would require table scans unless Liberty relies on the clustered PK/identity order.
- Not mirrored by ETL into liberty_link_stage, so this data is not available to eMed via the standard mirror; any consumer needing lab data would need a separate extraction path.

---

## `RxqLabType`

Rows (RXCS): 123 | Columns: 7 | PK: `TypeId` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Lookup/reference table defining lab test types (e.g. individual lab panels or analytes), each assigned to a category (`CatId` → `RxqLabCategories`) and carrying a unit of measure (`UnitType`) plus normal reference range bounds (`LowNormal`/`HighNormal`) and a `LoincCode` (inferred: LOINC standard code for interoperable lab result identification, per SureScripts/clinical-lab conventions). It is referenced by `RxqLabPatientRecord.TypeId` (100% match, high confidence), indicating this table supplies the type definition for individual patient lab result records (inferred: parent config table in a patient lab-results workflow).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| TypeId | int | NO | PK | identity |
| CatId | int | NO | → `RxqLabCategories` | |
| LabName | varchar(100) | YES | | |
| UnitType | varchar(50) | YES | | |
| HighNormal | decimal(18,3) | YES | | |
| LowNormal | decimal(18,3) | YES | | |
| LoincCode | varchar(50) | YES | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- Outbound (inferred):
  - `CatId` → `RxqLabCategories` — inferred, **high** confidence (100.0% referential match).
- Inbound (inferred):
  - `RxqLabPatientRecord.TypeId` → this table — inferred, **high** confidence (100.0% referential match).

**Indexes**

None reported (no indexes defined on this table in the extract).

**Gotchas**

- Not ETL-mirrored into liberty_link_stage — eMed has no direct visibility into lab type definitions or downstream patient lab records via this path.
- No `lookups` sampled (columns too high-cardinality/free-text for enum sampling); `UnitType` and `LabName` domains are unknown from this extract — do not assume values.
- `LoincCode` presence suggests intended standards-based interoperability, but format/validity is unverified here (inferred only).

---

## `RxqLabCategories`

rows (RXCS): 10, columns: 2, PK: `CatId`, ETL-mirrored into liberty_link_stage: no.

**Purpose**

A tiny reference/lookup table holding lab category names (`Category`, varchar(50)) keyed by an identity `CatId`. It is referenced by `RxqLabType.CatId` with a 100% referential match, indicating it groups lab test types into higher-level categories (inferred) — likely used to organize lab test definitions (e.g. chemistry, hematology, microbiology panels) within the pharmacy's lab-order/lab-result subsystem (inferred). With only 10 rows, this is a static/rarely-changed configuration table rather than transactional data.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| CatId | int | NOT NULL | PK | identity |
| Category | varchar(50) | NULL | | no sampled values (not in lookups) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none.
- **Inbound (inferred):**
  - `RxqLabType.CatId` → `RxqLabCategories` — inferred, **high** confidence (100.0% referential match).

These edges are inferred from column naming and data-validated against actual values, not declared database constraints.

**Indexes**

None defined.

**Gotchas**

- No indexes at all, not even on the PK beyond the implicit identity constraint shown — verify join performance if `RxqLabType` scans grow large.
- `Category` is nullable with no sampled lookup values provided, so its coded domain is unknown from this extract; treat contents as free text until confirmed.
- Not mirrored by ETL into liberty_link_stage, so this table is only visible in the source Liberty DB, not in the eMed reporting mirror.

---
