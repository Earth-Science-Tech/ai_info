# Liberty schema — Insurance, Claims, NCPDP, AR & Billing

Third-party insurance and Medicare eligibility, NCPDP payer/agency configuration and claim formats, accounts receivable, and the drug pricing / cost-basis layer (NADAC, MFP, price formulas and update history).

> Part of the [Liberty/RxQ schema reference](../README.md). Liberty declares **no foreign-key constraints** (verified via `sys.foreign_keys`), so all relationships shown are **inferred from column naming and then data-validated** by referential match rate — each is tagged high / medium / low / no-data / unvalidated confidence. Row counts and sampled enum values are from the RXCS instance (point-in-time); the schema itself is identical across the rxcs / mmed / mdvo tenants.

**Tables in this module (17):** [`rxqPatientThirdParty`](#rxqpatientthirdparty) · [`rxqMedicareEligibility`](#rxqmedicareeligibility) · [`rxqMedicareEligibilityPayers`](#rxqmedicareeligibilitypayers) · [`rxqNCPDP`](#rxqncpdp) · [`rxqNcpdpCodes`](#rxqncpdpcodes) · [`rxqNcpdpOnlineHistory`](#rxqncpdponlinehistory) · [`RxqAgencyNcpdpFormat`](#rxqagencyncpdpformat) · [`rxqAgency`](#rxqagency) · [`rxqAgencyStore`](#rxqagencystore) · [`rxqAccountReceivable`](#rxqaccountreceivable) · [`rxqPatientAccountReceivable`](#rxqpatientaccountreceivable) · [`rxqMFP`](#rxqmfp) · [`rxqDrugPricingHistory`](#rxqdrugpricinghistory) · [`rxqPriceUpdateHistory`](#rxqpriceupdatehistory) · [`rxqPriceUpdateSettings`](#rxqpriceupdatesettings) · [`rxqPriceFormula`](#rxqpriceformula) · [`rxqNADACAverageAcq`](#rxqnadacaverageacq)

---

## `rxqPatientThirdParty`

Rows: 2 (RXCS) · Columns: 46 · PK: `PatientId, AgencyCode, AgencySequence` · ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores per-patient third-party (insurance/payer) plan enrollment records — one row per patient per payer "agency" per coverage sequence, carrying cardholder identity, group/PCN/BIN-style plan identifiers, coverage limits (`DollarLimit`, `DollarMonthToDate`, `ScriptCount`), coverage window (`LastUsed`, `CoverageEnd`), and NCPDP-style adjudication flags (`OtherCoverageCode`, `PatientAssignmentIndicator`, `ProviderAcceptsAssignment`, `MedicaidIndicator`, `Medigap`) (inferred: field names align with NCPDP telecom/billing segment fields used for claims adjudication). `AgencySequence` is referenced heavily by claim/transaction-level tables (`rxqScriptTransaction`, `rxqInsuranceCard`, `rxqOnlineHistory`, `rxqScriptPayments`), indicating this table is the patient-plan registry that downstream billing/claims records point back to when identifying which payer plan a fill was adjudicated against (inferred). `DefaultAgencySwitch` suggests one row per patient can be flagged as the default/primary payer (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cPatientThirdPartyId | int | NO | | identity |
| PatientId | varchar(50) | NO | PK, → rxqPatient | |
| AgencyCode | varchar(50) | NO | PK | payer/agency code |
| AgencyIdentification | varchar(50) | YES | | |
| GroupNumber | varchar(50) | YES | | |
| CardHolderNumber | varchar(50) | YES | | |
| PersonNumber | varchar(50) | YES | | |
| ScriptCount | int | YES | | |
| DollarLimit | float | YES | | |
| DollarMonthToDate | float | YES | | |
| CopayCode | varchar(50) | YES | | |
| OtherCoverageCode | int | YES | | sampled: `0` (count 2) |
| PriorCode | int | YES | | sampled: `0` (count 2) |
| PriorAuthorizationNumber | numeric(18,0) | YES | | |
| CardHolderLastName | varchar(50) | YES | | |
| CardHolderFirstName | varchar(50) | YES | | |
| CardHolderMiddleInitial | varchar(50) | YES | | |
| DefaultAgencySwitch | varchar(50) | YES | | |
| EmployerIdentification | varchar(50) | YES | | |
| OtherIdentification | varchar(50) | YES | | |
| PlanIdentification | varchar(50) | YES | | |
| FacilityIdentification | varchar(50) | YES | | |
| HomePlan | varchar(50) | YES | | |
| PcpDoctorIdentification | varchar(50) | YES | | indexed |
| PatientLocation | varchar(50) | YES | | |
| PcnOverride | varchar(50) | YES | | |
| REC_LEN | int | YES | | |
| LastModified | datetime | YES | | |
| IsValid | bit | YES | | sampled: `true` (count 2) |
| InactiveSwitch | char(1) | YES | | sampled: `Y` (1), `N` (1) |
| LastUsed | date | YES | | |
| CoverageEnd | date | YES | | |
| PatientAssignmentIndicator | char(1) | NO | | |
| ProviderAcceptsAssignment | char(1) | NO | | |
| QualifiedFacility | char(1) | NO | | |
| Medigap | char(20) | NO | | |
| MedicaidIndicator | char(2) | NO | | sampled: `"  "` (blank, count 2) |
| MedicaidId | varchar(20) | NO | | |
| Comment | varchar(500) | YES | | |
| DOBOverride | date | YES | | |
| Coupon | bit | YES | | |
| AgencySequence | int | NO | PK | |
| void | bit | YES | | |
| CreationDate | datetime | YES | | |
| E1TransactionId | int | YES | | |
| GenderOverride | int | YES | | sampled: `null` (count 2) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

Outbound (inferred):
- `PatientId` → `rxqPatient` — inferred, **high** confidence (100.0% referential match, not sampled)

Inbound (inferred):
- `rxqAuditLogMaster.cPatientThirdPartyId` → this table — inferred, **high** confidence (100.0% match)
- `rxqScriptTransaction.AgencySequence` → this table — inferred, **high** confidence (99.97% match)
- `rxqInsuranceCard.AgencySequence` → this table — inferred, **no-data** confidence (parent/child empty, unverified)
- `rxqInsuranceCardsImages.AgencySequence` → this table — inferred, **no-data** confidence (unverified)
- `rxqOnlineHistory.AgencySequence` → this table — inferred, **no-data** confidence (unverified)
- `rxqScriptPayments.AgencySequence` → this table — inferred, **no-data** confidence (unverified)

All of the above are naming-based inferences data-validated against actual column values (where data existed) — not declared schema constraints.

**Indexes**

- `IX_cPatientThirdParty` (NONCLUSTERED, non-unique) on `PatientId` — supports lookup of all third-party plans for a patient.
- `IX_PatientThirdParty_PcpDoctorIdentification` (NONCLUSTERED, non-unique) on `PcpDoctorIdentification` — supports lookup by primary-care-provider identification.
- `LibertyAuto_23_22_rxqPatientThirdParty` (NONCLUSTERED, non-unique) on `AgencySequence`, including `PatientId`, `AgencyCode`, `PcpDoctorIdentification` — covering index for `AgencySequence`-keyed joins from claim/transaction tables, avoiding a lookup back to the base row.

**Gotchas**

- Compound PK spans two varchar columns plus an int (`PatientId`, `AgencyCode`, `AgencySequence`) rather than the surrogate `cPatientThirdPartyId` identity column — joins from other tables predominantly use `AgencySequence` alone (per inferred_referenced_by), not the full composite key.
- Only 2 rows sampled in RXCS — several lookup domains (`MedicaidIndicator` blank, `GenderOverride` null) may not reflect the full real-world value space; treat coded-domain samples as illustrative, not exhaustive.
- `MedicaidIndicator` is a fixed char(2) but sampled value is blank spaces — actual coding scheme unconfirmed from this data.
- Several inbound references (`rxqInsuranceCard`, `rxqInsuranceCardsImages`, `rxqOnlineHistory`, `rxqScriptPayments`) are unvalidated (no-data) — likely real relationships given naming/domain but not confirmed by data in this instance at extraction time.

---

## `rxqMedicareEligibility`

Rows (RXCS): 3 | Columns: 18 | PK: `PatientId` | ETL-mirrored into liberty_link_stage: no

**Purpose**: Stores the result of a Medicare Part D eligibility check for a patient, including the identifying payer/BIN-PCN-cardholder response fields and the raw NCPDP-style response codes/messages (`F4_504_Message`, `FQ_526_AddMessage` — inferred: these look like NCPDP telecommunication field IDs 504 "Message" and 526 "Additional Message Information" from an E1/eligibility transaction response) (inferred). `PayerCount` and `IsValid` suggest it records whether a valid eligibility response with one or more payers was returned (inferred). One row per patient (PK is `PatientId` itself, not the identity `cMedicareEligibilityId`), so it holds only the latest/current eligibility snapshot rather than a history (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cMedicareEligibilityId | int | NO | | identity |
| PatientId | varchar(50) | NO | PK, → rxqPatient | |
| BIN | varchar(50) | YES | | payer Bank Identification Number (NCPDP) |
| PCN | varchar(50) | YES | | Processor Control Number (NCPDP) |
| NABP | varchar(50) | YES | | National Association of Boards of Pharmacy pharmacy ID |
| DateOfBirthYYYYMMDD | varchar(50) | YES | | DOB as string, format YYYYMMDD |
| Gender | varchar(50) | YES | | |
| FirstName | varchar(50) | YES | | |
| LastName | varchar(50) | YES | | |
| ZipCode | varchar(50) | YES | → rxqZCode | |
| CardholderId | varchar(50) | YES | | Medicare/payer cardholder ID |
| ResponseYYYYMMDD | varchar(50) | YES | | eligibility response date, string YYYYMMDD |
| ResponseHHMMSS | varchar(50) | YES | | eligibility response time, string HHMMSS |
| F4_504_Message | varchar(200) | YES | | NCPDP field 504 "Message" text (inferred) |
| FQ_526_AddMessage | varchar(200) | YES | | NCPDP field 526 "Additional Message Information" text (inferred) |
| LastModified | datetime | YES | | |
| IsValid | bit | YES | | sampled values: `true` (3) — only value observed |
| PayerCount | int | YES | | number of payers returned in eligibility response (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**:
  - `PatientId` → `rxqPatient` — inferred, **high** confidence (100.0% referential match)
  - `ZipCode` → `rxqZCode` — inferred, **high** confidence (100.0% referential match)
- **Inbound (inferred)**: none

**Indexes**: none defined.

**Gotchas**
- PK is the varchar `PatientId`, not the identity column `cMedicareEligibilityId` — one eligibility record per patient, so a re-check appears to overwrite rather than version (inferred from PK choice; no history/audit columns besides `LastModified`).
- Date/time fields are stored as strings (`YYYYMMDD`, `HHMMSS`) rather than native date/datetime types, consistent with raw NCPDP transaction field formats — don't assume sortable/comparable without parsing.
- Only 3 rows in RXCS sample; `IsValid` lookup only shows `true`, so the `false`/invalid-response domain is unconfirmed from this data.
- Not mirrored by ETL — not available in liberty_link_stage; any eMed-side consumption would need direct Liberty DB access.

---

## `rxqMedicareEligibilityPayers`

Rows (RXCS): 4 | Columns: 13 | PK: `cID` | ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores per-patient Medicare Part D eligibility/payer data as returned by an E1 eligibility-verification transaction — coverage type, PBM/payer routing identifiers (Id/IdQualifier/PCN/GroupId/CardholderId), person code, help-desk phone, patient-relationship code, and benefit effective/termination dates (inferred, standard NCPDP eligibility-response fields). It links to `rxqPatient` via `PatientId` and appears intended to link to an agency/payer-group table via `GroupId`, letting the pharmacy record which Medicare payer plan and benefit window applies to a patient for claims routing (inferred). Very low row count (4) suggests this is either a lightly-used/legacy eligibility cache or populated only for patients who had an explicit Medicare E1 check run.

**Columns**
| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| PatientId | varchar(50) | yes | → rxqPatient | |
| CoverageType | char(2) | no | | sampled values: `01` (3), `  ` i.e. blank/spaces (1) |
| IdQualifier | varchar(50) | yes | | |
| Id | varchar(50) | yes | | |
| PCN | varchar(50) | yes | | |
| CardholderId | varchar(50) | yes | | |
| GroupId | varchar(50) | yes | → rxqAgencyGroup | |
| PersonCode | varchar(50) | yes | | |
| HelpDeskNumber | varchar(50) | yes | | |
| PatientRelationshipCode | varchar(50) | yes | | |
| BenefitEffectiveYYYYMMDD | varchar(50) | yes | | date stored as string, format implied by column name |
| BenefitTerminationYYYYMMDD | varchar(50) | yes | | date stored as string, format implied by column name |
| cID | int | no | PK | identity |

**Relationships**
Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

These are all inferred from column naming and data-validated against actual parent-table values — not enforced constraints.

- **Outbound (inferred):**
  - `PatientId` → `rxqPatient` — inferred, **high** confidence (100.0% referential match, non-sampled, 4/4 non-null values matched).
  - `GroupId` → `rxqAgencyGroup` — inferred, **unvalidated** (parent table `rxqAgencyGroup` is empty, so match rate could not be computed; treat as an unconfirmed guess).
- **Inbound (inferred):** none.

**Indexes**
None reported (no indexes defined on this table beyond the PK).

**Gotchas**
- Date columns (`BenefitEffectiveYYYYMMDD`, `BenefitTerminationYYYYMMDD`) are varchar, not date/int — naming implies YYYYMMDD format but no type-level guarantee.
- `CoverageType` domain sample includes a blank/whitespace value (`"  "`), i.e. not every row has a populated coverage type.
- Extremely small table (4 rows) — any inferred relationship confidence here is based on a tiny sample; `GroupId`→`rxqAgencyGroup` can't be validated at all because the parent table currently has no rows.
- `PatientId` is a varchar key (not an int FK to `rxqPatient`'s presumed identity key), consistent with Liberty's general lack of typed/enforced FKs.

---

## `rxqNCPDP`

Rows (RXCS): 106 · Columns: 335 · PK: `AgencyCode` · ETL-mirrored into `liberty_link_stage`: no

**Purpose**

Per-payer ("AgencyCode") configuration table for NCPDP Telecommunication Standard claim submission — one row per third-party payer/agency, defining which NCPDP segment fields (patient, insurance, claim, pharmacy, prescriber, other-payer/COB, workers'-comp, DUR, pricing, coupon, compound, prior-authorization, clinical) must/may be populated when submitting a claim to that payer (inferred, from the field-group naming matching standard NCPDP D.0 segments and the Y/N switch semantics observed in `lookups`). Nearly every business column is duplicated with a `1`/`2` suffix (e.g. `InsuranceSwitch1`/`InsuranceSwitch2`, `ClaimSwitch1`/`ClaimSwitch2`), consistent with primary-claim vs. reversal/secondary-claim (COB) transaction configuration (inferred). Columns typed `varchar(20)` even where the sampled domain is boolean (`Y`/`N`) suggest this is a generic flag-storage design shared across many switch fields rather than true bit columns. `Data`, `ErrCode`, `LastModified`, `IsValid` at the end look like a generic audit/staging footer (inferred) rather than NCPDP-standard fields — `ErrCode` is always `0` and `IsValid` is always `true` in the sampled 106 rows, suggesting these are unused/always-passing housekeeping columns in this tenant.

**Columns**

Given 335 near-identical `1`/`2`-suffixed pairs, columns are grouped by NCPDP segment; suffix `1`/`2` = primary/secondary (COB) transaction variant of the same field. All are `varchar(20)`, nullable, no key, unless noted.

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `cNCPDPId` | int | No | | identity |
| `AgencyCode` | varchar(20) | No | **PK** | payer/agency identifier |
| `VendorCertID` | varchar(20) | Yes | | single (no 1/2 pair) |
| `TransactionSwitch1`, `TransactionSwitch2` | varchar(20) | Yes | | sampled domain: `""` (empty string), 106/106 both |
| `TransactionQual1`, `TransactionQual2` | varchar(20) | Yes | | |
| `PatientSwitch1/2`, `PatientIDQualifier1/2`, `PatientID1/2`, `PatientDOB1/2`, `PatientGender1/2`, `PatientFirstName1/2`, `PatientLastName1/2`, `PatientStreet1/2`, `PatientCity1/2`, `PatientState1/2`, `PatientZip1/2`, `PatientPhone1/2`, `PatientLocation1/2`, `PatientEmployerID1/2`, `PatientSmoker1/2`, `PatientPregnancy1/2`, `PatientEmail1/2` | varchar(20) | Yes | | Patient segment field-required switches |
| `InsuranceSwitch1/2`, `InsuranceID1/2`, `InsuranceFirstName1/2`, `InsuranceLastName1/2`, `InsuranceHomePlan1/2`, `InsurancePlanID1/2`, `InsuranceEligibility1/2`, `InsuranceFacilityID1/2`, `InsuranceGroupID1/2`, `InsurancePersonCode1/2`, `InsurancePatientRel1/2` | varchar(20) | Yes | | Insurance segment. `InsuranceSwitch1`: `Y`=96/`N`=10; `InsuranceSwitch2`: `N`=90/`Y`=16; `InsuranceGroupID1`: `Y`=94/`N`=12; `InsuranceGroupID2`: `N`=102/`Y`=4; `InsurancePersonCode1`: `Y`=91/`N`=15; `InsurancePersonCode2`: `N`=101/`Y`=5 |
| `ClaimSwitch1/2`, `ClaimPerscriptionQual1/2`, `ClaimProductQual1/2`, `ClaimAssocScriptRef1/2`, `ClaimAssocScriptDate1/2`, `ClaimProcedureMOD1/2`, `ClaimQuantityDispensed1/2`, `ClaimFillNumber1/2`, `ClaimDaysSupply1/2`, `ClaimCompoundCode1/2`, `ClaimDispenseAs1/2`, `ClaimDateScript1/2`, `ClaimNumberOfRefills1/2`, `ClaimScriptOrigin1/2`, `ClaimSubClarification1/2`, `ClaimQuantityPrescribed1/2`, `ClaimOtherCoverage1/2`, `ClaimUnitDose1/2`, `ClaimOrigProdQual1/2`, `ClaimOrigProdCode1/2`, `ClaimOrigQuantity1/2`, `ClaimAlternateID1/2`, `ClaimScheduledScript1/2`, `ClaimUnitOfMeasure1/2`, `ClaimLevelOfService1/2`, `ClaimPriorAuthType1/2`, `ClaimPriorAuthNumber1/2`, `ClaimItermAuthType1/2`, `ClaimItermAuthID1/2`, `ClaimDispensingStatus1/2`, `ClaimQtyIntended1/2`, `ClaimDaysSupIntended1/2` | varchar(20) | Yes | | Claim segment. Sampled switches: `ClaimSwitch1` Y=96/N=10, `ClaimSwitch2` Y=94/N=12; `ClaimCompoundCode1` Y=96/N=10, `ClaimCompoundCode2` N=105/Y=1; `ClaimScriptOrigin1` N=98/Y=8, `ClaimScriptOrigin2` N=106; `ClaimUnitDose1` N=96/Y=10, `ClaimUnitDose2` N=106; `ClaimOrigProdCode1/2` N=106 (both); `ClaimScheduledScript1/2` N=106 (both); `ClaimUnitOfMeasure1` N=104/Y=2, `ClaimUnitOfMeasure2` N=106; `ClaimLevelOfService1` N=82/Y=24, `ClaimLevelOfService2` N=106; `ClaimPriorAuthType1` Y=86/N=20, `ClaimPriorAuthType2` N=106; `ClaimItermAuthType1/2` N=106 (both); `ClaimDispensingStatus1` N=96/Y=10, `ClaimDispensingStatus2` N=103/Y=3 |
| `PharmacySwitch1/2`, `PharmacyProviderIDQual1/2`, `PharmacyProviderID1/2` | varchar(20) | Yes | | Pharmacy segment. `PharmacySwitch1/2`: N=106 (both, never toggled in sample) |
| `PrescriberSwitch1/2`, `PrescriberQual1/2`, `PrescriberID1/2`, `PrescriberLocCode1/2`, `PrescriberLastName1/2`, `PrescriberPhone1/2`, `PrescriberPCPQual1/2`, `PrescriberPCPID1/2`, `PrescriberPCPLocation1/2`, `PrescriberPCPLastName1/2` | varchar(20) | Yes | | Prescriber segment. `PrescriberSwitch1` Y=96/N=10, `PrescriberSwitch2` N=102/Y=4; `PrescriberLocCode1` N=104/Y=2, `PrescriberLocCode2` N=106; `PrescriberPCPLocation1` N=104/Y=2, `PrescriberPCPLocation2` N=106 |
| `OtherSwitch1/2`, `OtherCount1/2`, `OtherCovType1/2`, `OtherQual1/2`, `OtherID1/2`, `OtherDate1/2`, `OtherAmtPaidCnt1/2`, `OtherAmtQual1/2`, `OtherAmtPaid1/2`, `OtherRejectCount1/2`, `OtherRejectCode1/2`, `OtherPatAmtCount1/2`, `OtherPatAmt1/2` | varchar(20) | Yes | | Other Payer (COB) segment. `OtherSwitch1` N=64/Y=42, `OtherSwitch2` N=106; `OtherCovType1` N=63/Y=43, `OtherCovType2` N=106; `OtherRejectCode1` N=79/Y=27, `OtherRejectCode2` N=106 |
| `WCSwitch1/2`, `WCName1/2`, `WCStreet1/2`, `WCCity1/2`, `WCState1/2`, `WCZip1/2`, `WCPhoneNumber1/2`, `WCContactName1/2`, `WCCarrierID1/2`, `WCReferenceID1/2` | varchar(20) | Yes | | Workers' Compensation segment. `WCSwitch1` N=103/Y=3, `WCSwitch2` N=106; `WCState1` N=94/Y=12, `WCState2` N=106 |
| `DURSwitch1/2`, `DURCodeCounter1/2`, `DURReason1/2`, `DURProfessional1/2`, `DURResult1/2`, `DURLevelOfEffort1/2`, `DURCOAgentQual1/2`, `DURCOAgentID1/2` | varchar(20) | Yes | | DUR/PPS segment. `DURSwitch1` Y=69/N=37, `DURSwitch2` N=100/Y=6; `DURCodeCounter1` Y=71/N=35, `DURCodeCounter2` N=102/Y=4 |
| `PricingSwitch1/2`, `PricingIngredient1/2`, `PricingDispensing1/2`, `PricingProfService1/2`, `PricingPatientPaid1/2`, `PricingIncentive1/2`, `PricingAmtClaimedCount1/2`, `PricingAmtQual1/2`, `PricingAmtClaimed1/2`, `PricingFlatSalesTaxAmt1/2`, `PricingPctSalesTaxAmt1/2`, `PricingPctSalesTaxRate1/2`, `PricingPctSalesTaxBasis1/2`, `PricingUsual1/2`, `PricingGross1/2`, `PricingBasisOfCost1/2` | varchar(20) | Yes | | Pricing segment. `PricingSwitch1` Y=96/N=10, `PricingSwitch2` N=106 |
| `CouponSwitch1/2`, `CouponType1/2`, `CouponNumber1/2`, `CouponValue1/2` | varchar(20) | Yes | | Coupon segment. `CouponSwitch1` N=92/Y=14, `CouponSwitch2` N=106; `CouponType1` N=84/Y=22, `CouponType2` N=106 |
| `CompoundSwitch1/2`, `CompoundDosageForm1/2`, `CompoundDispUnit1/2`, `CompoundRouteofAdmin1/2`, `CompoundIngrComponent1/2`, `CompoundProductQual1/2`, `CompoundProductID1/2`, `CompoundIngrQuantity1/2`, `CompoundIngrDrug1/2`, `CompoundIngrBasis1/2` | varchar(20) | Yes | | Compound segment. `CompoundSwitch1` N=94/Y=12, `CompoundSwitch2` N=106; `CompoundDosageForm1` N=88/Y=18, `CompoundDosageForm2` N=106; `CompoundDispUnit1` N=88/Y=18, `CompoundDispUnit2` N=106; `CompoundRouteofAdmin1` N=88/Y=18, `CompoundRouteofAdmin2` N=106 |
| `PriorSwitch1/2`, `PriorReqType1/2`, `PriorReqDateBegin1/2`, `PriorReqDateEnd1/2`, `PriorBasis1/2`, `PriorRepFirstName1/2`, `PriorRepLastName1/2`, `PriorRepStreet1/2`, `PriorRepCity1/2`, `PriorRepState1/2`, `PriorRepZip1/2`, `PriorNumberAssigned1/2`, `PriorAuthNumber1/2`, `PriorAuthSupp1/2` | varchar(20) | Yes | | Prior Authorization segment. `PriorSwitch1` N=97/Y=9, `PriorSwitch2` N=106; `PriorReqType1` N=86/Y=20, `PriorReqType2` N=106; `PriorRepState1` N=102/Y=4, `PriorRepState2` N=106 |
| `ClinicalSwitch1/2`, `ClinicalDiagCodeCount1/2`, `ClinicalDiagQual1/2`, `ClinicalDiagCode1/2`, `ClinicalInfo1/2`, `ClinicalMeasDate1/2`, `ClinicalMeasTime1/2`, `ClinicalMeasDimension1/2`, `ClinicalMeasUnit1/2`, `ClinicalMeasValue1/2` | varchar(20) | Yes | | Clinical segment. `ClinicalSwitch1` N=88/Y=18, `ClinicalSwitch2` N=106; `ClinicalDiagCodeCount1/2` N=106 (both); `ClinicalDiagCode1` N=84/Y=22, `ClinicalDiagCode2` N=106; `ClinicalMeasUnit1` N=103/Y=3, `ClinicalMeasUnit2` N=106 |
| `LastChangeCC1/2`, `LastChangeYY1/2`, `LastChangeMM1/2`, `LastChangeDD1/2` | varchar(20) | Yes | | century/year/month/day parts of a last-change date, split as text (not a single date column) |
| `Data` | varchar(20) | Yes | | unlabeled/generic |
| `ErrCode` | int | Yes | | sampled: `0` (106/106) |
| `LastModified` | datetime | Yes | | |
| `IsValid` | bit | Yes | | sampled: `true` (106/106) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — `inferred_relationships` is empty; no column in this table was matched to a parent table by name+data validation.
- **Inbound (inferred):** none — `inferred_referenced_by` is empty; no other table's column was matched to `rxqNCPDP.AgencyCode` (or any other column) by name+data validation.

`AgencyCode` (varchar PK) strongly suggests other tables reference it as a payer/agency lookup key (e.g. claim or insurance tables), but no such edge was detected by the naming+data-validation heuristic — treat any such linkage as unconfirmed/absent evidence, not a "none exists" guarantee.

**Indexes**

None returned (`indexes: []`) — no non-clustered indexes beyond the PK were surfaced.

**Gotchas**

- Every business field is duplicated with a `1`/`2` suffix across ~330 of 335 columns — a wide, denormalized "primary claim + secondary/COB claim" config layout rather than a related child table; queries must always be aware which suffix applies to the transaction being evaluated.
- All Y/N "switch" fields are stored as `varchar(20)`, not `bit`, and several observed values are literal empty strings (`""`) rather than NULL (e.g. `TransactionSwitch1/2`) — do not assume NULL-only absence-handling.
- `LastChangeCC/YY/MM/DD` split date-part-as-text columns (both 1 and 2 variants) mean any historical "last changed" date requires string concatenation/parsing rather than a native datetime column.
- `ErrCode` (always 0) and `IsValid` (always true) across all 106 sampled rows suggest these are dead/unused housekeeping columns in this tenant — do not build logic that branches on them without confirming real-world variance first.
- PK `AgencyCode` is a varchar business key (not a surrogate int), while `cNCPDPId` is an unused-looking identity column that is not the PK — a common Liberty pattern of a synthetic identity column coexisting with the "real" natural-key PK.
- Not mirrored by ETL into `liberty_link_stage` — this table is invisible to downstream eMed reporting/joins; any need to reference per-payer NCPDP submission config must go directly against the Liberty source DB.

---

## `rxqNcpdpCodes`

Rows (RXCS): 334 | Columns: 4 | PK: (`CodeType`, `CodeKey`) | ETL-mirrored into liberty_link_stage: no

**Purpose**

A static NCPDP code-lookup/reference table: each row maps a `CodeType` (a named code category) plus a `CodeKey` (the raw code value within that category) to a human-readable `CodeName`, with `CodeFieldValueType` describing the value's data type (inferred). This is a classic Liberty "code dictionary" table used to decode NCPDP standard field values (e.g., claim segment/response codes) elsewhere in the pharmacy system rather than a transactional/patient-data table — consistent with its small fixed row count (334), composite non-identity varchar key, and total absence of foreign-key/relationship edges (inferred, since no other Liberty table has columns matching `CodeType`/`CodeKey` by name). Not mirrored by ETL, suggesting downstream (eMed/liberty_link_stage) consumers don't need this raw NCPDP dictionary directly (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| CodeType | varchar(100) | NO | PK | Part of composite PK; NCPDP code category name |
| CodeKey | varchar(50) | NO | PK | Part of composite PK; raw code value within CodeType |
| CodeName | varchar(500) | YES | | Human-readable label/description for the code (inferred) |
| CodeFieldValueType | varchar(50) | YES | | Describes the expected data type/format of the code value (inferred) |

No columns appear in `lookups` (none sampled/provided), so no enumerated value domain is documented here beyond the schema itself.

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

No naming-based candidate edges were detected in either direction — this table has no `implicit_ref` columns and no other table's columns were matched to it. Treat it as a standalone reference/dictionary table.

**Indexes**

None reported (empty `indexes` list beyond the composite primary key itself).

**Gotchas**

- Composite varchar primary key (`CodeType`, `CodeKey`) rather than a surrogate identity — typical of static lookup tables but means joins/consumers must match on two varchar columns, not a single numeric ID.
- No declared or inferred relationships at all — this table is disconnected from the rest of the schema graph as extracted; any linkage to other tables' NCPDP code columns would be by convention/value only, not enforced or detectable via naming.
- Not ETL-mirrored, so liberty_link_stage/eMed cannot resolve NCPDP codes via this table directly; any code-decoding done in eMed must use its own reference data or hit Liberty live.

---

## `rxqNcpdpOnlineHistory`

Rows (RXCS): 4 · Columns: 4 · PK: `TransactionID` · ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores a log of NCPDP online transactions (request/response pairs) with a timestamp, keyed by an identity `TransactionID`. (Inferred) Given the "Ncpdp" naming and the `TransactionRequest`/`TransactionResponse` varchar(max) columns, this appears to be a raw audit trail of outbound NCPDP-format transactions (e.g., pharmacy claim submissions/eligibility checks over the NCPDP Telecommunication Standard) and their raw returned payloads, used for troubleshooting/auditing rather than as an operational table consumed elsewhere in the schema. With only 4 rows sampled, it is either lightly used, recently added, or purged/archived elsewhere.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| TransactionID | int | NO | PK | identity |
| TransactionDateTime | datetime | YES | | |
| TransactionRequest | varchar(max) | YES | | raw request payload (no lookups sampled) |
| TransactionResponse | varchar(max) | YES | | raw response payload (no lookups sampled) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

**Indexes**

None reported (no indexes, including no PK-backing index entries surfaced beyond the primary key column itself).

**Gotchas**

- No inferred relationships in either direction and no lookups — this table is schematically isolated in the extracted metadata; any linkage to a specific patient/claim/order would have to be parsed out of the `TransactionRequest`/`TransactionResponse` payload text itself, not from typed columns.
- Only 4 rows sampled at extraction time — too small to draw volume/usage conclusions; treat as point-in-time.
- Not mirrored by ETL, so this data is not available in liberty_link_stage for reporting/joins.

---

## `RxqAgencyNcpdpFormat`

Rows (RXCS): 6 · Columns: 232 · PK: (`AgencyCode`, `RecordType`) · ETL-mirrored into liberty_link_stage: no

**Purpose**
Stores per-agency NCPDP telecommunication D.0 claim-format templates: for a given `AgencyCode` (a payer/agency, e.g. a workers'-comp carrier or Medicaid agency) and `RecordType` (sampled domain: `R`, `C` — likely Request vs. Claim/Response, inferred), it defines a segment-by-segment field map covering nearly every NCPDP D.0 claim segment (Patient `PS_*`, Insurance `IS_*`, Claim `CS_*`, Pharmacy Provider `PPS_*`, Prescriber `MdS_*`, Coordination of Benefits `COBS_*`, Workers' Comp `WS_*`, DUR/PPS `DS_*`, Pricing `PrS_*`, Coupon `CpS_*`, Compound `CmpS_*`, Prior Authorization `PAS_*`, Clinical `ClS_*`, Additional Documentation `ADS_*`, Facility `FS_*`, Narrative `NS_*`). The overwhelming majority of columns are `bit` typed despite NCPDP-field-style names (Id, Date, Amount, etc.) — this is consistent with each column being a boolean "include/require this NCPDP field for this agency+record type" toggle rather than a value holder (inferred). A handful of columns are `char(1)`/`char(2)` — these look like literal qualifier/format codes (e.g. `TransactionHeaderB2Qualifier`, `*IdQualifier`, `*ProductIdQualifier`) rather than flags (inferred). `Description`, `LastChangeDate`, and `VendorCertificationNumber` are template metadata (name, last-edit timestamp, SureScripts/NCPDP vendor certification number for the format). Functionally this is a claim-format configuration/lookup table used to drive outbound NCPDP D.0 claim construction per agency — likely for non-standard third-party billing (workers' comp, cash-discount, or state Medicaid) rather than routine PBM adjudication, given the dedicated Workers' Comp (`WS_*`) and Facility (`FS_*`) segments (inferred). Only 6 rows exist in RXCS, implying very few agencies have custom NCPDP format overrides configured — most billing presumably uses a hardcoded/default D.0 layout.

**Columns**
| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `AgencyCode` | varchar(50) | NO | PK |  |
| `RecordType` | char(1) | NO | PK | sampled values: "R"(3), "C"(3) |
| `Description` | varchar(50) | NO |  |  |
| `LastChangeDate` | datetime | NO |  |  |
| `VendorCertificationNumber` | varchar(50) | NO |  |  |
| `TransactionHeaderB2Qualifier` | char(2) | NO |  |  |
| `PS_PatientSegment` | bit | NO |  |  |
| `PS_IdQualifier` | char(2) | NO |  |  |
| `PS_Id` | bit | NO |  |  |
| `PS_DateOfBirth` | bit | NO |  |  |
| `PS_Gender` | bit | NO |  | sampled values: true(3), false(3) |
| `PS_FirstName` | bit | NO |  |  |
| `PS_LastName` | bit | NO |  |  |
| `PS_Street` | bit | NO |  |  |
| `PS_City` | bit | NO |  |  |
| `PS_State` | bit | NO |  | sampled values: false(6) |
| `PS_Zip` | bit | NO |  |  |
| `PS_Phone` | bit | NO |  |  |
| `PS_Location` | bit | NO |  | sampled values: true(3), false(3) |
| `PS_EmployerId` | bit | NO |  |  |
| `PS_SmokerCode` | bit | NO |  | sampled values: false(6) |
| `PS_PregnancyIndicator` | bit | NO |  | sampled values: true(3), false(3) |
| `PS_EmailAddress` | bit | NO |  |  |
| `PS_Residence` | bit | NO |  |  |
| `IS_InsuranceSegment` | bit | NO |  |  |
| `IS_CardholderId` | bit | NO |  | sampled values: true(6) |
| `IS_CardholderFirstName` | bit | NO |  |  |
| `IS_CardholderLastName` | bit | NO |  |  |
| `IS_HomePlan` | bit | NO |  |  |
| `IS_PlanId` | bit | NO |  |  |
| `IS_EligibilityClarificationCode` | bit | NO |  |  |
| `IS_GroupId` | bit | NO |  | sampled values: true(6) |
| `IS_PersonCode` | bit | NO |  | sampled values: true(3), false(3) |
| `IS_PatientRelationshipCode` | bit | NO |  |  |
| `IS_OtherPayerBIN` | bit | NO |  |  |
| `IS_OtherPayerPCN` | bit | NO |  |  |
| `IS_OtherPayerCardholderId` | bit | NO |  | sampled values: false(6) |
| `IS_OtherPayerGroupId` | bit | NO |  | sampled values: false(6) |
| `IS_MedigapId` | bit | NO |  |  |
| `IS_MedicaidIndicator` | bit | NO |  | sampled values: false(6) |
| `IS_ProviderAcceptsAssignmentIndicator` | bit | NO |  |  |
| `IS_QualifiedFacility` | bit | NO |  |  |
| `IS_MedicaidId` | bit | NO |  |  |
| `IS_MedicaidAgencyNumber` | bit | NO |  |  |
| `CS_ClaimSegment` | bit | NO |  |  |
| `CS_ScriptNumberQualifier` | char(1) | NO |  |  |
| `CS_ScriptNumber` | bit | NO |  |  |
| `CS_ProductIdQualifier` | char(2) | NO |  |  |
| `CS_ProductId` | bit | NO |  |  |
| `CS_AssociatedScriptNumber` | bit | NO |  |  |
| `CS_AssociatedScriptDate` | bit | NO |  |  |
| `CS_ProcedureModifierCodeCount` | bit | NO |  | sampled values: false(6) |
| `CS_ProcedureModifierCode` | bit | NO |  | sampled values: false(6) |
| `CS_QuantityDispensed` | bit | NO |  |  |
| `CS_FillNumber` | bit | NO |  |  |
| `CS_DaysSupply` | bit | NO |  |  |
| `CS_CompoundCode` | bit | NO |  | sampled values: true(3), false(3) |
| `CS_DAWCode` | bit | NO |  | sampled values: true(3), false(3) |
| `CS_DateWritten` | bit | NO |  |  |
| `CS_RefillsAuthorized` | bit | NO |  |  |
| `CS_PrescriptionOriginCode` | bit | NO |  | sampled values: true(3), false(3) |
| `CS_SubmissionClarificationCodeCount` | bit | NO |  |  |
| `CS_SubmissionClarificationCode` | bit | NO |  |  |
| `CS_QuantityWritten` | bit | NO |  |  |
| `CS_OtherCoverageCode` | bit | NO |  | sampled values: true(6) |
| `CS_SpecialPackageIndicator` | bit | NO |  | sampled values: false(6) |
| `CS_OriginallyPrescribedProductIdQualifier` | char(2) | NO |  | sampled values: "  "(6) |
| `CS_OriginallyPrescribedProductId` | bit | NO |  | sampled values: false(6) |
| `CS_OriginallyPrescribedQuantity` | bit | NO |  | sampled values: false(6) |
| `CS_AlternateId` | bit | NO |  |  |
| `CS_ScheduledPrescriptionIdNumber` | bit | NO |  | sampled values: false(6) |
| `CS_UnitOfMeasure` | bit | NO |  | sampled values: true(3), false(3) |
| `CS_LevelOfService` | bit | NO |  | sampled values: true(3), false(3) |
| `CS_PriorAuthorizationTypeCode` | bit | NO |  |  |
| `CS_PriorAuthorizationNumberSubmitted` | bit | NO |  |  |
| `CS_IntermediaryAuthorizationTypeId` | bit | NO |  |  |
| `CS_IntermediaryAuthorizationId` | bit | NO |  |  |
| `CS_DispensingStatus` | bit | NO |  | sampled values: false(6) |
| `CS_QuantityIntendedToBeDispensed` | bit | NO |  |  |
| `CS_DaysSupplyIntendedToBeDispensed` | bit | NO |  |  |
| `CS_DelayReasonCode` | bit | NO |  |  |
| `CS_TransactionReferenceNumber` | bit | NO |  |  |
| `CS_PatientAssignmentIndicator` | bit | NO |  |  |
| `CS_RouteOfAdministration` | bit | NO |  | sampled values: true(3), false(3) |
| `CS_CompoundType` | bit | NO |  | sampled values: true(3), false(3) |
| `CS_MedicaidSubrogationInternalNumber` | bit | NO |  |  |
| `CS_PharmacyServiceType` | bit | NO |  | sampled values: true(6) |
| `PPS_PharmacyProviderSegment` | bit | NO |  |  |
| `PPS_ProviderIdQualifier` | char(2) | NO |  |  |
| `PPS_ProviderId` | bit | NO |  |  |
| `MdS_PrescriberSegment` | bit | NO |  |  |
| `MdS_PrescriberIdQualifier` | char(2) | NO |  |  |
| `MdS_PrescriberId` | bit | NO |  |  |
| `MdS_PrescriberLastName` | bit | NO |  |  |
| `MdS_PrescriberPhone` | bit | NO |  |  |
| `MdS_PrimaryCareProviderIdQualifier` | char(2) | NO |  |  |
| `MdS_PrimaryCareProviderId` | bit | NO |  |  |
| `MdS_PrimaryCareProviderLastName` | bit | NO |  |  |
| `MdS_PrescriberFirstName` | bit | NO |  |  |
| `MdS_PrescriberStreet` | bit | NO |  |  |
| `MdS_PrescriberCity` | bit | NO |  |  |
| `MdS_PrescriberState` | bit | NO |  | sampled values: false(6) |
| `MdS_PrescriberZip` | bit | NO |  |  |
| `COBS_CoordinationOfBenefitsSegment` | bit | NO |  |  |
| `COBS_OtherPaymentsCount` | bit | NO |  |  |
| `COBS_OtherPayerCoverageCode` | bit | NO |  | sampled values: true(6) |
| `COBS_OtherPayerIdQualifier` | char(2) | NO |  |  |
| `COBS_OtherPayerId` | bit | NO |  |  |
| `COBS_OtherPayerDate` | bit | NO |  |  |
| `COBS_InternalControlNumber` | bit | NO |  |  |
| `COBS_OtherPayerAmountPaidCount` | bit | NO |  |  |
| `COBS_OtherPayerAmountPaidQualifier` | char(2) | NO |  |  |
| `COBS_OtherPayerAmountPaid` | bit | NO |  |  |
| `COBS_OtherPayerRejectCount` | bit | NO |  |  |
| `COBS_OtherPayerRejectCode` | bit | NO |  | sampled values: true(3), false(3) |
| `COBS_OtherPayerCopayCount` | bit | NO |  |  |
| `COBS_OtherPayerCopayAmountQualifier` | char(2) | NO |  |  |
| `COBS_OtherPayerCopayAmount` | bit | NO |  |  |
| `COBS_BenefitStageCount` | bit | NO |  |  |
| `COBS_BenefitStageQualifier` | char(2) | NO |  |  |
| `COBS_BenefitStageAmount` | bit | NO |  |  |
| `WS_WorkersCompSegment` | bit | NO |  |  |
| `WS_DateOfInjury` | bit | NO |  |  |
| `WS_EmployerName` | bit | NO |  |  |
| `WS_EmployerStreet` | bit | NO |  |  |
| `WS_EmployerCity` | bit | NO |  |  |
| `WS_EmployerState` | bit | NO |  | sampled values: false(6) |
| `WS_EmployerZip` | bit | NO |  |  |
| `WS_EmployerPhone` | bit | NO |  |  |
| `WS_EmployerContact` | bit | NO |  |  |
| `WS_CarrierId` | bit | NO |  |  |
| `WS_ClaimId` | bit | NO |  |  |
| `WS_BillingEntityTypeIndicator` | bit | NO |  | sampled values: false(6) |
| `WS_PayToQualifier` | char(2) | NO |  |  |
| `WS_PayToId` | bit | NO |  |  |
| `WS_PayToName` | bit | NO |  |  |
| `WS_PayToStreet` | bit | NO |  |  |
| `WS_PayToCity` | bit | NO |  |  |
| `WS_PayToState` | bit | NO |  | sampled values: false(6) |
| `WS_PayToZip` | bit | NO |  |  |
| `WS_GenericEquivalentProductIdQualifier` | char(2) | NO |  |  |
| `WS_GenericEquivalentProductId` | bit | NO |  |  |
| `DS_DURPPSSegment` | bit | NO |  |  |
| `DS_DURCodeCounter` | bit | NO |  | sampled values: true(3), false(3) |
| `DS_ReasonForServiceCode` | bit | NO |  |  |
| `DS_ProfessionalServiceCode` | bit | NO |  | sampled values: true(3), false(3) |
| `DS_ResultOfServiceCode` | bit | NO |  | sampled values: true(3), false(3) |
| `DS_LevelOfEffort` | bit | NO |  | sampled values: true(3), false(3) |
| `DS_CoAgentIdQualifier` | char(2) | NO |  |  |
| `DS_CoAgentId` | bit | NO |  |  |
| `PrS_PricingSegment` | bit | NO |  |  |
| `PrS_IngredientCost` | bit | NO |  |  |
| `PrS_DispensingFee` | bit | NO |  |  |
| `PrS_ProfessionalServiceFee` | bit | NO |  |  |
| `PrS_PatientPaidAmount` | bit | NO |  |  |
| `PrS_IncentiveAmount` | bit | NO |  |  |
| `PrS_OtherAmountClaimedCount` | bit | NO |  |  |
| `PrS_OtherAmountClaimedQualifier` | char(2) | NO |  |  |
| `PrS_OtherAmountClaimed` | bit | NO |  |  |
| `PrS_FlatSalesTax` | bit | NO |  |  |
| `PrS_PercentageSalesTax` | bit | NO |  |  |
| `PrS_PercentageSalesTaxRate` | bit | NO |  |  |
| `PrS_PercentageSalesTaxBasis` | bit | NO |  |  |
| `PrS_UsualAndCustomary` | bit | NO |  |  |
| `PrS_GrossAmountDue` | bit | NO |  |  |
| `PrS_BasisOfCostDetermination` | bit | NO |  |  |
| `PrS_MedicaidPaidAmount` | bit | NO |  |  |
| `CpS_CouponSegment` | bit | NO |  |  |
| `CpS_CouponType` | bit | NO |  | sampled values: false(6) |
| `CpS_CouponNumber` | bit | NO |  |  |
| `CpS_CouponValueAmount` | bit | NO |  |  |
| `CmpS_CompoundSegment` | bit | NO |  |  |
| `CmpS_DosageFormDescriptionCode` | bit | NO |  |  |
| `CmpS_DispensingUnitFormIndicator` | bit | NO |  | sampled values: true(3), false(3) |
| `CmpS_IngredientComponentCount` | bit | NO |  |  |
| `CmpS_ProductIdQualifier` | char(2) | NO |  |  |
| `CmpS_ProductId` | bit | NO |  |  |
| `CmpS_IngredientQuantity` | bit | NO |  |  |
| `CmpS_IngredientDrugCost` | bit | NO |  |  |
| `CmpS_IngredientBasisOfCost` | bit | NO |  |  |
| `CmpS_IngredientModifierCodeCount` | bit | NO |  | sampled values: false(6) |
| `CmpS_IngredientModifierCode` | bit | NO |  | sampled values: false(6) |
| `PAS_PriorAuthorizationSegment` | bit | NO |  |  |
| `PAS_RequestType` | bit | NO |  | sampled values: false(6) |
| `PAS_RequestPeriodBeginDate` | bit | NO |  |  |
| `PAS_RequestPeriodEndDate` | bit | NO |  |  |
| `PAS_BasisOfRequest` | bit | NO |  |  |
| `PAS_RepFirstName` | bit | NO |  |  |
| `PAS_RepLastName` | bit | NO |  |  |
| `PAS_RepStreet` | bit | NO |  |  |
| `PAS_RepCity` | bit | NO |  |  |
| `PAS_RepState` | bit | NO |  | sampled values: false(6) |
| `PAS_RepZip` | bit | NO |  |  |
| `PAS_PriorAuthNumberAssigned` | bit | NO |  |  |
| `PAS_AuthorizationNumber` | bit | NO |  |  |
| `PAS_AuthorizationSupportingDocumentation` | bit | NO |  |  |
| `ClS_ClinicalSegment` | bit | NO |  |  |
| `ClS_DiagnosisCodeCount` | bit | NO |  | sampled values: true(3), false(3) |
| `ClS_DiagnosisCodeQualifier` | char(2) | NO |  | sampled values: "01"(3), "  "(3) |
| `ClS_DiagnosisCode` | bit | NO |  | sampled values: true(3), false(3) |
| `ClS_ClinicalInformationCounter` | bit | NO |  | sampled values: false(6) |
| `ClS_MeasurementDate` | bit | NO |  |  |
| `ClS_MeasurementTime` | bit | NO |  |  |
| `ClS_MeasurementDimension` | bit | NO |  |  |
| `ClS_MeasurementUnit` | bit | NO |  | sampled values: false(6) |
| `ClS_MeasurementValue` | bit | NO |  |  |
| `ADS_AdditionalDocumentationSegment` | bit | NO |  |  |
| `ADS_AdditionalDocumentationTypeId` | bit | NO |  | sampled values: false(6) |
| `ADS_RequestPeriodBeginDate` | bit | NO |  |  |
| `ADS_RequestPeriodRevisedDate` | bit | NO |  |  |
| `ADS_RequestStatus` | bit | NO |  | sampled values: false(6) |
| `ADS_LengthOfNeedQualifier` | char(1) | NO |  |  |
| `ADS_LengthOfNeed` | bit | NO |  |  |
| `ADS_PrescriberDateSigned` | bit | NO |  |  |
| `ADS_SupportingDocumentation` | bit | NO |  |  |
| `ADS_QuestionNumberLetterCount` | bit | NO |  |  |
| `ADS_QuestionNumberLetter` | bit | NO |  |  |
| `ADS_QuestionPercentResponse` | bit | NO |  |  |
| `ADS_QuestionDateResponse` | bit | NO |  |  |
| `ADS_QuestionDollarAmountResponse` | bit | NO |  |  |
| `ADS_QuestionNumericResponse` | bit | NO |  |  |
| `ADS_QuestionAlphanumericResponse` | bit | NO |  |  |
| `FS_FacilitySegment` | bit | NO |  |  |
| `FS_FacilityId` | bit | NO |  |  |
| `FS_FacilityName` | bit | NO |  |  |
| `FS_FacilityStreet` | bit | NO |  |  |
| `FS_FacilityCity` | bit | NO |  |  |
| `FS_FacilityState` | bit | NO |  | sampled values: false(6) |
| `FS_FacilityZip` | bit | NO |  |  |
| `NS_NarrativeSegment` | bit | NO |  |  |
| `NS_NarrativeMessage` | bit | NO |  |  |
| `COBS_OCC08Override` | bit | YES |  |  |

**Relationships**
Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no `implicit_ref` naming matches were detected on any column (no column resembles a typed FK such as `PatientId`/`RxId`; `AgencyCode` is a free-text code with no matching parent table found).
- **Inbound (inferred):** none — no other table's column was found to reference `AgencyCode`/`RecordType` by name+data match in this extract.

All confidence in this section would be **no-data** by default since the metadata's `inferred_relationships`/`inferred_referenced_by` arrays are both empty; treat `AgencyCode` as a probable soft link to an (unidentified or unmirrored) agency/payer master table, unconfirmed.

**Indexes**
None reported (empty `indexes[]`) beyond the implicit PK constraint on (`AgencyCode`, `RecordType`).

**Gotchas**
- 226 of 232 columns are typed `bit` even though their names imply strings/dates/amounts (e.g. `CS_DateWritten`, `PrS_GrossAmountDue`, `WS_ClaimId`) — these are almost certainly per-field inclusion/requirement toggles for the NCPDP template, not the actual claim data (inferred); don't mistake this for a table that stores real claim amounts or dates.
- Composite varchar/char PK: `AgencyCode` (varchar(50)) + `RecordType` (char(1)) — no surrogate integer key, so joins must match on the exact code string and be alert to trailing-space padding (seen in `char(2)` qualifier columns sampled as `"  "`).
- Only 6 rows total in RXCS split evenly 3/3 across `RecordType` values `R` and `C`, suggesting exactly 3 (or fewer) distinct `AgencyCode`s each with one `R` row and one `C` row — a very small, hand-maintained configuration set rather than a bulk-populated reference table.
- `COBS_OCC08Override` is the only nullable column; all 231 others are NOT NULL, consistent with a fully-populated template row per agency rather than sparse/optional data.
- No declared or inferred relationships exist for this table in the extract — any join to patient, claim, or agency-master tables must be established from external knowledge (e.g. application code or Liberty documentation), not from this schema alone.

---

## `rxqAgency`

Rows (RXCS): 58 · Columns: 42 · PK: `AgencyCode` · ETL-mirrored into `liberty_link_stage`: no

**Purpose**

Stores third-party-payer ("agency"/plan) definitions used for claims adjudication and pricing — one row per payer plan identified by `AgencyCode`, carrying NCPDP claims-routing identifiers (`BIN`, `PCN`, `NcpdpFormat`, `PlanClassificationCode`, `DefaultOtherCoverageCode`, `OverrideNcpdpPharmacyServiceType`), pricing/reimbursement rules (`PriceFormulaCode`, `UsualAndCustomaryOption`, `UsualAndCustomaryCustomPF`, `DefaultBasisOfCost`, `IsDiscount`, `ReplacePaymentsWithUandC`), plan limits (`MaxScriptsPerMonth`, `RefillsAllowed`, `DollarsAllowed`, `MonthsToRefillAllowed`, `ClaimsPerTransmission`), and special-program flags (`Is340B`, `WorkersCompSwitch`, `WelfarePriceType`, `BillImmunization`, `SubmitCompoundsMode`, `PercentageTaxExempt`/`FlatTaxExempt`). This is a small, largely-static payer/plan reference table (inferred) referenced elsewhere in the Liberty schema by agency code (e.g. patient/claim tables would carry an `AgencyCode`-shaped column), though no such inbound edges were detected in this extract. `LastUsed`/`LastModified`/`InActive`/`IsValid` suggest standard lifecycle/audit tracking on plan records (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| AgencyCode | varchar(50) | NO | PK | |
| AgencyDescription | varchar(50) | YES | | |
| ProviderIdSource | int | NO | | lookup values: `0` (55), `2` (3) |
| BIN | int | NO | | NCPDP Bank Identification Number for claims routing (inferred) |
| PCN | varchar(50) | NO | | NCPDP Processor Control Number (inferred) |
| PriceFormulaCode | varchar(50) | NO | | |
| WorkersCompSwitch | varchar(50) | YES | | |
| PrescriptionScreenDisplay | varchar(500) | YES | | |
| MaxScriptsPerMonth | int | YES | | |
| WelfarePriceType | varchar(50) | YES | | |
| RefillsAllowed | int | YES | | |
| DollarsAllowed | float | YES | | |
| MonthsToRefillAllowed | int | YES | | |
| NcpdpFormat | varchar(50) | YES | | |
| PlanClassificationCode | char(2) | NO | | lookup values: `"01"` (56), `"  "` (blank, 2) |
| UsualAndCustomaryOption | varchar(50) | YES | | |
| LastUsed | date | YES | | |
| ClaimsPerTransmission | int | YES | | |
| DefaultOtherCoverageCode | char(2) | YES | | lookup values: `"  "` (blank, 58/58 — all sampled rows blank) |
| CompoundBillingNDC | varchar(50) | YES | | |
| ReplacePaymentsWithUandC | bit | YES | | |
| OverrideNcpdpPharmacyServiceType | char(2) | YES | | lookup values: `"  "` (blank, 58/58 — all sampled rows blank) |
| LastModified | datetime | YES | | audit timestamp (inferred) |
| IsValid | bit | YES | | lookup values: `true` (58/58 — all sampled rows true) |
| DirFeeId | varchar(50) | YES | | DIR (direct and indirect remuneration) fee identifier (inferred) |
| InActive | bit | YES | | lookup values: `false` (56), `null` (2) |
| PercentageTaxExempt | bit | NO | | |
| FlatTaxExempt | bit | NO | | |
| DefaultBasisOfCost | nvarchar(2) | YES | | lookup values: `""` (empty string, 58/58 — all sampled rows empty) |
| DefaultSubClarificationCode | varchar(200) | YES | | |
| MedicareCarrierNumber | nvarchar(50) | YES | | |
| Is340B | bit | YES | | 340B drug-pricing program flag (inferred) |
| BillImmunization | int | YES | | |
| SubmitCompoundsMode | int | YES | | lookup values: `0` (56), `null` (2) |
| UsualAndCustomaryCustomPF | varchar(200) | YES | | "PF" = price formula (inferred) |
| RejectionPF | varchar(200) | YES | | |
| IncludeLoyaltyPriceInUC | varchar(50) | YES | | |
| GerGroupId | int | YES | | lookup values: `null` (58/58 — all sampled rows null) |
| IsDiscount | bit | NO | | |
| AllowFormulaOnCOB | bit | NO | | lookup values: `false` (58/58 — all sampled rows false); "COB" = coordination of benefits (inferred) |
| CustomField1 | varchar(50) | YES | | |
| CustomField2 | varchar(50) | YES | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no `implicit_ref` columns detected in this table.
- **Inbound (inferred):** none — no other table's columns were data-validated as referencing `rxqAgency.AgencyCode` in this extract. (Given the naming convention, other Liberty tables likely carry an `AgencyCode`-typed column pointing here, but no such edge was confirmed by data validation, so treat any such relationship as unconfirmed/absent from evidence.)

**Indexes**

None reported (extract returned an empty index list — no explicit non-clustered indexes beyond the implicit PK constraint on `AgencyCode`).

**Gotchas**

- Varchar PK (`AgencyCode`) rather than a surrogate int — typical of Liberty reference tables, but means joins elsewhere must match on string equality/formatting.
- Several columns sampled as uniformly blank/empty/null/false across all 58 rows in this tenant (`DefaultOtherCoverageCode`, `OverrideNcpdpPharmacyServiceType`, `DefaultBasisOfCost`, `GerGroupId`, `AllowFormulaOnCOB`, `IsValid`, `IsDiscount`... note `IsDiscount`/`PercentageTaxExempt`/`FlatTaxExempt` had no lookup entries at all, meaning they weren't in the small-cardinality sample or exceeded distinct-value thresholds) — these may be effectively unused/legacy fields in RXCS specifically; don't assume the same holds for mmed/mdvo tenants without re-sampling.
- Zero declared and zero inferred relationships makes this a schema island in the extract; any consuming code likely joins to it by convention on `AgencyCode` from claims/pricing tables not captured here.
- Not ETL-mirrored into `liberty_link_stage` — eMed-side code needing agency/plan metadata must query Liberty directly, not the mirror.

---

## `rxqAgencyStore`

Rows (RXCS): 5 | Columns: 5 | PK: `StoreNumber`, `AgencyCode` (composite) | ETL-mirrored into liberty_link_stage: no

**Purpose**

Maps a store (`StoreNumber`) to an external agency's provider identifier (`StoreProviderId`) under a given `AgencyCode` — i.e. a per-agency provider-ID crosswalk for the pharmacy store (inferred). "Agency" here likely denotes an external payer/regulatory/network entity that assigns its own provider ID to the store, distinct from Liberty's internal store identifier (inferred). `IsValid` flags whether the mapping is currently active; all 5 sampled rows are `true`, so no inactive/superseded mappings are observed in this instance. `LastModified` supports change tracking/audit of the mapping. No declared or inferred relationships link this table to `rxqStore` or any agency-reference table, so the exact meaning of `AgencyCode` and the target of `StoreProviderId` cannot be confirmed from this metadata alone.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| StoreNumber | varchar(50) | NOT NULL | PK (composite) | No implicit_ref detected despite the name; not validated against a store table |
| AgencyCode | varchar(50) | NOT NULL | PK (composite) | No implicit_ref detected; identifies the external agency |
| StoreProviderId | varchar(50) | NOT NULL | — | Provider ID assigned by the agency for this store (inferred) |
| LastModified | datetime | NULL | — | No default captured |
| IsValid | bit | NULL | — | Sampled values: `true` (5/5 rows) — no `false` rows observed in this instance |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no inferred_relationships recorded for this table (naming/data validation found no confirmed parent-key edges, e.g. for `StoreNumber`/`AgencyCode`).
- **Inbound (inferred):** none — no other table's inferred_relationships point to `rxqAgencyStore`.

All join paths for `StoreNumber` and `AgencyCode` are therefore unconfirmed/absent in the inferred-relationship analysis; treat any assumed link to a store or agency master table as an unverified guess, not a confirmed relationship.

**Indexes**

None captured (indexes list is empty).

**Gotchas**

- Composite varchar PK (`StoreNumber` + `AgencyCode`) — no surrogate/identity key.
- Not ETL-mirrored into liberty_link_stage, so downstream eMed reporting has no visibility into this crosswalk.
- Despite plausible naming, neither PK column resolved to an inferred_relationship — likely because the parent table's key type/values didn't data-validate or the parent table wasn't sampled; do not assume `rxqStore` is the target without direct verification.
- Only 5 rows total in RXCS — too small a sample to generalize `IsValid=false` behavior or the domain of `AgencyCode`.

---

## `rxqAccountReceivable`

Rows: 49,909 (RXCS) · Columns: 27 · PK: `Partition, ARBatch, AccountId, ARType, RecordNumber` (composite) · ETL-mirrored into `liberty_link_stage`: no

**Purpose**

Stores accounts-receivable ledger entries (charges/payments/adjustments) posted against a patient/account, one row per AR record within a batch (`ARBatch`) and partition (`Partition`) (inferred from composite key shape). Each entry carries a monetary `Amount`, optional `TaxAmount`/`TaxRateCode`/`TaxFlag`, an `AppliedToDue` figure, and a `RecordStatus`/`RelStatus` pair suggesting posting/reconciliation state (inferred — no lookup values captured for these two columns). `ARType` is a small coded classifier of entry type (values 0/5/6/7 observed, dominated by 7 — 49,886 of 49,909 rows), consistent with a typical AR transaction-type code (e.g., charge vs. payment vs. adjustment) (inferred; exact meanings not resolvable from this metadata alone). Rows link out to a dispensed prescription via `ScriptNumber` (99.88% referential match to `rxqScriptBase`), tying AR activity to a specific script/fill, and carry supplementary references (`RefillNumber`, `TicketNumber`, `CHECK_NUM`, `ReferenceNumber`) for reconciling to a specific fill, sale ticket, or payment instrument (inferred). `ItemPatientId` plus the indexed `AccountId` suggest AR is tracked both at an account level and an item/patient level (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cAccountReceivableId | int | NO | | identity |
| Partition | varchar(50) | NO | PK | |
| ARBatch | varchar(50) | NO | PK | |
| AccountId | varchar(50) | NO | PK | indexed (IX_AccountReceivable_FamilyIdentification) |
| ARType | int | NO | PK | coded: 7 (49,886), 5 (13), 0 (6), 6 (4) |
| RecordNumber | int | NO | PK | |
| PostDate | date | YES | | |
| RecordStatus | varchar(50) | YES | | no sampled values captured |
| ReferenceNumber | varchar(50) | YES | | |
| Description | varchar(200) | YES | | |
| AppliedToDue | float | YES | | |
| Amount | float | YES | | |
| TaxAmount | float | YES | | |
| TaxRateCode | varchar(50) | YES | | |
| StoreNumber | varchar(50) | YES | | |
| TaxFlag | varchar(50) | YES | | no sampled values captured |
| RelStatus | varchar(50) | YES | | no sampled values captured |
| Comment | varchar(200) | YES | | |
| LastModified | datetime | YES | | |
| IsValid | bit | YES | | coded: true (49,909 — all rows) |
| CreatedDateTime | datetime | YES | | |
| ItemPatientId | nvarchar(50) | YES | | indexed (IX_rxqAccountReceivable_ItemFamilyId) |
| ScriptNumber | int | YES | → rxqScriptBase | |
| RefillNumber | int | YES | | |
| CHECK_NUM | varchar(25) | YES | | |
| TicketNumber | varchar(50) | YES | | |
| AccountReceivableID | int | YES | | distinct from PK `cAccountReceivableId`; likely a legacy/duplicate reference column (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**:
  - `ScriptNumber` → `rxqScriptBase` — inferred, **high** confidence (99.88% referential match, 58 orphans out of 49,910 non-null values; not sampled).
- **Inbound (inferred)**: none.

**Indexes**

- `IX_AccountReceivable_FamilyIdentification` (NONCLUSTERED, non-unique) on `AccountId` — supports account-level AR lookups.
- `IX_rxqAccountReceivable_ItemFamilyId` (NONCLUSTERED, non-unique) on `ItemPatientId` — supports item/patient-level AR lookups.

**Gotchas**

- Primary key is a 5-part composite of mixed types (`varchar` partition/batch/account + `int` type/record-number), not a single surrogate — joins/aggregations must include all five columns to avoid collapsing distinct rows.
- Two similarly-named columns exist: `cAccountReceivableId` (int identity, not part of PK) and `AccountReceivableID` (nullable int, also not part of PK) — likely serve different purposes (surrogate row id vs. a cross-reference id) and should not be assumed interchangeable.
- `RecordStatus`, `RelStatus`, and `TaxFlag` are coded/flag-like varchar columns with no sampled lookup values available here — their domains are undocumented in this extract.
- Not mirrored by ETL into `liberty_link_stage`, so eMed-side reporting cannot currently join against this AR detail without a direct Liberty-side query.

---

## `rxqPatientAccountReceivable`

Rows (RXCS): 14,220 · Columns: 31 · PK: `AccountId` · ETL-mirrored into `liberty_link_stage`: no

**Purpose**
Stores one patient/account-level accounts-receivable ledger summary per `AccountId` — running balance, aging buckets, credit limit, finance/service charge configuration, and last-payment info (inferred: a classic AR aging-bucket design mirroring standard pharmacy-billing/patient-statement modules — `PreviousBalance`, `Over30Days`/`Over60Days`/`Over90Days`/`Over120Days`, `CurrentDebits`, `CurrentCredits`, `TotalBalance`, `AmountDue`). `OwnerPatientId` and the uniquely-indexed `IDX_PatAccRev_OPId` indicate each row is scoped to exactly one owning patient (inferred: 1:1 patient-to-AR-account). Not present in the eMed ETL mirror, so this data is Liberty-side only today.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cPatientAccountReceivableId | int | NO | | identity |
| AccountId | varchar(50) | NO | PK | |
| Lastname | varchar(50) | YES | | |
| FirstName | varchar(50) | YES | | |
| MiddleInitial | varchar(50) | YES | | |
| AccountNumber | int | YES | | indexed (IX_cAccountNumber, non-unique) |
| CreditLimit | int | YES | | |
| FinanceChargeSwitch | int | YES | | lookup values: `0` (14,219), `1` (1) — near-universally off |
| FinanceChargePeriod | varchar(50) | YES | | |
| PrintCode | varchar(50) | YES | | |
| LastPaymentAmount | float | YES | | |
| LastPaymentDate | date | YES | | |
| ResponsibleIdentifier | varchar(50) | YES | | |
| YearToDateInterest | float | YES | | |
| PreviousBalance | float | YES | | |
| AmountDue | float | YES | | |
| Over30Days | float | YES | | aging bucket |
| Over60Days | float | YES | | aging bucket |
| Over90Days | float | YES | | aging bucket |
| Over120Days | float | YES | | aging bucket |
| CurrentDebits | float | YES | | |
| CurrentCredits | float | YES | | |
| TotalBalance | float | YES | | |
| YearToDateMedical | float | YES | | |
| FinanceChargeFlag | varchar(50) | YES | | |
| LastModified | datetime | YES | | |
| IsValid | bit | YES | | lookup values: `true` (14,220) — every sampled row is valid |
| ServiceChargeFlag | varchar(50) | YES | | |
| ServiceChargeAmount | float | YES | | |
| OwnerPatientId | varchar(50) | NO | | uniquely indexed via IDX_PatAccRev_OPId; naming implies one owning patient per account, but not captured as an inferred_relationship edge (no matching `rxqPatient` join validated in the metadata) |
| cAccountReceivablePrintCodeId | int | YES | → rxqAccountReceivablePrintCode | lookup values: `0` (14,220, all rows) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):**
  - `cAccountReceivablePrintCodeId` → `rxqAccountReceivablePrintCode` (join col `cAccountReceivablePrintCodeId`) — inferred, **unvalidated** (parent table empty, no data to check match rate against; all 14,220 sampled values are `0`).
- **Inbound (inferred):** none.

**Indexes**
- `IDX_PatAccRev_OPId` — UNIQUE NONCLUSTERED on `OwnerPatientId` — enforces one AR account row per owning patient; primary lookup path from patient → AR summary.
- `IX_cAccountNumber` — NONCLUSTERED on `AccountNumber` — secondary lookup path by account number.

**Gotchas**
- Both keys are `varchar(50)`: `AccountId` (PK) and `OwnerPatientId`/`ResponsibleIdentifier` — no numeric surrogate join keys despite `AccountNumber` (int) also existing as a separate, differently-indexed field.
- `cAccountReceivablePrintCodeId` is effectively constant (`0` for all 14,220 rows) and its referenced parent (`rxqAccountReceivablePrintCode`) is empty, so this "relationship" is structurally present but currently unconfirmable/inert.
- `OwnerPatientId` strongly resembles a patient FK by name and uniqueness, but the extractor did not surface it as an `implicit_ref`/inferred_relationship — treat any patient join through this column as an unconfirmed convention, not a validated edge.
- Not ETL-mirrored: any eMed-side billing/statement feature needing this AR aging data must source it directly from Liberty, not from `liberty_link_stage`.

---

## `rxqMFP`

Rows: 141 (RXCS) · Columns: 7 · PK: `MfpId` · ETL-mirrored: no (not present in liberty_link_stage)

**Purpose**

Stores a dated price list keyed by `NDC` with an effective/end-date range, a container-level price (`ContainerMfpPrice`), a per-unit price (`UnitMfpPrice`), and a `MfpLastUpdated` stamp. The table name and column naming ("MFP") strongly suggest this holds Maximum Fair Price data — the government-negotiated per-drug pricing introduced under the Medicare Drug Price Negotiation Program (IRA) — used to reference/compare against pharmacy pricing for negotiated-price NDCs (inferred; the metadata contains no lookup values or descriptive text to confirm the "MFP = Maximum Fair Price" expansion, only the column/table naming pattern). The effective-date/end-date pair (inferred) implies this is a versioned reference table, i.e. multiple rows can exist per NDC over time to track price changes.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| MfpId | int | NO | PK | identity |
| NDC | varchar(50) | YES | | no declared/inferred FK; likely joins to a drug table by NDC value (unconfirmed — no inferred_relationships recorded) |
| MfpEffectiveDate | date | YES | | start of price validity period (inferred) |
| MfpEndDate | date | YES | | end of price validity period (inferred) |
| ContainerMfpPrice | decimal(10,2) | YES | | price per container/package (inferred) |
| MfpLastUpdated | date | YES | | last refresh/sync date for this row (inferred) |
| UnitMfpPrice | decimal(10,2) | YES | | price per dispensing unit (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no inferred relationships were detected for this table's columns (notably `NDC`, despite its typical role as a drug-lookup key elsewhere in the schema, has no validated inferred edge here).
- **Inbound (inferred):** none — no other table's columns were inferred to reference `rxqMFP`.

**Indexes**

None reported (no indexes defined on this table).

**Gotchas**

- No indexes at all, including none on `NDC` or the PK beyond the implicit clustered PK constraint — any lookup by NDC or date range would be a table scan (table is small at 141 rows, so low impact today).
- `NDC` is a loosely-typed `varchar(50)` with no inferred/declared FK to a drug table, so referential integrity to whatever drug dimension it's meant to join against is unverified/unenforced.
- Not ETL-mirrored into liberty_link_stage — eMed-side reporting/analytics cannot currently join against this pricing data without a new extract.
- All columns are nullable except the PK, including the price fields and date range, so rows with partial/missing pricing data are possible.

---

## `rxqDrugPricingHistory`

Rows (RXCS): 5,165 | Columns: 6 | PK: `cDrugPricingHistoryId` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores a time-stamped history of drug price changes, keyed to a drug (`DrugId`) and an optional vendor (`VendorId`), tagged with a coded `PriceType` (inferred). It appears to be an audit/history log rather than the operational pricing table used at dispense time (inferred) — there is no operational table in this extract that references it (`inferred_referenced_by` is empty), consistent with a write-once history log that nothing else joins against.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cDrugPricingHistoryId | int | NO | PK | identity |
| DrugId | varchar(50) | YES | → rxqDrug | varchar-typed key (not int) |
| VendorId | int | YES | | no inferred_relationships edge recorded (parent vendor table not matched/validated) |
| PriceType | int | YES | | coded domain (sampled): `2` (3,873), `1` (1,246), `3` (46) |
| LastChanged | datetime | YES | | |
| LastModified | datetime | YES | | distinct from LastChanged — possibly separate audit-timestamp semantics (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

**Outbound (inferred)**
- `DrugId` → `rxqDrug` — inferred, **high** confidence (99.9% referential match: 5,158/5,165 non-null values resolve, 7 orphans; not sampled).

**Inbound (inferred)**
- none

**Indexes**

None reported (empty index list — no declared indexes on this table beyond the implicit PK).

**Gotchas**

- `DrugId` is `varchar(50)`, not int — typical Liberty pattern of string-typed keys joining to `rxqDrug`.
- 7 `DrugId` values (0.14%) don't resolve to `rxqDrug` — likely retired/deleted drug records or data-entry artifacts; not enough to lower confidence off "high".
- `VendorId` has no validated inferred relationship despite the name strongly suggesting a vendor/supplier lookup table — treat any vendor-table join as an unconfirmed guess, not backed by data here.
- `PriceType` is an unlabeled int enum (values 2/1/3 observed); no lookup table available in this extract to decode meaning (e.g., AWP/WAC/cost) — treat as opaque code pending external documentation.
- Not ETL-mirrored to liberty_link_stage, so this history is not queryable from the eMed side without a direct Liberty DB connection.

---

## `rxqPriceUpdateHistory`

Rows (RXCS): 1,742 | Columns: 13 | PK: `id` | ETL-mirrored into liberty_link_stage: no

**Purpose**: Audit/run log for batch price-update jobs that import a price file and reconcile drug pricing across two catalogs, "Rxq" and "Bzq" (inferred — column names `numberOfRxqMatchesFound`/`numberOfBzqMatchesFound`, `numberOfRxqPricesChanged`/`numberOfBzqPricesChanged`, `numberOfItemsAddedToRxqDatabase`/`numberOfItemsAddedToBzqDatabase` imply two parallel drug-price tables, likely `rxqDrug`-family and a "Bzq" counterpart, being synced from the same source file). Each row records one execution: source file (`filePath`), how it was triggered (`startOrigin`), start/end timestamps (`dateStarted`/`dateFinished`), input row count (`numberOfRecordsInFile`), and outcome counts (matches found, prices changed, items added) per catalog. `priceUpdateSettingsId` ties the run to a configuration record (inferred FK, likely `rxqPriceUpdateSettings` or similar — not present in this extract, so unvalidated).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| `id` | int | NO | PK | identity |
| `priceUpdateSettingsId` | int | YES | → (unresolved, likely priceUpdateSettings table) | no implicit_ref detected; inferred by name only, not in inferred_relationships |
| `dateStarted` | datetime | YES | | job start timestamp |
| `dateFinished` | datetime | YES | | job end timestamp |
| `numberOfRecordsInFile` | int | YES | | row count of source price file |
| `numberOfBzqMatchesFound` | int | YES | | matches found in "Bzq" catalog |
| `numberOfRxqMatchesFound` | int | YES | | matches found in "Rxq" catalog |
| `numberOfRxqPricesChanged` | int | YES | | prices updated in Rxq catalog |
| `numberOfBzqPricesChanged` | int | YES | | prices updated in Bzq catalog |
| `numberOfItemsAddedToRxqDatabase` | int | YES | | new items inserted into Rxq catalog |
| `numberOfItemsAddedToBzqDatabase` | int | YES | | new items inserted into Bzq catalog |
| `startOrigin` | nvarchar(50) | YES | | how the run was initiated (e.g. manual/scheduled) — not in lookups, no sampled values available |
| `filePath` | nvarchar(max) | YES | | path of the source price-update file |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**: none. (`priceUpdateSettingsId` looks like an FK by naming convention but produced no `inferred_relationships` entry in this extract — no data-validated target table available; treat as an unconfirmed guess.)
- **Inbound (inferred)**: none.

**Indexes**

- `settings id and date` (NONCLUSTERED, non-unique) on (`priceUpdateSettingsId`, `dateStarted`) — supports lookup of a settings config's run history ordered/filtered by start time.

**Gotchas**

- No FK metadata and no inferred/validated relationships at all in this extract — `priceUpdateSettingsId`'s parent table is unknown from this data alone; corroborate with a `rxqPriceUpdateSettings`-style table if found elsewhere in the schema.
- `lookups` is empty — `startOrigin` is a small coded-looking varchar(50) but no sampled values were captured, so its enum domain is undocumented here.
- Table is a pure audit/run log (counts and timestamps), not itself part of the transactional pricing path — the actual price changes presumably land in the Rxq/Bzq drug tables, not here.

---

## `rxqPriceUpdateSettings`

Rows (RXCS): 3 | Columns: 111 | PK: `id` | ETL-mirrored into liberty_link_stage: no

**Purpose**: Stores configuration profiles for automated pharmacy price-file import jobs — each row (`id`, `type`, `displayName`, `vendorId`) defines one vendor price-update feed and how to fetch, parse, and apply it. Columns cover: remote file retrieval (`serverAddress`/`serverType`/`serverPortOverride`/`serverUsername`/`serverPassword`/`serverDirectory`/`serverFilename`/`serverEncryption`, `tempDirectory`, `removeFileWhenDone`), fixed-width/EDI/flat-file parsing (paired `*Location`/`*Length`/`*Segment` triplets per field, `ediFieldSeperator`/`ediSegmentSeperator`/`ediFileMarker`, `flatFileCharacterDelimeter`, `quotesEncapsulateTextField`, `ignoreHeader`), and per-price-type update flags for both RxQ (retail pharmacy) and BZQ (front-end/OTC "bazaar" merchandise) systems — AWP, ACQ (acquisition cost), WAC, CON (contract), retail, cost, and item-number fields, each with an `implied decimal` precision setting (inferred). `updateOnly340B`/`updateOnlyNon340B` scope updates to 340B-eligible items (inferred). This is an operational/admin settings table for the vendor price-file ETL subsystem inside Liberty itself, distinct from the eMed ETL pipeline (mirrored_by_etl=false — not replicated to liberty_link_stage).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| id | int | NO | PK | identity |
| type | nvarchar(50) | YES | | feed/profile type (inferred; no sampled values — table empty of lookups) |
| displayName | nvarchar(50) | YES | | human-readable label for the profile |
| vendorId | int | YES | | likely → a vendor/supplier table (no `implicit_ref` detected; name suggests FK) |
| printResults | bit | YES | | |
| updateBzq | bit | YES | | apply update to BZQ (bazaar/OTC) system |
| updateRxq | bit | YES | | apply update to RxQ (pharmacy) system |
| fullLoadBzq | bit | YES | | full vs incremental load flag, BZQ |
| fullLoadRxq | bit | YES | | full vs incremental load flag, RxQ |
| tempDirectory | nvarchar(50) | YES | | local staging path for downloaded file |
| removeFileWhenDone | bit | YES | | delete source file after processing |
| serverAddress | nvarchar(max) | YES | | remote host for price file retrieval |
| serverPortOverride | int | YES | | |
| serverType | nvarchar(50) | YES | | e.g. FTP/SFTP (inferred; no sampled values) |
| serverUsername | nvarchar(50) | YES | | |
| serverPassword | nvarchar(50) | YES | | stored in plaintext column (gotcha) |
| serverDirectory | nvarchar(50) | YES | | |
| serverFilename | nvarchar(50) | YES | | |
| serverEncryption | nvarchar(50) | YES | | |
| rxqItemMarker | nvarchar(50) | YES | | fixed-width marker identifying item record in RxQ file |
| rxqItemMarkerLocation | nvarchar(50) | YES | | |
| rxqItemMarkerSegment | nvarchar(50) | YES | | |
| bzqItemMarker | nvarchar(50) | YES | | |
| bzqItemMarkerLocation | nvarchar(50) | YES | | |
| bzqItemMarkerSegment | nvarchar(50) | YES | | |
| allUseDateInsideFile | bit | YES | | |
| allDateLocation | nvarchar(50) | YES | | |
| allDateLength | nvarchar(50) | YES | | |
| allDateSegment | nvarchar(50) | YES | | |
| updateRxqAWP | bit | YES | | update Average Wholesale Price (inferred, NCPDP pricing term) |
| rxqAWPIsPackage | bit | YES | | |
| rxqAWPLocation | nvarchar(50) | YES | | |
| rxqAWPLength | nvarchar(50) | YES | | |
| rxqAWPSegment | nvarchar(50) | YES | | |
| rxqAWPImpliedDecimal | int | YES | | decimal-place shift when parsing raw numeric field |
| updateRxqACQ | bit | YES | | update acquisition cost |
| rxqACQIsPackage | bit | YES | | |
| rxqACQLocation | nvarchar(50) | YES | | |
| rxqACQLength | nvarchar(50) | YES | | |
| rxqACQSegment | nvarchar(50) | YES | | |
| rxqACQImpliedDecimal | int | YES | | |
| updateRxqWAC | bit | YES | | update Wholesale Acquisition Cost |
| rxqWACIsPackage | bit | YES | | |
| rxqWACLocation | nvarchar(50) | YES | | |
| rxqWACLength | nvarchar(50) | YES | | |
| rxqWACSegment | nvarchar(50) | YES | | |
| rxqWACImpliedDecimal | int | YES | | |
| updateRxqCON | bit | YES | | update contract price |
| rxqCONIsPackage | bit | YES | | |
| rxqCONLocation | nvarchar(50) | YES | | |
| rxqCONLength | nvarchar(50) | YES | | |
| rxqCONSegment | nvarchar(50) | YES | | |
| rxqCONImpliedDecimal | int | YES | | |
| updateRxqItemNumber | bit | YES | | |
| rxqItemNumberLocation | nvarchar(50) | YES | | |
| rxqItemNumberLength | nvarchar(50) | YES | | |
| rxqItemNumberSegment | nvarchar(50) | YES | | |
| rxqNameLocation | nvarchar(50) | YES | | |
| rxqNameLength | nvarchar(50) | YES | | |
| rxqNameSegment | nvarchar(50) | YES | | |
| rxqNDCLocation | nvarchar(50) | YES | | NDC = National Drug Code (inferred) |
| rxqNDCLength | nvarchar(50) | YES | | |
| rxqNDCSegment | nvarchar(50) | YES | | |
| bzqNameLocation | nvarchar(50) | YES | | |
| bzqNameLength | nvarchar(50) | YES | | |
| bzqNameSegment | nvarchar(50) | YES | | |
| bzqUPCLocation | nvarchar(50) | YES | | UPC = retail barcode for BZQ items (inferred) |
| bzqUPCLength | nvarchar(50) | YES | | |
| bzqUPCSegment | nvarchar(50) | YES | | |
| updateBzqRetail | bit | YES | | |
| bzqRetailIsCase | bit | YES | | |
| bzqRetailLocation | nvarchar(50) | YES | | |
| bzqRetailLength | nvarchar(50) | YES | | |
| bzqRetailSegment | nvarchar(50) | YES | | |
| bzqRetailImpliedDecimal | int | YES | | |
| updateBzqCost | bit | YES | | |
| bzqCostIsCase | bit | YES | | |
| bzqCostLocation | nvarchar(50) | YES | | |
| bzqCostLength | nvarchar(50) | YES | | |
| bzqCostSegment | nvarchar(50) | YES | | |
| bzqCostImpliedDecimal | int | YES | | |
| updateBzqContract | bit | YES | | |
| bzqContractIsCase | bit | YES | | |
| bzqContractLocation | nvarchar(50) | YES | | |
| bzqContractLength | nvarchar(50) | YES | | |
| bzqContractSegment | nvarchar(50) | YES | | |
| bzqContractImpliedDecimal | int | YES | | |
| updateBzqItemNumber | nvarchar(50) | YES | | note: bit elsewhere but nvarchar(50) here (gotcha) |
| bzqItemNumberLocation | nvarchar(50) | YES | | |
| bzqItemNumberLength | nvarchar(50) | YES | | |
| bzqItemNumberSegment | nvarchar(50) | YES | | |
| bzqNewItemTaxable | bit | YES | | default taxable flag for newly-created BZQ items |
| bzqNewItemDept | nvarchar(50) | YES | | default department for newly-created BZQ items |
| bzqNewItemClass | nvarchar(50) | YES | | default class for newly-created BZQ items |
| ediFieldSeperator | nvarchar(50) | YES | | EDI field delimiter char (sic: "Seperator") |
| ediSegmentSeperator | nvarchar(50) | YES | | EDI segment delimiter char |
| usePhysicalFileChangeDate | bit | YES | | use OS file mtime vs in-file date |
| fileChangeDateLocation | nvarchar(50) | YES | | |
| fileChangeDateLength | nvarchar(50) | YES | | |
| fileChangeDateSegment | nvarchar(50) | YES | | |
| flatFileCharacterDelimeter | nvarchar(50) | YES | | (sic: "Delimeter") |
| bzqMakeMatchesOnUPCOnly | bit | YES | | restrict BZQ item matching to UPC only |
| ignoreHeader | bit | YES | | skip header row/line in import file |
| quotesEncapsulateTextField | bit | YES | | CSV-style quoted text fields |
| updateCompoundPrices | bit | YES | | |
| ediFileMarker | nvarchar(50) | YES | | |
| autoPrintPriceChangeReport | bit | YES | | |
| updateOnly340B | bit | YES | | scope update to 340B program items only |
| updateOnlyNon340B | bit | YES | | scope update to non-340B items only |
| rxqVendorGeneric | varchar(50) | YES | | |
| bzqSendUpdatesToPending | int | YES | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**: none. No `implicit_ref` was detected on any column by the naming-based inference pass. `vendorId` reads like it should reference a vendor table, but no candidate was matched/validated — treat any vendor linkage as an unconfirmed guess (inferred only, not data-validated).
- **Inbound (inferred)**: none.

**Indexes**: none reported.

**Gotchas**
- Only 3 rows exist system-wide (RXCS) — this is a small, hand-maintained admin/config table, not transactional data; expect similarly tiny row counts across mmed/mdvo tenants.
- `serverPassword` is stored as plaintext `nvarchar(50)` — credential-handling risk if this table is ever exposed or copied outside Liberty.
- `updateBzqItemNumber` is typed `nvarchar(50)` while every other sibling `update*` flag in the table is `bit` — likely a schema inconsistency/typo carried forward from legacy Liberty schema design, not a deliberate multi-value flag.
- Two misspelled column names present in source schema: `ediFieldSeperator`/`ediSegmentSeperator` ("Seperator") and `flatFileCharacterDelimeter` ("Delimeter") — preserve as-is when referencing them in queries.
- Heavy repetition of a `*Location`/`*Length`/`*Segment` (and often `*IsPackage`/`*ImpliedDecimal`) column-group pattern per price field (AWP/ACQ/WAC/CON/Retail/Cost/Contract/ItemNumber/Name/NDC/UPC) reflects fixed-width or EDI-segment file-parsing configuration — this table is essentially a per-vendor parser/mapping spec, not clinical or fiscal data itself.
- No lookups/enum values were sampled for any column (table has no small coded columns captured) — do not assume values for `type`/`serverType`/etc.

---

## `rxqPriceFormula`

Rows (RXCS): 13 · Columns: 110 · PK: (`StoreNumber`, `PriceFormulaCode`) · ETL-mirrored into `liberty_link_stage`: no

**Purpose**

Stores per-store pricing-formula definitions used to compute a dispensed drug's price from ingredient/acquisition cost — cost factors, dispense fees, copay-type/amount overrides (brand/generic/alternate), a tiered "break" schedule (up to 25 breakpoints, each with a max-value threshold, an add-on, and a fee), and floor/ceiling controls (`MininumFee`, `MinimumPrice`, `CapCopayToTotal`, `SubtractCopayFromTotal`). (inferred) The formula is keyed by `PriceFormulaCode` per `StoreNumber`, implying pricing rules are configured per store/tenant and referenced elsewhere (e.g. a plan or drug-class pricing table) by that code — no inbound reference was detected in this metadata set, so the consuming table is unconfirmed. With only 13 rows this is a small, largely-static configuration table (pricing "recipes"), not a transactional table.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cPriceFormulaId | numeric(18,0) | NO | | identity |
| StoreNumber | varchar(50) | NO | PK | |
| PriceFormulaCode | varchar(50) | NO | PK | |
| ModeSelect | varchar(50) | YES | | |
| BrandCopayType | varchar(50) | YES | | |
| BrandCopayAmt | float | YES | | |
| GenericCopayType | varchar(50) | YES | | |
| GenericCopayAmt | float | YES | | |
| AlternateCopayType | varchar(50) | YES | | |
| AlternateCopayAmt | float | YES | | |
| CostFactor1 | float | YES | | |
| CostFactor2 | float | YES | | |
| DispenseFee1 | float | YES | | |
| DispenseFee2 | float | YES | | |
| TotalFactorOperator1 | varchar(50) | YES | | |
| TotalFactorOperator2 | varchar(50) | YES | | |
| TotalFactor1 | float | YES | | |
| TotalFactor2 | float | YES | | |
| CostSelect1 | varchar(50) | YES | | |
| CostSelect2 | varchar(50) | YES | | |
| MininumFee | float | YES | | note: misspelled column name as stored |
| BreakMaxValue1‑24 | float | YES | | 24 tiered-breakpoint threshold columns |
| BreakAddOn1‑24 | float | YES | | 24 tiered-breakpoint add-on columns |
| BreakFee1‑25 | float | YES | | 25 tiered-breakpoint fee columns (one more than the AddOn/MaxValue series) |
| Comment | varchar(50) | YES | | |
| LastModified | datetime | YES | | |
| IsValid | bit | YES | | sampled values: `true` (13) — all 13 rows are valid in this sample |
| MinimumPrice | numeric(10,2) | YES | | |
| CapCopayToTotal | bit | NO | | |
| SubtractCopayFromTotal | bit | NO | | |
| CostFactor3 | float | YES | | |
| DispenseFee3 | float | YES | | |
| TotalFactorOperator3 | nvarchar(50) | YES | | |
| TotalFactor3 | float | YES | | |
| CostSelect3 | nvarchar(50) | YES | | |
| ClassOperation | varchar(50) | YES | | |
| Code | varchar(max) | YES | → rxqEcareCode (inferred, low/no match) | |
| BrandCopayMinimumAmt | decimal(5,2) | YES | | |
| GenericCopayMinimumAmt | decimal(5,2) | YES | | |
| ConditionCopaySwitch | bit | YES | | sampled values: `false` (11), `null` (2) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**:
  - `Code` → `rxqEcareCode` (join on `Code`) — inferred, **low** confidence (0.0% referential match; 11 non-null values, 11 orphans, not sampled). Effectively unconfirmed — the naming suggests an eCare-code link but zero of the 11 populated values resolve to `rxqEcareCode`, so treat this as a false lead or a differently-scoped code domain.
- **Inbound (inferred)**: none detected.

**Indexes**

None reported (empty index list in metadata) — no informative named indexes beyond the declared primary key.

**Gotchas**

- No table in the extracted metadata was found referencing `rxqPriceFormula` by `PriceFormulaCode`/`StoreNumber` (inbound list is empty) — the table(s) that actually select a pricing formula per drug/plan/patient are outside this extract, so the practical consumption path can't be confirmed here.
- Composite varchar PK (`StoreNumber` + `PriceFormulaCode`) rather than a surrogate key, despite an identity column (`cPriceFormulaId`) also being present — two competing key candidates.
- Highly repetitive wide-table design: 3 parallel "factor/fee/select" columns (suffix 1-3) plus 24-25 parallel "break" tier columns — a denormalized tiered-pricing schedule flattened into fixed columns rather than a child table.
- `MininumFee` is a misspelling in the actual schema (not a typo introduced here) — don't confuse with `MinimumPrice`.
- Only `IsValid` and `ConditionCopaySwitch` have any observed values in this extract; all other bit/float/varchar columns have no sampled lookup data, so their real-world domains (e.g. valid `ModeSelect`, `CostSelect1-3`, `TotalFactorOperator1-3` values) are unknown from this metadata alone.

---

## `rxqNADACAverageAcq`

Rows (RXCS): 37,934 | Columns: 12 | PK: `NDC` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores the CMS National Average Drug Acquisition Cost (NADAC) reference table, keyed one row per NDC, with the published per-unit acquisition cost, pricing unit, effective date, OTC flag, and drug classification/explanation codes (inferred — column names `NADACPerUnit`, `EffectiveDate`, `PricingUnit`, `ExplanationCode`, `ClassificationforRateSetting`, and `AsOfDate` match CMS NADAC file field naming exactly). It also carries the corresponding generic drug's NADAC per-unit cost and effective date for brand NDCs (inferred — used to compare brand vs. generic reimbursement/acquisition benchmarks). This is a static/reference pricing table, not a transactional table, and is not part of the ETL mirror into liberty_link_stage.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| NDC | varchar(50) | NO | PK | National Drug Code identifier |
| NDCDescription | varchar(500) | YES | | Drug label/description text (inferred) |
| NADACPerUnit | decimal(12,6) | YES | | Published NADAC unit cost |
| EffectiveDate | date | YES | | Date this NADAC value took effect |
| PricingUnit | varchar(50) | YES | | Unit of measure for pricing (e.g. EA/ML/GM) (inferred, no sampled values available) |
| PharmacyTypeIndicator | varchar(50) | YES | | CMS pharmacy-type classification code (inferred, no sampled values available) |
| OTC | bit | YES | | Over-the-counter flag |
| ExplanationCode | varchar(50) | YES | | CMS explanation/footnote code for the NADAC value (inferred, no sampled values available) |
| ClassificationforRateSetting | varchar(50) | YES | | Brand/Generic (or similar) classification used for rate setting (inferred, no sampled values available) |
| CorrespondingGenericDrugNADACPerUnit | decimal(12,6) | YES | | NADAC unit cost of the corresponding generic equivalent (inferred) |
| CorrespondingGenericDrugEffectiveDate | date | YES | | Effective date of the corresponding generic NADAC value (inferred) |
| AsOfDate | date | YES | | Date this reference snapshot/file was current as of (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no `implicit_ref` entries and no inferred_relationships were detected for this table.
- **Inbound (inferred):** none — no other table's columns were inferred to reference this table.

**Indexes**

None reported (no index metadata returned for this table beyond the primary key on `NDC`).

**Gotchas**

- No lookups/coded-value samples were captured for this table, so enum-like columns (`PricingUnit`, `PharmacyTypeIndicator`, `ExplanationCode`, `ClassificationforRateSetting`) have unknown domains here; consult the CMS NADAC file layout for authoritative code lists.
- `NDC` is a varchar PK (not numeric) — format/leading-zero handling should be verified before joining against other NDC columns elsewhere in the schema.
- Purely a reference/lookup table (no declared or inferred relationships to any transactional Liberty tables), so any linkage to order/dispensing tables via NDC would be an application-level join, not schema-evidenced.

---
