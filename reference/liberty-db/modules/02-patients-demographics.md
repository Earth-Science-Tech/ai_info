# Liberty schema — Patients & Demographics

The rxqPatient master and its demographic satellites — addresses, phone numbers, preferences, HIPAA acknowledgements, consultations, patient ranking, and long-term-care / nursing-home patient linkage.

> Part of the [Liberty/RxQ schema reference](../README.md). Liberty declares **no foreign-key constraints** (verified via `sys.foreign_keys`), so all relationships shown are **inferred from column naming and then data-validated** by referential match rate — each is tagged high / medium / low / no-data / unvalidated confidence. Row counts and sampled enum values are from the RXCS instance (point-in-time); the schema itself is identical across the rxcs / mmed / mdvo tenants.

**Tables in this module (10):** [`rxqPatient`](#rxqpatient) · [`rxqPatientPreferences`](#rxqpatientpreferences) · [`rxqPhoneNumber`](#rxqphonenumber) · [`rxqAddress`](#rxqaddress) · [`rxqZCode`](#rxqzcode) · [`rxqPatientHipaaAcknowledge`](#rxqpatienthipaaacknowledge) · [`rxqPatientRanking`](#rxqpatientranking) · [`rxqPatientConsultation`](#rxqpatientconsultation) · [`rxqNHPat`](#rxqnhpat) · [`rxqNHHom`](#rxqnhhom)

---

## `rxqPatient`

Rows (RXCS): 165,756 | Columns: 117 | PK: `PatientId` | ETL-mirrored into `liberty_link_stage`: yes (39 of 117 columns mirrored)

**Purpose**

Master patient-demographic table for the pharmacy system — one row per patient (`PatientId` varchar PK), holding name/DOB/gender/contact/address (primary, alternate, billing, shipping, delivery address IDs), insurance/identity numbers (SSN, driver's license, passport, Medicare Beneficiary ID/HIC), pricing/discount settings (`PriceFormula`, `Discount`, `OverTheCounterDiscount`), communication preferences (`TextingOption`, `SendRxAlertText/Email/Voice`), and clinical/consent flags (`DeceasedFlag`/`DeceasedDate`, `PregnancyIndicator`, `Breastfeeding`, `VaccineRegistryConsent`, `MedicalConditionsSwitch`). It is the central hub table referenced (by naming convention) from nearly every other clinical, financial, and workflow table in the schema — allergies, alerts, e-care plans, lab records, scripts, insurance, messaging, audit logs, etc. (inferred, from the 40+ inbound `PatientId`-named columns found across the schema). `HouseholdId`/`AccountId` (indexed via `IDX_Pat_HHID`/`IDX_Pat_AccId`) suggest grouping of patients into households/billing accounts for family/facility billing (inferred). `Rx365*` and `SalesForceReferral*` columns indicate integration with a patient-portal (Rx365) and Salesforce for referral tracking (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| LastName | varchar(50) | Y | | indexed (`IX_cPatient`) |
| FirstName | varchar(50) | Y | | |
| MiddleInitial | varchar(50) | Y | | |
| PatientId | varchar(50) | N | **PK** | |
| Street | varchar(50) | Y | | |
| City | varchar(50) | Y | | |
| State | varchar(50) | Y | | |
| Zip | varchar(50) | Y | | |
| ZipPlus | varchar(50) | Y | | |
| Phone | varchar(50) | Y | | indexed (`IX_cPatient_2`) |
| DateOfBirth | date | Y | | indexed (`IX_rxqPatient_DateOfBirth`) |
| Gender | varchar(50) | Y | | |
| SocialSecurityNumber | varchar(50) | Y | | indexed (`IX_cPatient_3`) |
| PriceFormula | varchar(50) | Y | | indexed (`IX_Patient_PriceFormula`) |
| Discount | float | Y | | |
| ChildProofTop | varchar(50) | Y | | |
| Language | varchar(50) | Y | → `rxqDirection` | |
| ProfileFrequency | varchar(50) | Y | | |
| RxCountYearToDate | int | Y | | |
| ChargeCode | varchar(50) | Y | | |
| StartDate | date | Y | | |
| LastDateUsed | date | Y | | |
| NursingHome | varchar(50) | Y | | |
| ResponsiblePartySwitch | varchar(50) | Y | | |
| Comment | nvarchar(max) | Y | | |
| CrossCheckSwitch | varchar(50) | Y | | |
| DriversLicenseNumber | varchar(50) | Y | | |
| MilitaryId | varchar(50) | Y | | |
| SmokerCode | varchar(50) | Y | | |
| PregnancyIndicator | varchar(50) | Y | | |
| EmailAddress | varchar(50) | Y | | indexed (`IX_rxqPatient_EmailAddress`) |
| HippaSwitch | varchar(50) | Y | | |
| HippaDate | date | Y | | |
| TaxCode | varchar(50) | Y | | |
| TaxExemptNumber | varchar(50) | Y | | |
| OverTheCounterDiscount | int | Y | | |
| AlternateStreet | varchar(50) | Y | | |
| AlternateCity | varchar(50) | Y | | |
| AlternateState | varchar(50) | Y | | |
| AlternateZip | varchar(50) | Y | | |
| AlternateZipPlus | varchar(50) | Y | | |
| AlternatePhone | varchar(50) | Y | | indexed (`IX_AltPhone`) |
| Suite | varchar(50) | Y | | |
| AlternateSuite | varchar(50) | Y | | |
| CountryCode | varchar(50) | Y | | |
| AlternateCountryCode | varchar(50) | Y | | |
| DeliveryDefault | varchar(50) | Y | | |
| OTCVolumeDiscount | varchar(50) | Y | | |
| LastModified | datetime | Y | | |
| IsValid | bit | Y | | all sampled rows `true` (165,756) — appears to be always-set/no soft-invalidation in use |
| FacilityChargeAccountId | varchar(50) | Y | | |
| TextingOption | char(1) | Y | | values: `O`=88,745, ` ` (blank)=55,789, `N`=21,222 |
| PhoneType | char(2) | Y | | |
| AlternatePhoneType | char(2) | Y | | |
| LastDatePOS | date | Y | | |
| InActive | bit | Y | | values: `false`=165,752, `true`=4 |
| CustomField1–4 | varchar(50) | Y | | free-form custom fields |
| UnitDose | bit | Y | | values: `false`=165,754, `true`=2 |
| GlobalId | varchar(50) | Y | | indexed (`IX_rxqPatient_GlobalId`) |
| PlaceOfService | varchar(50) | Y | | |
| PatientResidence | varchar(50) | Y | | |
| FacilityCharge | bit | Y | | |
| AddressVerified | date | Y | | |
| SalesForceReferral | varchar(75) | Y | | |
| SalesForceReferralId | varchar(50) | Y | | |
| cQueueId | int | Y | → `rxqQueue` (unconfirmed — see Relationships) | values: `0`=165,755, `3`=1 |
| HouseholdId | varchar(50) | Y | | indexed (`IDX_Pat_HHID`) |
| AccountId | varchar(50) | Y | | indexed (`IDX_Pat_AccId`) |
| Relation | varchar(1) | Y | | |
| OfficeUse | bit | Y | | |
| PassportNumber | varchar(50) | Y | | |
| AutoFill | bit | Y | | |
| RxLoyalty | bit | Y | | |
| FacilityChargeOTCOnly | bit | Y | | |
| SendRxAlertText | bit | Y | | |
| SendRxAlertEmail | bit | Y | | |
| SendRxAlertVoice | bit | Y | | |
| RxAlertVoiceType | varchar(50) | Y | | |
| MedSyncStartDate1 | datetime | Y | | |
| MedSyncDays1 | int | Y | | |
| MedSyncStartDate2 | datetime | Y | | |
| MedSyncDays2 | int | Y | | |
| PrintMonograph | bit | Y | | |
| MedicalConditionsSwitch | bit | Y | | all sampled rows `false` (165,756) |
| DeceasedFlag | bit | Y | | all sampled rows `false` (165,756) |
| DeceasedDate | date | Y | | |
| HIC | varchar(50) | Y | | Medicare Health Insurance Claim number (legacy) |
| Ranking | varchar(50) | Y | | |
| Is340B | bit | Y | | 340B drug-pricing program flag |
| MedicareBeneficiaryId | varchar(50) | Y | | |
| DeliveryAddress | bit | Y | | |
| SpeciesCode | int | Y | | values: `0`=165,729, `2`=15, `1`=9, `3`=3 — veterinary species coding (inferred) |
| VaccineRegistryConsent | bit | Y | | |
| Breastfeeding | bit | Y | | |
| Race | varchar(50) | Y | | |
| Ethnicity | varchar(50) | Y | | |
| Weight | int | Y | | |
| PrimaryAddressId | int | Y | | |
| AlternateAddressId | int | Y | | |
| BillingAddressId | int | Y | | |
| ShippingAddressId | int | Y | | |
| DeliveryAddressId | int | Y | | |
| PatientPhone1Id | int | Y | | |
| PatientPhone2Id | int | Y | | |
| RxAlertVoicePhoneId | int | Y | | |
| Rx365Id | uniqueidentifier | Y | | Rx365 patient-portal integration key (inferred) |
| Rx365LastLogin | datetime | Y | | |
| Rx365StoreNumber | varchar(50) | Y | | |
| Rx365Email | varchar(500) | Y | | |
| SupportedLanguageCode | varchar(3) | Y | | values: `""` (empty)=87,480, `NULL`=78,276 — effectively unused |
| PatientConsolidationHistoryId | uniqueidentifier | Y | | |
| LastVisitDate | date | Y | | |
| LastVisitDateImported | bit | Y | | |
| DriversLicenseState | varchar(50) | Y | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

All edges below are INFERRED from column naming and DATA-VALIDATED against actual parent-table values — not enforced/declared constraints.

- **Outbound (inferred):**
  - `Language` → `rxqDirection` — inferred, **high** confidence (100.0% referential match, not sampled).
  - `cQueueId` → `rxqQueue` — inferred, **low** confidence (0.0% referential match, not sampled); 165,760 of 165,761 non-null values are orphans, effectively meaning `cQueueId` almost never resolves to a real `rxqQueue` row on RXCS (the dominant value is `0`, likely a "no queue" sentinel rather than a true FK). Treat as unconfirmed/weak.

- **Inbound (inferred)** — `rxqPatient.PatientId` is referenced (by column-naming) from many tables. Grouped by confidence:
  - **High confidence (>=95% match):** `PrescriptionRequests.PatientId` (100.0%), `rxqEcarePlan.PatientId` (100.0%), `RxqLabPatientRecord.PatientId` (100.0%), `rxqMedicareEligibility.PatientId` (100.0%), `rxqMedicareEligibilityPayers.PatientId` (100.0%), `rxqNHPat.PatientId` (100.0%), `rxqPatientConsultation.patientId` (100.0%), `rxqPatientThirdParty.PatientId` (100.0%), `rxqPmpGatewayAudit.PatientId` (100.0%), `rxqProfileOnlyScripts.PatientId` (100.0%), `rxqScriptBase.PatientId` (100.0%), `StockReturnHistory.PatientID` (100.0%), `rxqRxAlert.PatientId` (99.99%), `rxqPatientAllergies.PatientId` (99.98%), `rxqPatientHipaaAcknowledge.PatientId` (99.92%), `rxqPatientMessage.PatientId` (98.56%), `rxqChangeLogEntry.PatientId` (98.07%), `rxqAuditLogMaster.PatientId` (97.22%), `rxqPatientDisease.PatientId` (96.0%), `rxqEScript.PatientId` (95.71%).
  - **Medium confidence (60–95% match):** `rxqTreatmentSchedule.PatientId` (88.89%), `rxqWorkFlowItem.PatientId` (60.93%).
  - **Low confidence (<60% match) — treat as weak/unconfirmed:** `rxqPendingScript.PatientId` (13.14%), `rxqParameterGeneral.PatientId` (0.0%), `rxqSMSMessage.PatientId` (0.0%), `rxqTasks.PatientId` (0.0%).
  - **No-data (parent/child empty — unvalidated):** `DrugPreference.PatientID`, `HistoricalAppointment.PatientId`, `MedSyncNotes.PatientID`, `MedSyncPatientReview.PatientId`, `PatientAuxiliary.PatientId`, `PatientConsultationNotes.PatientID`, `PatientNotes.PatientID`, `Rx365PatientAppendix.PatientId`, `RX365PatientLink.PatientId`, `rxqClinicalOppAnswer.PatientId`, `rxqInsuranceCard.PatientId`, `rxqInsuranceCardsImages.PatientId`, `rxqMTMAlert.PatientId`, `rxqNewRxRequest.PatientId`, `rxqNHMedSheetReportDefaultOrdering.PatientId`, `rxqPatientAlias.PatientId`, `rxqPatientBulkMessage.PatientId`, `rxqPatientCreditCard.PatientId`, `rxqPatientMedicalInsurance.PatientId`, `rxqQuotes.PatientId`, `rxqVideoConference.PatientId`, `rxqWorkComp.PatientId`, `rxqWorkCompPlan.PatientId`, `rxqWorkFlowMedSyncCall.PatientId`.

**Indexes**

- `PatientSearch` (NONCLUSTERED, non-unique): composite key on `PatientId, MiddleInitial, GlobalId, DriversLicenseNumber, PassportNumber, MedicareBeneficiaryId, HIC, CustomField1-4, FirstName, LastName, DateOfBirth, Phone` — primary patient-lookup/search index (name+DOB+phone+ID-number matching).
- `IX_cPatient` (`LastName`), `IX_cPatient_2` (`Phone`), `IX_cPatient_3` (`SocialSecurityNumber`) — legacy single-column search indexes, likely predating `PatientSearch`.
- `IX_rxqPatient_DateOfBirth`, `IX_rxqPatient_EmailAddress`, `IX_rxqPatient_GlobalId`, `IX_AltPhone` — targeted lookup indexes supporting DOB/email/GlobalId/alt-phone matching (e.g., duplicate-patient detection, portal linking).
- `IDX_Pat_AccId` (`AccountId`), `IDX_Pat_HHID` (`HouseholdId`) — support account/household grouping joins.
- `IX_Patient_PriceFormula` (`PriceFormula`) — supports pricing-engine joins.
- Large `_dta_index_...` composite covering index (auto-generated by SQL Server Database Tuning Advisor) keyed on `PatientId, PatientPhone2Id, PatientPhone1Id, PrimaryAddressId, NursingHome, Ranking` with many included columns — a query-tuning artifact, not a semantic join path.

**Gotchas**

- Varchar `PatientId` (not int/identity) is the PK — all downstream `PatientId` FK-style columns must match on string, so type mismatches or padding/casing differences could silently break joins.
- `cQueueId` naming implies FK to `rxqQueue` but is validated at 0% match — essentially always `0` (sentinel/"none"), not a real queue-id reference; do not treat as a working join.
- `SupportedLanguageCode` is functionally dead data on RXCS: only empty-string or NULL values across all 165,756 rows.
- `IsValid`, `MedicalConditionsSwitch`, `DeceasedFlag` are constant (single value) across all sampled rows on RXCS — low differentiation; don't assume these flags are actively used/maintained in this tenant.
- Several inbound "PatientId" columns (`rxqPendingScript`, `rxqParameterGeneral`, `rxqSMSMessage`, `rxqTasks`) have low/zero referential match — these are naming coincidences or hold non-patient sentinel values, not reliable joins; verify before using.
- Table carries multiple parallel address-reference schemes: legacy inline address fields (`Street`/`City`/`State`/`Zip`, `Alternate*`) alongside newer `*AddressId` int columns (`PrimaryAddressId`, `AlternateAddressId`, `BillingAddressId`, `ShippingAddressId`, `DeliveryAddressId`) — likely a migration to a normalized address table in progress (inferred); both may or may not be kept in sync.
- SSN, driver's license, passport, and Medicare Beneficiary ID are all stored in plaintext varchar columns on this table — high-sensitivity PII/PHI co-located with routine demographic data.

---

## `rxqPatientPreferences`

Rows (RXCS): 171,540 | Columns: 5 | PK: (`LookUpId`, `PreferenceType`, `Preference`) | ETL-mirrored into `liberty_link_stage`: no

**Purpose**

Stores a keyed set of patient preference entries — a `LookUpId` (generic entity key, name suggests polymorphic/multi-entity lookup rather than a strict `PatientId` FK) paired with a `PreferenceType` code and a `Preference` value string, timestamped by `LastModified` (inferred). No lookup-domain values were sampled for `PreferenceType`, so the concrete preference categories (e.g., delivery method, communication channel, language) cannot be enumerated from this metadata alone (inferred, unconfirmed). The generic `LookUpId` naming and its low-confidence inbound matches from `rxqPhoneNumber`, `rxqAddress`, and `rxqEScriptResponseTime` suggest this table is part of a shared "LookUpId" keying scheme used across several Liberty tables rather than being patient-specific exclusively (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `cPatientPreferencesId` | int | NOT NULL | | identity (auto-increment surrogate key, not part of PK) |
| `LookUpId` | varchar(50) | NOT NULL | PK | part of composite PK; no declared/inferred outbound FK target resolved |
| `PreferenceType` | int | NOT NULL | PK | part of composite PK; no sampled lookup values available |
| `Preference` | varchar(50) | NOT NULL | PK | part of composite PK; free-text/coded preference value, no sampled lookup values available |
| `LastModified` | datetime | NULL | | last-update timestamp (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none.
- **Inbound (inferred):**
  - `rxqEScriptResponseTime.LookUpId` → this table's `LookUpId` — inferred, **low** confidence (50.0% referential match)
  - `rxqPhoneNumber.LookUpId` → this table's `LookUpId` — inferred, **low** confidence (37.2% referential match)
  - `rxqAddress.LookUpId` → this table's `LookUpId` — inferred, **low** confidence (32.7% referential match)
  - `BillingEvents.LookUpId` → this table's `LookUpId` — inferred, **no-data** confidence (match rate not computable, parent/child empty or uncheckable)
  - `rxqAuditLogMaster.cPatientPreferencesId` → this table's `cPatientPreferencesId` — inferred, **low** confidence (0.0% referential match)
  - `rxqPrintableAttachment.LookupId` → this table's `LookUpId` — inferred, **unvalidated** (parent empty or type mismatch)

All inbound edges are weak/unconfirmed guesses based on column-name matching (`LookUpId`/`cPatientPreferencesId` are generic/reused names across Liberty tables) and should not be treated as confirmed joins — the low match rates (0–50%) indicate `LookUpId` is very likely a shared generic key column used with different semantics/entity scopes across tables, not a dedicated FK to this specific table.

**Indexes**

None reported (empty `indexes` array in metadata) — no declared indexes beyond the implicit PK constraint.

**Gotchas**

- Composite varchar+int PK (`LookUpId`, `PreferenceType`, `Preference`) — no numeric surrogate key is used for lookups/joins despite `cPatientPreferencesId` existing as an identity column; that identity column is NOT part of the PK and its only observed consumer (`rxqAuditLogMaster`) has a 0% match rate, suggesting it's rarely/never actually used as a join key.
- `LookUpId` is a generic, ambiguously-scoped key name reused across many unrelated Liberty tables (`rxqPhoneNumber`, `rxqAddress`, `rxqEScriptResponseTime`, `BillingEvents`, `rxqPrintableAttachment`) — none of the inbound matches clear medium/high confidence, so do not assume any of these tables reliably reference `rxqPatientPreferences` specifically; `LookUpId` may key off a different parent entity per table.
- No lookup-domain values were sampled for `PreferenceType` or `Preference`, so their coded meanings are unknown from this extract — do not infer specific preference categories without checking the live data.
- Not mirrored by ETL into `liberty_link_stage`, so this data is unavailable to eMed application code/reporting without a direct Liberty-side query.

---

## `rxqPhoneNumber`

Rows (RXCS): 358,479 | Columns: 5 | PK: `cPhoneNumberId` | ETL-mirrored into liberty_link_stage: no

**Purpose** — Stores individual phone number records (`PhoneNumber`, coded `PhoneNumberType`) keyed by an identity `cPhoneNumberId`, with a `LookUpId` string linking each number back to an owning entity and a `LastModified` audit timestamp. `LookUpId` weakly resembles the key used by `rxqPatientPreferences` but only ~37% of values match that table (inferred), suggesting `LookUpId` is a generic polymorphic lookup key shared across multiple owner types (e.g. patients, prescribers, facilities) rather than a dedicated FK to one table (inferred). `rxqAuditLogMaster` references `cPhoneNumberId` with a 100% match, indicating phone number changes are tracked in the system-wide audit log (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cPhoneNumberId | int | NO | PK | identity |
| LookUpId | varchar(200) | YES | → rxqPatientPreferences (weak) | polymorphic-looking lookup key (inferred); low-confidence match to rxqPatientPreferences |
| PhoneNumberType | int | YES | | coded type; no sampled values available (lookups empty) |
| PhoneNumber | varchar(50) | YES | | raw phone number string |
| LastModified | datetime | YES | | audit/update timestamp |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**
  - `LookUpId` → `rxqPatientPreferences` — inferred, **low** confidence (37.2% referential match, sampled; 125,694 of 200,000 non-null values are orphans). Weak/unconfirmed edge — `LookUpId` likely serves as a generic polymorphic key rather than a dedicated link to this one table.
- **Inbound (inferred)**
  - `rxqAuditLogMaster.cPhoneNumberId` → this table — inferred, **high** confidence (100.0% referential match).

**Indexes**
- `LibertyAuto_15_14_rxqPhoneNumber` (NONCLUSTERED, non-unique) on `LookUpId` — supports lookup of phone numbers by owning entity's key.

**Gotchas**
- `LookUpId` is a varchar(200) key, not a typed FK column, and its low match rate against `rxqPatientPreferences` (37%) strongly suggests it's a shared/polymorphic identifier reused across several owner tables in Liberty — treat any single-table join on it as unconfirmed without further validation.
- `PhoneNumberType` is coded but no sample values were captured (lookups empty), so its domain (e.g. home/work/mobile/fax) is undocumented here.
- Not mirrored by ETL into liberty_link_stage — eMed application code cannot query this table directly via the standard mirror; any phone-number needs must go through whatever mirrored table already carries contact info, or a new ETL mapping would be required.

---

## `rxqAddress`

Rows (RXCS): 341,175 | Columns: 12 | PK: `cAddressId` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores discrete postal addresses (Street/City/State/Zip/ZipPlus/Suite/CountryCode) as freestanding rows keyed by an identity `cAddressId`, with a free-text `Notes` field and a `LastModified` audit timestamp. `AddressType` (int, no lookup values sampled) suggests each row is tagged with a category — e.g. shipping vs. billing vs. prescriber (inferred), but the coded domain is not confirmed by data. The presence of `LookUpId` (varchar) hints this table is used as a shared, generic address store referenced by other entities via a lookup-key indirection rather than a typed FK (inferred). It is heavily referenced from the audit subsystem (`rxqAuditLogMaster`), consistent with a role as the canonical address record whose changes are tracked for compliance (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cAddressId | int | no | PK | identity |
| LookUpId | varchar(200) | yes | → rxqPatientPreferences (weak, see below) | |
| AddressType | int | yes | | no sampled lookup values available |
| Street | varchar(200) | yes | | |
| City | varchar(200) | yes | | |
| State | varchar(200) | yes | | |
| Zip | varchar(200) | yes | | |
| ZipPlus | varchar(200) | yes | | |
| Suite | varchar(200) | yes | | |
| CountryCode | varchar(200) | yes | | |
| Notes | varchar(200) | yes | | free text |
| LastModified | datetime | yes | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

These are all INFERRED from column naming and then DATA-VALIDATED against actual values — not declared constraints.

- **Outbound (inferred)**
  - `LookUpId` → `rxqPatientPreferences` — inferred, **low** confidence (32.65% referential match, 200,000 non-null values sampled, 134,695 orphans; sampled). Weak/unconfirmed — likely `LookUpId` is a generic keying scheme shared across multiple unrelated tables rather than a dedicated FK to `rxqPatientPreferences` specifically.

- **Inbound (inferred)**
  - `rxqAuditLogMaster.cAddressId` → this table — inferred, **high** confidence (99.83% referential match). Indicates `rxqAuditLogMaster` logs changes/events keyed to specific address records, supporting an audit-trail role for `rxqAddress`.

**Indexes**

- `rxqAddress_LookUpId` (NONCLUSTERED, non-unique) on `LookUpId` — supports lookups/joins via the `LookUpId` indirection column, reinforcing that it is the primary access path into this table (beyond the PK).

**Gotchas**

- `LookUpId` is a varchar, not the typed int PK — a generic cross-table keying convention that here matches poorly (32.65%) against `rxqPatientPreferences`, suggesting it's a shared/multi-purpose lookup key rather than a clean FK; do not assume it uniquely identifies a patient-preferences row.
- No `lookups` were sampled for `AddressType`, so its coded meaning (e.g., home/shipping/billing/prescriber) is unknown and should not be inferred without further data.
- Despite storing PHI-adjacent data (street/city/state/zip), this table is NOT mirrored by ETL into liberty_link_stage — consumers needing address data must go through Liberty directly or another mirrored path.
- High row count (341K) relative to typical patient counts implies either multiple addresses per entity (home/shipping/prescriber) or accumulation of historical/superseded address rows — audit-trail usage from `rxqAuditLogMaster` supports the latter (inferred).

---

## `rxqZCode`

Rows: 42,069 (RXCS) · Columns: 7 · PK: `ZipCode` · ETL-mirrored into `liberty_link_stage`: no

**Purpose**
A static US ZIP-code reference/lookup table (ZipCode → CityName, StateAbbr, AreaCode). It appears to serve as a shared geographic lookup used elsewhere in Liberty to validate or resolve addresses/phone-area associations (inferred). `rxqMedicareEligibility.ZipCode` matches this table's key with 100% referential integrity, consistent with its use as a canonical ZIP reference during Medicare eligibility processing (inferred). All 42,069 sampled rows have `IsValid = true`, suggesting `IsValid` is a soft-delete/active flag for pruning stale ZIP entries rather than an operational status (inferred). Not mirrored by ETL into eMed, so eMed-side reporting cannot join directly to this table.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cZCodeId | int | NOT NULL | | identity (surrogate row id, not the declared PK) |
| ZipCode | char(5) | NOT NULL | PK | 5-digit ZIP code, table's business key |
| CityName | varchar(64) | NULL | | city name for the ZIP |
| StateAbbr | char(2) | NULL | | 2-letter state abbreviation |
| AreaCode | char(3) | NULL | | telephone area code associated with the ZIP |
| LastModified | datetime | NULL | | last-updated timestamp for the row |
| IsValid | bit | NULL | | sampled values: `true` = 42,069 (100% of sampled rows) — no `false` observed, so likely an active/soft-delete flag (inferred) |

**Relationships**
Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none.
- **Inbound (inferred)** — all edges below are inferred from column naming (`ZipCode`) and DATA-VALIDATED against actual values, not declared constraints:
  - `rxqMedicareEligibility.ZipCode` → `rxqZCode` — inferred, **high** confidence (100.0% referential match)
  - `rxqPatientCreditCard.ZipCode` → `rxqZCode` — inferred, **no-data** confidence (parent/child had no data to validate; unconfirmed/weak guess)
  - `rxqWorkCompLawyer.ZipCode` → `rxqZCode` — inferred, **no-data** confidence (parent/child had no data to validate; unconfirmed/weak guess)

**Indexes**
None reported (empty index list — no declared indexes beyond the implicit PK constraint on `ZipCode`, if one exists at the storage level).

**Gotchas**
- PK is `ZipCode` (char(5)), not the identity column `cZCodeId` — joins from other tables should use `ZipCode`, not `cZCodeId`.
- Table is not ETL-mirrored, so any eMed-side ZIP/city/state/area-code enrichment must either replicate this table separately or rely on an external ZIP reference source.
- `IsValid` shows only `true` in the sample; treat any `false`/NULL rows (if they exist beyond the sample) as unvalidated/inactive ZIPs — don't assume the column is inert.
- Two of the three inbound inferred edges (`rxqPatientCreditCard`, `rxqWorkCompLawyer`) are `no-data`/unconfirmed — do not treat them as verified join paths without re-checking against live data.

---

## `rxqPatientHipaaAcknowledge`

Rows (RXCS): 67,745 | Columns: 8 | PK: `cPatientHipaaAcknowledgeId` | ETL-mirrored into liberty_link_stage: no

**Purpose** — Stores per-patient, per-store HIPAA Notice of Privacy Practices acknowledgment records: whether/when a patient acknowledged (`Acknowledged`, `AcknowledgeDate`), an optional captured `Signature`, and a `CurrentStatus` code tracking the acknowledgment's lifecycle state (inferred). One row per patient acknowledgment event at a given `StoreNumber`, supporting one patient having multiple acknowledgments across stores/visits (inferred, from the composite non-unique index on `PatientId`+`StoreNumber`+`AcknowledgeDate`). Not mirrored to the eMed ETL, so eMed has no visibility into HIPAA acknowledgment status.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cPatientHipaaAcknowledgeId | int | NO | PK | identity |
| PatientId | varchar(50) | NO | → rxqPatient | |
| StoreNumber | varchar(50) | NO | | pharmacy store/location identifier |
| AcknowledgeDate | datetime | NO | | |
| LastModified | datetime | YES | | |
| Acknowledged | bit | YES | | |
| Signature | varchar(max) | YES | | captured signature data/blob |
| CurrentStatus | int | YES | | coded status: `1` (58,350), `0` (9,335), `3` (37), `2` (23) — meanings not labeled in source |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- Outbound (inferred):
  - `PatientId` → `rxqPatient` — inferred, **high** confidence (99.9% referential match, not sampled).

- Inbound (inferred):
  - `rxqAuditLogMaster.cPatientHipaaAcknowledgeId` → this table — inferred, **high** confidence (97.1% referential match).

These edges are inferred from column naming and data-validated against actual key values, not declared database constraints; treat anything below high confidence as an unconfirmed guess (not applicable here — the one outbound and one inbound edge are both high confidence).

**Indexes**

- `rxqPatientHipaaAcknowledge_PatientIdStoreNumberAcknowledgeDate` (NONCLUSTERED, non-unique) on (`PatientId`, `StoreNumber`, `AcknowledgeDate`) — primary lookup path for a patient's acknowledgment history at a given store, ordered/filterable by date.

**Gotchas**

- `PatientId` and `StoreNumber` are varchar(50) despite being identifier-like — typical Liberty pattern, join carefully on type/format.
- 53 `PatientId` values (0.08%) are orphans against `rxqPatient` — small but nonzero referential gap.
- `CurrentStatus` codes (0/1/2/3) have no documented labels in this metadata; `1` dominates (~86%) and likely represents the terminal/normal "acknowledged" state (inferred), but this is unconfirmed.
- Row is separately audited via `rxqAuditLogMaster` (97.1% inbound match), implying HIPAA acknowledgment changes are logged for compliance purposes (inferred).
- Not ETL-mirrored: any eMed feature needing HIPAA-acknowledgment status must query Liberty directly or request mirroring.

---

## `rxqPatientRanking`

Rows (RXCS): 9 | Columns: 8 | PK: `cPatientRankingId` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Small reference/lookup table defining a tiered ranking scheme for patients, keyed by a `RankType`/`Rank` pair (unique together per the index) with a `Name` label, an `Image` code, and `High`/`Low` bounds — likely a numeric threshold band (e.g. spend, adherence score, or refill count) that maps into a named rank tier (inferred). `RankType` has two observed values (0 and 1), suggesting two distinct ranking dimensions/schemes each with their own set of tiers (inferred). With only 9 rows this is a static configuration table, not transactional data, and it carries no declared or inferred link to `rxqPatient` or any other table in this dataset — its relationship to actual patient records (if any) is not evidenced here.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cPatientRankingId | int | NO | PK | identity |
| RankType | int | YES | | part of unique index `IX_rxqPatientRanking`; sampled values: `0` (5), `1` (4) |
| Rank | int | YES | | part of unique index `IX_rxqPatientRanking` |
| Name | varchar(50) | YES | | label for the rank tier (inferred) |
| Image | int | YES | | likely an icon/image reference code (inferred) |
| High | int | YES | | upper bound of a threshold band (inferred) |
| Low | int | YES | | lower bound of a threshold band (inferred) |
| LastModified | datetime | YES | | audit timestamp |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

No naming-based candidate columns were detected pointing into or out of this table; despite the "Patient" in its name, there is no inferred edge to `rxqPatient` or any patient-identifying table in the extracted metadata.

**Indexes**

- `IX_rxqPatientRanking` (UNIQUE, NONCLUSTERED) on (`RankType`, `Rank`) — enforces one row per rank position within a ranking scheme; the natural lookup key for resolving a patient's rank code to its `Name`/`Image`/threshold band.

**Gotchas**

- Name suggests a per-patient relationship, but no FK-like column (e.g. `PatientId`) exists on this table — it is purely a rank-tier definition table, not a patient-to-rank assignment table; the assignment likely lives elsewhere (not present in this extract).
- Not ETL-mirrored to liberty_link_stage — unavailable to eMed-side reporting/queries without a direct Liberty DB pull.
- `High`/`Low`/`Image` semantics are unconfirmed (no lookups sampled for them) — treat as inferred only.

---

## `rxqPatientConsultation`

Rows (RXCS): 1 · Columns: 9 · PK: `id` · ETL-mirrored into liberty_link_stage: no

**Purpose** — Stores a per-patient counseling/consultation record: a `patientId` link, `consultationDate` / `ConsultationCompletedDate` timestamps, free-text `notes`, the counseling pharmacist's `rphInitials`, an `IsActive` flag, and store/ticket identifiers (`StoreNumber`, `TicketNumber`). (Inferred) This looks like the pharmacist patient-consultation/counseling log required for new-Rx or clinical-review workflows (NCPDP-style counseling documentation), scoped per store location and tied to a specific fill/ticket. Row count of 1 means the sampled values reflect a single record only — treat as illustrative, not representative.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `id` | nvarchar(50) | NO | PK | |
| `patientId` | nvarchar(50) | YES | → `rxqPatient` | |
| `consultationDate` | datetime | YES | | indexed (`indexDatePatientConsultation`) |
| `notes` | nvarchar(max) | YES | | free text |
| `rphInitials` | nvarchar(50) | YES | | pharmacist initials, presumably free text |
| `IsActive` | bit | YES | | sampled values: `true` (count 1) |
| `TicketNumber` | nvarchar(50) | YES | | |
| `StoreNumber` | nvarchar(50) | YES | | indexed (`storeIndexPatientConsultation`) |
| `ConsultationCompletedDate` | datetime | YES | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**:
  - `patientId` → `rxqPatient` (join col `PatientId`) — inferred, **high** confidence (100.0% referential match, not sampled).
- **Inbound (inferred)**: none.

These edges are inferred purely from column naming plus data validation against actual values in the parent table — not enforced database constraints.

**Indexes**
- `indexDatePatientConsultation` (NONCLUSTERED, non-unique) on `consultationDate` — supports date-range lookups of consultations.
- `storeIndexPatientConsultation` (NONCLUSTERED, non-unique) on `StoreNumber` — supports per-store filtering.

**Gotchas**
- All key/identifier columns (`id`, `patientId`, `TicketNumber`, `StoreNumber`) are `nvarchar`, not integer, consistent with Liberty's general pattern of string-typed surrogate keys.
- Table currently has only 1 row in RXCS — low confidence that sampled `IsActive` value (`true`) represents the full domain; do not assume it's the only valid value (e.g., `false`/`0` likely also valid for inactive/voided consultations).
- No inbound references were found from any other table to this one — it appears to be a leaf/terminal table in the inferred graph (at least among tables scanned).
- Not ETL-mirrored to liberty_link_stage, so this data is not available to eMed via the standard mirror; any consumption would require a direct Liberty-side query or a new ETL addition.

---

## `rxqNHPat`

Rows (RXCS): 2 · Columns: 69 · PK: `NH`, `PatientLastName`, `PatientFirstName`, `PatientMiddleI`, `PatientId` (composite) · ETL-mirrored into `liberty_link_stage`: no

**Purpose**

Stores nursing-home (NH/LTC facility) admission and census records for patients, layering long-term-care-specific data (station/room/bed assignment, admit/release/discharge dates split into MM/DD/YY, deceased flag, leave-of-absence tracking, primary/secondary attending physician, standing orders, and free-text comments) on top of the core patient record (inferred — column names like `RoomNumber`/`BedNumber`/`AdmitMM`/`ReleaseDD`/`LtcVendor` are typical NCPDP/LTC pharmacy fields for facility census management, not general retail-pharmacy data). It links to a patient via `PatientId` (high-confidence match to `rxqPatient`) and is itself keyed additionally by the facility identifier `NH`, meaning a single patient can have one row per nursing home. The 32 numbered `StandingOrders1`-`StandingOrders32` columns (inferred) likely encode a fixed slate of facility standing-order flags/codes per admission. Only 2 rows exist in the RXCS sample, suggesting this table is lightly used or scoped to a small subset of NH-affiliated patients/facilities.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cNHPatId | int | NO | | identity |
| RawData | varchar(50) | YES | | |
| ErrCode | varchar(50) | YES | | |
| NH | varchar(50) | NO | PK | facility/nursing-home identifier |
| PatientLastName | varchar(50) | NO | PK | |
| PatientFirstName | varchar(50) | NO | PK | |
| PatientMiddleI | varchar(50) | NO | PK | |
| PatientId | varchar(50) | NO | PK, → rxqPatient | |
| StationNumber | varchar(50) | YES | | |
| RoomNumber | varchar(50) | YES | | |
| BedNumber | varchar(50) | YES | | |
| AdmitMM | varchar(50) | YES | | admit month |
| AdmitDD | varchar(50) | YES | | admit day |
| AdmitYY | varchar(50) | YES | | admit year |
| ReleaseMM | varchar(50) | YES | | release month |
| ReleaseDD | varchar(50) | YES | | release day |
| ReleaseYY | varchar(50) | YES | | release year |
| Deceased | varchar(50) | YES | | |
| PriDocPre | varchar(50) | YES | | primary doctor prefix/ID (inferred) |
| PriDocSuf | int | YES | | primary doctor suffix/ID (inferred) |
| SecDocPre | varchar(50) | YES | | secondary doctor prefix/ID (inferred) |
| SecDocSuf | int | YES | | secondary doctor suffix/ID (inferred) |
| StandingOrders1 ... StandingOrders32 | varchar(50) | YES | | 32 repeated columns, standing-order slate per admission (inferred) |
| Comment1 | varchar(200) | YES | | |
| Comment2 | varchar(200) | YES | | |
| Comment3 | varchar(200) | YES | | |
| AdmissionNumber | varchar(50) | YES | | |
| LastModified | datetime | YES | | |
| IsValid | bit | YES | | sampled values: `true` (2) |
| ExcludeOrdersFromMedSheet | varchar(50) | YES | | |
| AdmitStatus | int | YES | | sampled values: `NULL` (2) |
| DischargeType | int | YES | | sampled values: `NULL` (2) |
| LeaveOfAbsence | date | YES | | |
| LeaveOfAbsenceReason | int | YES | | |
| ExpectedReturn | date | YES | | |
| Inactive | bit | YES | | sampled values: `false` (2) |
| InactiveStatus | int | YES | | sampled values: `NULL` (2) |
| LtcVendor | int | YES | | long-term-care vendor code (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**
  - `PatientId` → `rxqPatient` (join on `PatientId`) — inferred, **high** confidence (100.0% referential match, not sampled — checked against full data)

- **Inbound (inferred)**
  - `rxqAuditLogMaster.cNHPatId` → this table — inferred, **high** confidence (100.0% referential match)
  - `rxqMTMAlert.PatientFirstName` → this table — inferred, **no-data** confidence (no match_rate available; likely `rxqMTMAlert` is empty or the join couldn't be validated)
  - `rxqMTMAlert.PatientLastName` → this table — inferred, **no-data** confidence (no match_rate available; same caveat)

**Indexes**

None reported (empty index list).

**Gotchas**

- Composite 5-part varchar primary key (`NH` + name parts + `PatientId`) rather than the identity `cNHPatId` — joins/lookups by name fields are fragile (case/whitespace sensitivity typical of varchar keys).
- Dates are stored as three separate varchar/int-like MM/DD/YY columns (`AdmitMM`/`AdmitDD`/`AdmitYY`, `ReleaseMM`/`ReleaseDD`/`ReleaseYY`) rather than native date types, unlike `LeaveOfAbsence`/`ExpectedReturn` which are proper `date` columns — inconsistent date modeling within the same table.
- 32 near-identical `StandingOrdersN` columns is a denormalized repeating-group pattern; no lookup data sampled to confirm their coded domain.
- Only 2 rows in RXCS and no rows/insufficient data in the referencing `rxqMTMAlert` table, so the `PatientFirstName`/`PatientLastName` inbound edges are unconfirmed guesses, not validated relationships.
- Not mirrored by ETL into `liberty_link_stage`, so this NH/LTC data is not available in the eMed application layer.

---

## `rxqNHHom`

Rows: 4 (RXCS) · Columns: 236 · PK: `ID` (varchar(50)) · ETL-mirrored into `liberty_link_stage`: no

**Purpose**

Stores facility/institutional-pharmacy ("nursing home" — NHHom = NH Home/Facility) master records: one row per long-term-care facility, holding its address (`Street`/`StreetAdd`/`City`/`State`/`Zip`/`ZipB`/`County`), contact info (`Phone`/`Fax`/`ContactName`/`NPI`), certification/print settings (`Certification`, `CertificationLine1/2`, `PrintPRN`), and an extensive bank of per-cycle scheduling slots (`StandingOrders1`–`32`, `TreatmentScheduleCode1`–`18`, and `Schedule11`–`818` covering 8 schedule groups × up to 18 slots each) used to drive facility cycle-fill dosing/delivery calendars (inferred — the `FacilityCycleFillStart`/`FacilityCycleFillDays`/`FacilityCycleFillWorkflowDays`/`FacilityFillProgram`/`CycleOfTheMonthRecurrenceData` columns support this). Also carries HL7/interface config for facility-bound electronic messaging (`HL7InterfaceId`, `InterfaceType`, `SendTrigger`) and per-facility workflow toggles (`ShowInLTCModule`, `ShowFacilityOptionsInScriptScreen`, `GroupPatients`/`GroupPatientsBy`, `OverridePatientAddresses`, `PaymentRequired`, `RequireTQ`, `PrintPatientEducationDocuments`, `EnablePatientMPPPNotifications`). Only 4 rows exist in RXCS, i.e. this is a small institutional/LTC-facility configuration table, not a high-volume transactional one (inferred). No FK constraints or naming-inferable relationships were detected/validated to other tables in this extract.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cNHHomId | int | NOT NULL | | identity |
| RawData | varchar(50) | NULL | | |
| ErrCode | varchar(50) | NULL | | |
| ID | varchar(50) | NOT NULL | PK | |
| Street | varchar(50) | NULL | | |
| StreetAdd | varchar(50) | NULL | | |
| Certification | varchar(50) | NULL | | |
| City | varchar(50) | NULL | | |
| State | varchar(50) | NULL | | |
| Zip | varchar(50) | NULL | | |
| ZipB | varchar(50) | NULL | | |
| County | varchar(50) | NULL | | |
| Phone | varchar(50) | NULL | | |
| Fax | varchar(50) | NULL | | |
| PrintPRN | varchar(50) | NULL | | |
| StandingOrders1–32 (32 cols) | varchar(50) | NULL | | repeating slot group, facility standing-order codes per cycle position (inferred) |
| CertificationLine1 | varchar(80) | NULL | | |
| CertificationLine2 | varchar(80) | NULL | | |
| SortLine | int | NULL | | |
| TreatmentScheduleCode1–18 (18 cols) | varchar(50) | NULL | | repeating slot group, treatment-schedule codes (inferred) |
| Schedule11–118 (18 cols) | varchar(50) | NULL | | schedule group 1, slots 1–18 |
| Schedule21–218 (18 cols) | varchar(50) | NULL | | schedule group 2, slots 1–18 |
| Schedule31–318 (18 cols) | varchar(50) | NULL | | schedule group 3, slots 1–18 |
| Schedule41–418 (18 cols) | varchar(50) | NULL | | schedule group 4, slots 1–18 |
| Schedule51–518 (18 cols) | varchar(50) | NULL | | schedule group 5, slots 1–18 |
| Schedule61–618 (18 cols) | varchar(50) | NULL | | schedule group 6, slots 1–18 |
| Schedule71–718 (18 cols) | varchar(50) | NULL | | schedule group 7, slots 1–18 |
| Schedule81–818 (18 cols) | varchar(50) | NULL | | schedule group 8, slots 1–18 |
| LastModified | datetime | NULL | | |
| IsValid | bit | NULL | | sampled: `true` (4/4) |
| FacilityId | varchar(50) | NULL | | likely facility identifier (inferred; not validated as a ref — no inferred_relationships recorded) |
| HL7InterfaceId | int | NULL | | |
| FacilityCycleFillStart | date | NULL | | |
| FacilityCycleFillDays | int | NULL | | |
| FacilityCycleFillWorkflowDays | int | NULL | | |
| FacilityFillProgram | int | NULL | | |
| CycleOfTheMonthRecurrenceData | varchar(max) | NULL | | |
| PrimaryAddressId | int | NULL | | |
| ShowInLTCModule | bit | NULL | | |
| ShowFacilityOptionsInScriptScreen | bit | NULL | | sampled: `true` (3), `false` (1) |
| ContactName | varchar(50) | NULL | | |
| NPI | varchar(15) | NULL | | |
| PrintPatientEducationDocuments | bit | NOT NULL | | |
| EnablePatientMPPPNotifications | bit | NOT NULL | | |
| InterfaceType | int | NOT NULL | | sampled: `0` (4/4) |
| SendTrigger | int | NOT NULL | | |
| GroupPatients | bit | NULL | | |
| GroupPatientsBy | tinyint | NULL | | |
| OverridePatientAddresses | bit | NULL | | |
| PaymentRequired | bit | NULL | | |
| DeliveryInstructions | varchar(250) | NULL | | |
| RequireTQ | bit | NULL | | |

Note: the repeating `StandingOrdersN`, `TreatmentScheduleCodeN`, and `ScheduleG-N` columns (32 + 18 + 8×18 = 194 of the table's 236 columns) are enumerated as groups above rather than one row each, for density; each individual column shares the same type/nullability/notes shown.

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no naming-inferable, data-validated outbound edges were detected from this table (empty `inferred_relationships`). `FacilityId`/`PrimaryAddressId`/`HL7InterfaceId` look like they should reference other Liberty tables by naming convention, but no such edge was inferred/validated in this extract — treat any such link as an unconfirmed guess.
- **Inbound (inferred):** none — no other table was found to reference `rxqNHHom` by naming convention in this extract (empty `inferred_referenced_by`).

**Indexes**

None reported (empty `indexes[]` — no non-default indexes surfaced beyond the PK constraint on `ID`).

**Gotchas**

- Varchar(50) primary key (`ID`) rather than the identity `cNHHomId`, which is instead a separate auto-increment column not used as the key — classic Liberty dual-key pattern (surrogate identity + string business key).
- Only 4 rows in RXCS — this is a low-cardinality configuration table (per-facility setup), not a high-volume operational table; row counts/sample values are point-in-time and may look sparse for that reason.
- 194 of 236 columns are flat repeating slot groups (`StandingOrdersN`, `TreatmentScheduleCodeN`, `ScheduleG-N` for G=1..8, N=1..18) rather than a normalized child table — a classic wide/denormalized Liberty design; any consumer needing per-slot detail must pivot these manually.
- `RawData`/`ErrCode` suggest this table (or its row-population path) may double as an interface/import staging artifact in addition to being the live facility master — treat with caution before assuming every row is a "real" configured facility.
- No inferred relationships at all (in or out) despite several column names (`FacilityId`, `PrimaryAddressId`, `HL7InterfaceId`) that strongly suggest FK-like references — likely because parent tables weren't in this extract or matched data too poorly/were empty; don't assume these are unrelated, just unconfirmed.

---
