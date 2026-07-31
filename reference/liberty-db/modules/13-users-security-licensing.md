# Liberty schema — Users, Security & Licensing

Application users, roles, privileges and security groups, the security event log, staff time-clock shifts, professional/multi-state licenses, and data-access restriction rules.

> Part of the [Liberty/RxQ schema reference](../README.md). Liberty declares **no foreign-key constraints** (verified via `sys.foreign_keys`), so all relationships shown are **inferred from column naming and then data-validated** by referential match rate — each is tagged high / medium / low / no-data / unvalidated confidence. Row counts and sampled enum values are from the RXCS instance (point-in-time); the schema itself is identical across the rxcs / mmed / mdvo tenants.

**Tables in this module (11):** [`rxqUser`](#rxquser) · [`rxqUserRoles`](#rxquserroles) · [`rxqPrivileges`](#rxqprivileges) · [`rxqSecurityGroup`](#rxqsecuritygroup) · [`rxqSecurityLogEntry`](#rxqsecuritylogentry) · [`rxqUserLicenses`](#rxquserlicenses) · [`rxqMultipleStatesLicense`](#rxqmultiplestateslicense) · [`rxqProLicense`](#rxqprolicense) · [`RxqRestrictionsMaster`](#rxqrestrictionsmaster) · [`RxqRestrictionsFilters`](#rxqrestrictionsfilters) · [`rxqTimeClockShift`](#rxqtimeclockshift)

---

## `rxqUser`

Rows (RXCS): 134 · Columns: 50 · PK: `RecordId` · ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores Liberty pharmacy-system user/staff accounts: login credentials (encrypted/hashed password + 4 generations of password history for reuse-prevention), account-lockout and password-policy state, contact/HR fields (name, birth/hire date, phone, email), UI preferences (theme, color, default views), and Windows-AD / global-identity linkage. It is the application's internal identity table for pharmacy staff (pharmacists, cashiers, etc.) rather than a patient- or order-facing table (inferred, based on fields like `RphInitials`, `CashierInitials`, `HireDate`, `PromptForClockIn`). No rows are ETL-mirrored to eMed, consistent with it holding credentials/PII for internal staff, not clinical/order data.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cUserId | int | NO | | identity |
| RecordId | varchar(50) | NO | PK | |
| EncryptedPassword | varchar(50) | YES | | |
| LastLoginDate | datetime | YES | | |
| FirstName | varchar(50) | YES | | |
| LastName | varchar(50) | YES | | |
| RphInitials | varchar(50) | YES | | pharmacist initials (inferred) |
| PrevEncryptedPassword1 | varchar(50) | YES | | password-history slot 1 |
| PrevEncryptedPassword2 | varchar(50) | YES | | password-history slot 2 |
| PrevEncryptedPassword3 | varchar(50) | YES | | password-history slot 3 |
| PrevEncryptedPassword4 | varchar(50) | YES | | password-history slot 4 |
| PasswordChanged | date | YES | | |
| LockOut | datetime | YES | | lockout timestamp |
| LockOutCount | int | YES | | |
| PasswordRequired | varchar(50) | YES | | |
| TimeOutMinutes | int | YES | | session idle-timeout setting (inferred) |
| CashierInitials | varchar(50) | YES | | |
| MASTERRECORDID | varchar(50) | YES | | |
| LastModified | datetime | YES | | |
| IsValid | bit | YES | | sampled values: `true`=134 (all sampled rows active) |
| PIN | varchar(50) | YES | | |
| Email | varchar(50) | YES | | |
| MobilePhone | varchar(50) | YES | | |
| HomePhone | varchar(50) | YES | | |
| Title | varchar(50) | YES | | job title (inferred) |
| MyTheme | varchar(50) | YES | | UI theme preference |
| UserImage | varbinary(max) | YES | | photo/avatar blob (inferred) |
| BirthDate | datetime | YES | | |
| HireDate | datetime | YES | | |
| ForcePasswordChange | bit | NO | | |
| WindowsAD | varchar(256) | YES | | Windows Active Directory identity link (inferred) |
| LoggableStores | varchar(50) | YES | | store-scope restriction for logging/access (inferred) |
| PromptForClockIn | bit | YES | | |
| LibertyId | varchar(50) | YES | | |
| NewUser | bit | YES | | |
| UserColor | int | YES | | sampled values: `0`=129, `null`=1, `2025787510`=1, `2024948928`=1, `2018812955`=1, `2014347466`=1 (mostly 0; a few large int-packed color codes, e.g. RGB int) |
| ReleaseNotesLastCheckedRxqVersion | varchar(50) | YES | | |
| PhoneExtension | varchar(20) | YES | | |
| GlobalUserId | uniqueidentifier | YES | | cross-system/tenant global identity (inferred) |
| AccountLocked | bit | YES | | |
| AccountDisabled | bit | YES | | |
| LastChecked | datetime | YES | | |
| EscriptDefaultView | int | YES | | sampled values: `0`=86, `null`=48 |
| VerificationDefaultView | int | YES | | sampled values: `null`=134 (always null in sampled rows) |
| PWEnrollee | bit | NO | | password-manager/"PW" enrollment flag (inferred) |
| HashedPassword | nvarchar(max) | YES | | current hashing scheme, supersedes `EncryptedPassword` (inferred) |
| PrevHashedPassword1 | nvarchar(max) | YES | | password-history slot 1 (hashed) |
| PrevHashedPassword2 | nvarchar(max) | YES | | password-history slot 2 (hashed) |
| PrevHashedPassword3 | nvarchar(max) | YES | | password-history slot 3 (hashed) |
| PrevHashedPassword4 | nvarchar(max) | YES | | password-history slot 4 (hashed) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

No column-naming-based relationships were inferred/detected in either direction for this table (e.g., no `*UserId`-style column resolving into another table's key, and no other table's column was matched against `rxqUser`'s keys). `RecordId`/`cUserId` may still be referenced by other tables' user-stamp columns (e.g. audit "modified by" fields) that weren't detected by the naming/data-validation heuristic — treat any such link as unconfirmed.

**Indexes**
None reported (no indexes present in the extracted metadata beyond the implicit PK constraint on `RecordId`).

**Gotchas**
- Dual credential schemes coexist: legacy `EncryptedPassword`/`PrevEncryptedPassword1-4` alongside newer `HashedPassword`/`PrevHashedPassword1-4` — likely mid-migration between encryption and hashing (inferred); consumers must check both.
- PK `RecordId` is `varchar(50)`, not the `cUserId` int identity column — typical Liberty pattern of a surrogate string PK distinct from the internal identity counter.
- `VerificationDefaultView` is null for 100% of sampled rows and `EscriptDefaultView` is null for ~36% — likely unused/legacy or feature-flag-gated settings (inferred).
- Contains actual PII/credential material (password hashes, PIN, birth date, phone, email) — sensitive table, appropriately excluded from ETL mirroring to eMed.

---

## `rxqUserRoles`

Rows (RXCS): 149 · Columns: 5 · PK: `RecordId`, `UserRoleType` (composite) · ETL-mirrored into `liberty_link_stage`: no

**Purpose**

Stores a per-record assignment of a coded role type (`UserRoleType`) plus the initials of the user associated with that role (inferred). `RecordId` is a varchar(50) key rather than a typed FK to any specific entity table, so this looks like a generic/polymorphic "who holds what role on this record" join table (inferred) rather than a table scoped to one parent entity — no naming or data evidence ties `RecordId` to a specific table (no `inferred_relationships` were detected). `LastModified` suggests standard audit-tracking of when the role assignment last changed. The composite PK (`RecordId`+`UserRoleType`) implies at most one assignment of a given role type per record.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cUserRolesId | int | NOT NULL | | identity (auto-increment surrogate) |
| RecordId | varchar(50) | NOT NULL | PK | no implicit_ref detected — target entity not inferable from naming/data |
| UserRoleType | int | NOT NULL | PK | coded domain, sampled values: `2` (92), `1` (27), `5` (21), `4` (7), `3` (2) |
| Initials | varchar(50) | NULL | | likely user initials (inferred) |
| LastModified | datetime | NULL | | audit timestamp (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no `inferred_relationships` were detected for `RecordId` or any other column; despite the name, no target table could be data-validated (treat `RecordId`'s referent as unknown/unconfirmed).
- **Inbound (inferred):** none — no other table's columns were inferred to reference `rxqUserRoles`.

**Indexes**

None reported (no indexes beyond the implicit composite PK constraint on `RecordId`+`UserRoleType`).

**Gotchas**

- `RecordId` is a varchar(50) key with no confirmed parent table — despite the generic name, treat any assumption about what entity it points to as unverified; do not assume it's patient/prescriber/order without further evidence.
- `UserRoleType` is a small numeric enum (values 1–5 observed) with no accompanying lookup/description table in this metadata — the meaning of each code (e.g., what role `2` vs `5` represents) is not documented here and would need to be sourced from the Liberty application or a separate codes table.
- Not ETL-mirrored, so this data is not queryable from `liberty_link_stage`; any eMed-side use would require direct Liberty DB access.

---

## `rxqPrivileges`

Rows: 1,148 (RXCS) · Columns: 6 · PK: (`Type`, `Entity`, `PrivilegeId`) · ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores a static catalog/registry of definable privilege (permission) entries used by Liberty's role-based access control, keyed by a composite of `Type` and `Entity` plus a numeric `PrivilegeId` (inferred). `IsValid` marks whether a given privilege entry is currently active (100% of sampled rows are `true`), and `LastModified` tracks when the entry was last changed. It appears to be a lookup/definition table (not a transactional log) that other tables — plausibly a `UserPermissions`-style grant table — reference by `PrivilegeId` to associate specific privileges with users, roles, or entities (inferred; the only detected inbound reference is unvalidated).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cPrivilegesId | int | NOT NULL | | identity |
| Type | varchar(50) | NOT NULL | PK | part of composite PK |
| Entity | varchar(50) | NOT NULL | PK | part of composite PK |
| PrivilegeId | int | NOT NULL | PK | part of composite PK; referenced (inferred, unconfirmed) by `UserPermissions.PrivilegeId` |
| LastModified | datetime | NULL | | |
| IsValid | bit | NULL | | sampled values: `true` (1,148) — i.e., all sampled rows are valid |

**Relationships**
Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):**
  - `UserPermissions.PrivilegeId` → this table's `PrivilegeId` — inferred, **no-data** confidence (match rate not computed; parent/child data unavailable to validate). Treat as an unconfirmed guess based on column naming only.

**Indexes**
None reported (no non-default indexes beyond the implicit composite PK).

**Gotchas**
- Composite varchar+varchar+int primary key (`Type`, `Entity`, `PrivilegeId`) rather than a single surrogate key, despite an identity column (`cPrivilegesId`) existing alongside it — the identity column is NOT part of the PK, so it's likely just a row-order/audit artifact, not the natural key (inferred).
- `Type` and `Entity` are unconstrained free-text `varchar(50)` — no lookup/enum data was sampled for either, so their value domains are undocumented here.
- The single inbound reference (`UserPermissions.PrivilegeId`) is unvalidated ("no-data"), meaning the join was never confirmed against real data — do not treat it as a reliable relationship without further verification.
- Not mirrored by ETL, so this table is invisible to liberty_link_stage-based reporting/queries; any consumer needing privilege definitions must query Liberty directly.

---

## `rxqSecurityGroup`

Rows: 4 (RXCS) · Columns: 6 · PK: `Id` · ETL-mirrored into liberty_link_stage: no

**Purpose** — A tiny, near-static lookup/reference table defining security groups (roles) within the Liberty pharmacy-management system, holding only 4 rows, each with a `Name`, `Description`, and an `IsValid` active flag (all 4 sampled rows are valid) (inferred). It is referenced by `rxqWorkflowCustomStage.cSecurityGroupId`, suggesting security groups gate which roles can act on or view a given custom workflow stage (inferred). The presence of both an identity column `cSecurityGroupId` and a separate non-identity PK `Id` suggests `Id` is the stable business key used elsewhere in the system while `cSecurityGroupId` may be a vestigial/parallel counter (inferred) — no data confirms their relationship since both are unpopulated in lookups except `cSecurityGroupId`, which for these 4 rows equals 1-4.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cSecurityGroupId | int | No | | identity; sampled values: 4, 3, 2, 1 (each count 1) |
| Id | int | No | PK | |
| Name | varchar(50) | Yes | | |
| Description | varchar(50) | Yes | | |
| LastModified | datetime | Yes | | |
| IsValid | bit | Yes | | sampled values: true (count 4) — only value observed across all 4 rows |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):**
  - `rxqWorkflowCustomStage.cSecurityGroupId` → this table — inferred, **no-data** confidence (no match rate available; parent-side validation could not be computed)

**Indexes** — none reported.

**Gotchas**
- Two candidate key columns exist (`Id` as declared PK vs. `cSecurityGroupId` as identity); the inbound reference from `rxqWorkflowCustomStage` uses `cSecurityGroupId`, not the PK `Id` — confirm which column is the true join key before relying on it, since the metadata could not data-validate this edge (no-data confidence, parent may have been empty or type-mismatched at sample time).
- Only 4 rows total and no lookups captured for `Name`/`Description`, so the actual security-group names/roles are unknown from this extract alone.

---

## `rxqSecurityLogEntry`

Rows (RXCS): 328,613 | Columns: 7 | PK: `cSecurityLogEntryId` | ETL-mirrored into liberty_link_stage: no

**Purpose** — An application-level security/audit event log for the Liberty pharmacy system, recording one row per event with a timestamp (`EntryDate`), the acting user (`UserId`), an event-type code (`SecurityEvent`), and free-form event detail (`EventData`) (inferred). `IsValid` is present on every sampled row as `true`, suggesting it is a soft-delete/active flag rather than a meaningful validity check on this data (inferred). No PHI-bearing or patient/prescription linkage columns exist, so this table is purely a security/access audit trail, not a clinical workflow table (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cSecurityLogEntryId | int | NO | PK | identity |
| EntryDate | datetime | YES | | timestamp of the security event (inferred) |
| UserId | varchar(50) | YES | | acting user identifier; no `implicit_ref` detected (not validated as an FK to a users table) |
| SecurityEvent | varchar(50) | YES | | event-type code; no sampled lookup values available |
| EventData | varchar(500) | YES | | free-form event detail/payload (inferred) |
| LastModified | datetime | YES | | standard audit timestamp (inferred) |
| IsValid | bit | YES | | sampled values: `true` (328,613 / 328,613 rows) — no `false` observed in sample |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

No columns in this table carry an `implicit_ref` to another table, and no other table's columns were inferred to reference this table's key. `UserId` is a plausible candidate for a relationship to a users/security table by naming convention, but no such inferred/data-validated edge was captured in the metadata — treat any such link as unconfirmed.

**Indexes** — none reported (no indexes defined beyond the PK).

**Gotchas**

- Not ETL-mirrored into liberty_link_stage — this data is not available in the eMed reporting/mirror pipeline.
- `IsValid` is 100% `true` in the sampled data; if it is meant as a soft-delete flag, no soft-deleted rows are present/sampled, so its behavior under `false` is unverified.
- `UserId` is a varchar(50), not an int FK to a numeric user table — join keys, if any, would be string-based and are unvalidated here (no inferred_relationships present).
- No indexes beyond the PK despite 328K+ rows — queries filtering by `EntryDate`, `UserId`, or `SecurityEvent` would rely on table/heap scans unless indexes exist outside what was captured.

---

## `rxqUserLicenses`

Rows (RXCS): 8 · Columns: 8 · PK: (`RecordId`, `LicenseType`, `LicenseState`) · ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores professional-license records (type/state/number/expiration) tied to a `RecordId`, with a composite key allowing multiple license types per state and (via the related `rxqMultipleStatesLicense` table) multiple states per license type (inferred). `LicenseExpiration` and `DateSnoozed` suggest this table drives license-expiration tracking/reminders for pharmacy staff (e.g., pharmacists/techs holding state board licenses), with `DateSnoozed` letting a user dismiss/defer an expiration alert (inferred). No columns or lookups sample actual `LicenseType` codes, so the enum domain (e.g., RPh vs. Tech vs. DEA) cannot be confirmed from this metadata alone.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `cUserLicenseId` | int | NOT NULL | | identity |
| `RecordId` | varchar(50) | NOT NULL | PK | likely references a user/employee record by name (inferred); no inferred_relationship recorded |
| `LicenseType` | int | NOT NULL | PK | referenced by `rxqMultipleStatesLicense.LicenseType` (low confidence, see below); no lookup values sampled |
| `LicenseNumber` | varchar(200) | NULL | | |
| `LicenseState` | varchar(25) | NOT NULL | PK | state code/name for the license |
| `LicenseExpiration` | date | NULL | | |
| `LastModified` | datetime | NULL | | |
| `DateSnoozed` | date | NULL | | likely used to suppress/defer expiration reminders (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

These are INFERRED from column naming and DATA-VALIDATED against actual values — not declared constraints.

- **Outbound (inferred):** none

- **Inbound (inferred):**
  - `rxqMultipleStatesLicense.LicenseType` → this table's `LicenseType` — inferred, **low** confidence (0.0% referential match). Treat as unconfirmed/weak; the two `LicenseType` columns do not currently share matching values in sampled data.

**Indexes**
None returned in metadata (empty index list).

**Gotchas**
- Composite 3-column PK (`RecordId`, `LicenseType`, `LicenseState`) — varchar-typed `RecordId` and `LicenseState` rather than surrogate keys typical of Liberty's schema style.
- `RecordId` naming implies a link to a staff/user record, but no implicit_ref or inferred_relationship is present — cannot confirm which table it joins to from this metadata.
- `LicenseType` has zero validated referential match from `rxqMultipleStatesLicense`, despite the naming suggesting a relationship — likely a coincidental/legacy naming pattern or a code-domain mismatch rather than a true join key.
- Very small table (8 rows in RXCS) — any join-rate statistics here are low-confidence due to sample size alone, independent of the match_rate computation.

---

## `rxqMultipleStatesLicense`

Rows: 1 (RXCS) · Columns: 6 · PK: `cMultipleStatesLicenseId` · ETL-mirrored into liberty_link_stage: no

**Purpose** — Stores a per-store, per-state pharmacy/user license record: a `StoreNumber`, a `LicenseType` code, a `LicenseNumber`, and the `State` it applies to, with a `LastModified` audit timestamp (inferred). The table name and columns suggest it tracks licensure needed to legally operate/dispense across multiple states from a single store (inferred). With only 1 row in RXCS, it appears sparsely populated / lightly used in this tenant (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cMultipleStatesLicenseId | int | NO | PK | identity |
| StoreNumber | varchar(50) | YES | | |
| LicenseType | int | YES | → rxqUserLicenses (weak, see Relationships) | coded value, no lookup domain sampled |
| LicenseNumber | varchar(max) | YES | | |
| State | varchar(50) | YES | | free-text/state code, no lookup domain sampled |
| LastModified | datetime | YES | | audit timestamp |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**:
  - `LicenseType` → `rxqUserLicenses` — inferred, **low** confidence (0.0% referential match, 1 non-null value checked, not sampled). This is a weak/unconfirmed guess based on column naming only; the single existing value did not match the referenced table's key.
- **Inbound (inferred)**: none.

**Indexes** — none reported.

**Gotchas**
- Only 1 row exists in RXCS and its `LicenseType` value is an orphan against `rxqUserLicenses` (0% match) — treat the `LicenseType` → `rxqUserLicenses` link as unconfirmed; with n=1 this single data point cannot establish a reliable relationship either way.
- `LicenseNumber` is `varchar(max)` despite being a small coded field elsewhere in Liberty (e.g. license numbers) — unusually wide type for the apparent content.
- No lookup/enum values were sampled for `LicenseType` or `State`, so their coded domains are unknown from this extract.
- Not ETL-mirrored, so this data is not visible in liberty_link_stage/eMed reporting.

---

## `rxqProLicense`

Rows: 24 (RXCS) · Columns: 4 · PK: `MacAddress` · ETL-mirrored into liberty_link_stage: no

**Purpose**

Tracks per-workstation Liberty client-software license/activation seats: a `MacAddress`-keyed row per registered `ComputerName`, with `LastAccessDate` and an `ActiveFlag` (inferred). This looks like a software-license or workstation-registration table for the Liberty desktop application rather than pharmacy/clinical data — it has no columns referencing patients, prescriptions, or orders, and no other table's naming suggests it feeds them (inferred). All 24 sampled rows have `ActiveFlag = true`, suggesting either all 24 registered machines are currently active, or the flag is rarely (if ever) set false in practice (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| MacAddress | varchar(50) | NO | PK | Workstation MAC address; primary key (varchar key, not surrogate int) |
| ComputerName | varchar(50) | NO | | Registered machine/host name |
| LastAccessDate | date | NO | | Date of last access/check-in by this workstation (inferred) |
| ActiveFlag | bit | NO | | Sampled values: `true` (24/24 rows) — no `false` observed in sample |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

**Indexes**

None reported (no indexes beyond the implicit PK constraint on `MacAddress`).

**Gotchas**

- Primary key is a varchar MAC address string, not a surrogate/identity key — typical of Liberty's ad-hoc licensing tables, atypical for its main operational tables.
- Zero inferred relationships in either direction — this table appears isolated from the rest of the schema (no patient/order/Rx linkage), consistent with it being an infrastructure/licensing table rather than a clinical-workflow table.
- Not ETL-mirrored to liberty_link_stage — irrelevant to downstream eMed reporting/joins; do not expect to find it in the mirror DB.
- Sample is tiny (24 rows) and `ActiveFlag` shows only `true` — cannot confirm whether `false` values ever occur or what deactivation means operationally.

---

## `RxqRestrictionsMaster`

Rows (RXCS): 27 · Columns: 5 · PK: `RestrictionId` · ETL-mirrored into liberty_link_stage: no

**Purpose** — A small master/lookup table defining named restriction rules, each with a `RestrictionName`, a `Result` (outcome/action code, both varchar), and an optional `Message` (up to 800 chars) presumably displayed to pharmacy staff when the restriction is triggered (inferred). `RestrictionType` is present on all 27 sampled rows with a single observed value of `0`, so its coded domain is not distinguishable from this data alone (inferred: likely a category/severity flag with other codes unused or reserved). No FK-style columns point elsewhere and no other table's columns reference this one by name, so its role in the broader workflow (e.g. patient, drug, or prescriber restriction checks) cannot be confirmed from schema/data alone (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| RestrictionId | numeric(18,0) | NO | PK | identity |
| RestrictionName | varchar(50) | NO | | |
| Result | varchar(50) | NO | | |
| Message | varchar(800) | YES | | |
| RestrictionType | int | YES | | sampled values: `0` (27/27 rows) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

No column-naming-based edges were inferred in either direction; this table appears schema-isolated relative to the rest of the extract.

**Indexes** — none declared (empty index list).

**Gotchas**
- `RestrictionType` shows only a single value (0) across all 27 rows in this sample — do not assume it's a boolean or that other codes don't exist elsewhere/over time; just insufficient data here to enumerate the full domain.
- `Result` and `RestrictionName` are both loosely-typed varchar with no observed lookup values captured, so their content/format is unverified from this metadata.
- Not mirrored by ETL — not present in liberty_link_stage; any consuming logic must query Liberty directly.

---

## `RxqRestrictionsFilters`

Rows (RXCS): 29 | Columns: 6 | PK: `RestrictionId`, `RestrictionClass`, `RestrictionProperty`, `RestrictionOperationFilter`, `RestrictionValue` (composite) | ETL-mirrored into liberty_link_stage: no

**Purpose** — Stores a small, low-cardinality table of restriction/filter rule definitions keyed by a composite of restriction id, a class (grouping/category), a property (the field being restricted), an operation-filter (likely a comparison/operator token such as equals, not-equals, in, etc. — (inferred)), and the literal value to match. The wide `RestrictionValue` (varchar(600)) and free-text `RestrictionPropertyType` suggest this is a generic rule/config table used to configure business-logic restrictions (e.g., dispensing, filtering, or workflow eligibility rules) that Liberty evaluates against some property of a class of entity (inferred — no sampled values or FK evidence available to confirm the entity class). With only 29 rows, this looks like a small reference/configuration table rather than a transactional or high-volume operational table.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| RestrictionId | numeric(18,0) | NO | PK | part of composite PK |
| RestrictionClass | varchar(50) | NO | PK | part of composite PK; likely a category/grouping code for the restriction (inferred) |
| RestrictionProperty | varchar(50) | NO | PK | part of composite PK; likely names the field/attribute being restricted (inferred) |
| RestrictionPropertyType | varchar(50) | YES | | not part of PK; likely a data-type/format tag for RestrictionProperty (inferred) |
| RestrictionOperationFilter | varchar(50) | NO | PK | part of composite PK; likely an operator/comparison token (e.g. equals/in/range) (inferred) |
| RestrictionValue | varchar(600) | NO | PK | part of composite PK; the literal restriction value/criteria being matched (inferred) |

No columns appear in `lookups` (none sampled/available for this table), so no enum domains can be listed from data.

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — `inferred_relationships` is empty; no column names in this table matched the naming pattern used to infer references to other tables.
- **Inbound (inferred):** none — `inferred_referenced_by` is empty; no other table's columns were inferred to reference this table's keys.

All relationship inference for this table returned no edges; any linkage to other tables (e.g., which entity `RestrictionClass`/`RestrictionProperty` actually governs) is unconfirmed and would need to be established by application-code/business-logic review, not schema/data evidence.

**Indexes** — none reported (empty `indexes` array; only the implicit composite primary key constrains uniqueness).

**Gotchas**
- Composite PK spans all 5 non-nullable columns including a 600-char varchar (`RestrictionValue`) — unusually wide key component; joins/lookups against this table must match on the full tuple, not just `RestrictionId`.
- No FK constraints and no inferred relationships (outbound or inbound) — this table is schema-isolated from the rest of the extracted graph; its `RestrictionClass`/`RestrictionProperty` values likely correspond to entities/fields defined only in application code, not in the database.
- `RestrictionPropertyType` is nullable and outside the PK, functioning as descriptive metadata rather than a discriminator.
- No sampled lookup values were captured, so the actual coded domains of `RestrictionClass`, `RestrictionOperationFilter`, etc. are unknown from this metadata alone — treat any stated meaning above as inferred, not confirmed.

---

## `rxqTimeClockShift`

rows (RXCS): 2 | columns: 6 | PK: `id` | ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores pharmacy staff time-clock punches — one row per shift with a clock-in (`TimeIn`) and clock-out (`TimeOut`) timestamp for a given `UserId`, a coded `ShiftType`, and an `EntryEdited` flag marking manual corrections to the punch (inferred). This is an employee time/attendance record, not a clinical or order-processing table (inferred). Row count of 2 indicates negligible real-world use in this instance (point-in-time) — likely a lightly-used or deprecated timekeeping feature (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| id | nvarchar(50) | NO | PK | |
| UserId | nvarchar(50) | YES | | likely references a Liberty user/employee table (no implicit_ref detected, no inferred relationship recorded) |
| TimeIn | datetime | YES | | shift clock-in timestamp |
| TimeOut | datetime | YES | | shift clock-out timestamp |
| ShiftType | int | YES | | coded shift type; sampled values: `0` (count 2) — only one value observed, domain otherwise unknown |
| EntryEdited | bit | YES | | flag, presumably indicating the punch was manually edited (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no inferred_relationships were detected/validated for this table (e.g. `UserId` has no recorded implicit_ref or data-validated match, despite the naming suggesting a user/employee parent).
- **Inbound (inferred):** none — no other table's columns were inferred/validated to reference this table.

All relationship edges in this system are inferred from column naming and then data-validated against actual values, not enforced by the database; the absence of any detected edges here means the naming-based inference produced nothing to validate, not that no logical relationship exists.

**Indexes**
- `IX_TimeClockShift_TimeOut` (nonclustered, `TimeOut`) — supports lookups/reporting by clock-out time.
- `IX_TimeClockShift_UserId_TimeOut` (nonclustered, `UserId`, `TimeOut`) — supports per-user shift history queries ordered/filtered by clock-out.
- `NonClusteredIndex-20180320-161631` (nonclustered, `UserId`) — per-user lookup path.
- `NonClusteredIndex-20180320-161813` (nonclustered, `TimeIn`, `TimeOut`) — supports shift-duration/range queries.

**Gotchas**
- PK `id` is a varchar(50), not an integer identity — consistent with other Liberty tables using string/GUID-style keys.
- `UserId` has no declared or inferred FK, so the employee/user table it maps to must be confirmed manually (e.g. via a Liberty users table) before joining.
- Only 2 rows and a single observed `ShiftType` value (0) in this sample — insufficient data to characterize the full coded domain of `ShiftType` or confirm typical `EntryEdited` behavior.
- Not mirrored by ETL into liberty_link_stage, so this data is not available in the eMed warehouse; any use requires direct Liberty DB access.

---
