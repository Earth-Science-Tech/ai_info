# Liberty schema — Prescriptions & Dispensing

Core prescription lifecycle centered on the rxqScriptBase / rxqScriptTransaction hubs — new and pending scripts, fills and refills, sigs/directions, auxiliary labels, Rx transfers, counseling, reconciliation and voided items.

> Part of the [Liberty/RxQ schema reference](../README.md). Liberty declares **no foreign-key constraints** (verified via `sys.foreign_keys`), so all relationships shown are **inferred from column naming and then data-validated** by referential match rate — each is tagged high / medium / low / no-data / unvalidated confidence. Row counts and sampled enum values are from the RXCS instance (point-in-time); the schema itself is identical across the rxcs / mmed / mdvo tenants.

**Tables in this module (20):** [`rxqScriptBase`](#rxqscriptbase) · [`rxqScriptTransaction`](#rxqscripttransaction) · [`rxqPendingScript`](#rxqpendingscript) · [`rxqProfileOnlyScripts`](#rxqprofileonlyscripts) · [`rxqScriptNumbers`](#rxqscriptnumbers) · [`rxqScriptTemplate`](#rxqscripttemplate) · [`rxqScriptCounsel`](#rxqscriptcounsel) · [`rxqScriptReconcile`](#rxqscriptreconcile) · [`rxqTransfers`](#rxqtransfers) · [`rxqPharmacyTransfer`](#rxqpharmacytransfer) · [`rxqAuditAutoRefill`](#rxqauditautorefill) · [`rxqAuditMedSync`](#rxqauditmedsync) · [`rxqTreatmentSchedule`](#rxqtreatmentschedule) · [`rxqDirection`](#rxqdirection) · [`rxqSigsCodes`](#rxqsigscodes) · [`rxqSigDays`](#rxqsigdays) · [`rxqDrugSigs`](#rxqdrugsigs) · [`rxqAuxiliaryLabels`](#rxqauxiliarylabels) · [`rxqSavedAuxiliaryLabels`](#rxqsavedauxiliarylabels) · [`rxqVoidedItem`](#rxqvoideditem)

---

## `rxqScriptBase`

Rows (RXCS): 573,164 | Columns: 49 | PK: `ScriptNumber` | ETL-mirrored into `liberty_link_stage`: yes (43 of 49 columns mirrored)

**Purpose**

`rxqScriptBase` is the master/header record for a prescription ("script") in the Liberty pharmacy system — one row per script number, holding the drug, prescriber, patient, quantity/refill authorization, and status/hold flags for that Rx (inferred). It is the central hub of the schema: 60+ other tables (billing, workflow, clinical alerts, e-prescribing, cycle-fill, transfers, shipment, counseling, audit) reference it by `ScriptNumber`, consistent with it being the canonical script identity in the dispensing workflow. `LastRefillNumber`/`RefillsAuthorized`/`AvailableQuantity`/`RefillUntilDate` support refill tracking, `CycleFill`/`MedSyncCode` support medication-synchronization programs, `EScriptTransactionId`/`PrescriptionOrigin` support e-prescribing intake (inferred), and `PetsName`/`PetsSpecies` indicate veterinary-Rx support (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cScriptBaseId | numeric(18,0) | No | | identity |
| ScriptNumber | int | No | **PK** | |
| LastRefillNumber | int | Yes | | |
| PatientId | varchar(50) | Yes | → `rxqPatient` | |
| DrugKey | varchar(50) | Yes | → `rxqDrug` | |
| DrugSchedule | varchar(50) | Yes | | likely DEA controlled-substance schedule (inferred; no sampled values) |
| DateWrittenSQL | date | Yes | | date Rx was written (inferred) |
| DoctorId | varchar(50) | Yes | → `rxqDoctor` | |
| FullDispenseQuantity | decimal(9,3) | Yes | | |
| AuthorizedQuantity | decimal(12,3) | Yes | | |
| AvailableQuantity | decimal(12,3) | Yes | | remaining quantity available to fill (inferred) |
| RefillsAuthorized | int | Yes | | |
| NumberOfLabels | int | Yes | | |
| ScriptStatus | int | Yes | | coded domain: 0 (565,150), 3 (8,010), 2 (3), 1 (1) — meaning of codes not in metadata |
| StoreNumber | varchar(50) | Yes | | store/site identifier (inferred) |
| CvtFrom | int | Yes | | "converted from" — likely origin script/system marker (inferred) |
| InjuryDate | date | Yes | | workers'-comp related (inferred) |
| OnHold | varchar(50) | Yes | | hold flag/reason (inferred; no sampled values) |
| TransferSwitch | varchar(50) | Yes | | pharmacy-transfer flag (inferred) |
| RefillUntilDate | date | Yes | | refill expiration date (inferred) |
| EScriptTransactionId | int | Yes | | e-prescribing transaction link (inferred) |
| UsersReference | varchar(50) | Yes | | |
| CycleFill | bit | No | | med-sync cycle-fill flag (inferred) |
| LastModified | datetime | Yes | | audit timestamp |
| IsValid | bit | Yes | | coded domain: true (573,164) — all sampled rows valid |
| OriginationDate | date | Yes | | |
| PetsName | varchar(50) | Yes | | veterinary Rx support (inferred) |
| PetsSpecies | varchar(50) | Yes | | veterinary Rx support (inferred) |
| OfficeUse | bit | Yes | | |
| AccuFloPriority | varchar(50) | Yes | | AccuFlo (fill-automation system) priority tag (inferred) |
| MedSyncCode | int | Yes | | coded domain: 0 (572,831), 1 (308), 3 (14), 7 (9), 2 (2) |
| RxFromNumber | int | Yes | | prior/source script number for transfers-in (inferred) |
| NewScriptNumber | int | Yes | | successor script number, e.g. after change/renewal (inferred) |
| AuthorizedBy | varchar(50) | Yes | | |
| NewDateDone | date | Yes | | |
| PrescriptionOrigin | varchar(50) | Yes | | NCPDP-style origin (paper/electronic/phone/fax) (inferred; no sampled values) |
| EffectiveDate | date | Yes | | |
| XDeaFlag | int | Yes | | DEA-related flag (inferred) |
| OpioidTreatmentType | int | Yes | | coded domain: null (573,164) — always null in sampled RXCS data |
| PRN | bit | Yes | | "as needed" dosing flag |
| DefaultAgencyUpdatedCheck | bit | Yes | | coded domain: false (569,924), null (3,240) |
| DrugUnitMultiplierId | int | Yes | | |
| DataEnteredBy | varchar(50) | Yes | | |
| cNHHomeId | int | Yes | | nursing-home/long-term-care facility link (inferred; not mirrored) |
| DoNotCF | bit | Yes | | "do not cycle-fill" flag (inferred; not mirrored) |
| IsLinked | bit | Yes | | not mirrored |
| StopCfWarning | bit | Yes | | cycle-fill warning suppression (inferred; not mirrored) |
| StopEquivalentCfWarning | bit | Yes | | not mirrored |
| SameChainOrigin | bit | Yes | | coded domain: null (573,164) — always null in sampled data; not mirrored |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

Outbound (inferred):
- `PatientId` → `rxqPatient` (join on `PatientId`) — inferred, **high** confidence (100.0% referential match, sampled)
- `DrugKey` → `rxqDrug` (join on `DrugId`) — inferred, **high** confidence (100.0% referential match, sampled)
- `DoctorId` → `rxqDoctor` (join on `DoctorId`) — inferred, **high** confidence (100.0% referential match, sampled)

Inbound (inferred) — tables whose `ScriptNumber` (or `cScriptBaseId`) values are found in this table's `ScriptNumber`, strongest first:
- **High confidence (>=95% match):** `PendingStockReturn` (100.0%), `rxqScriptCounsel` (100.0%), `rxqScriptDrugBatch` (100.0%), `rxqScriptTransaction` (100.0%), `rxqShipmentScriptNumber` (100.0%), `ScriptTransactionPackageLink` (100.0%), `rxqPatientMessageScriptTransactions` (99.97%, sampled), `rxqScriptTransactionAudit` (99.93%, sampled), `rxqPmpGatewayAudit` (99.9%, sampled), `rxqAccountReceivable` (99.88%, sampled), `rxqRxAlert` (99.81%, sampled), `rxqAuditMedSync` (99.74%, sampled), `rxqScheduleDrugReportLog` (99.64%, sampled), `rxqChangeLogEntry` (99.54%, sampled), `rxqImmunizationInfo` (99.52%, sampled), `rxqWorkFlowItem` (99.47%, sampled), `rxqClinicalInteractionsAndAlertsNotes` (99.43%, sampled), `rxqClinicalInteractionsAndAlerts` (99.42%, sampled), `rxqTransfers` (99.06%, sampled), `rxqAuditAutoRefill` (97.91%, sampled), `StockReturnHistory` via `ScriptNumber` and via `cScriptBaseId` (96.35% each, sampled)
- **Medium confidence (60-95%):** `PrescriptionRequests` (94.44%, sampled), `rxqCancelRx` (91.79%, sampled), `rxqEScript` (78.75%, sampled)
- **Low confidence (<60%) — weak/unconfirmed:** `rxqProfileOnlyScripts` (50.0%, sampled), `rxqDrugCompoundPending` (0.78%, sampled), `rxqProblemQueue` (0.69%, sampled), `rxqAuxiliaryLabels` (0%, sampled), `rxqPendingStockReturn` (0%, sampled), `rxqScriptReconcile` (0%, sampled)
- **No-data (parent table empty at sample time, unconfirmed):** `BillingEvents`, `BillingStatus`, `BinAssignmentHistory`, `CentralFillDeliveryAudit`, `CentralFillScriptDetails`, `ECRSSubmission`, `LtcOutboundMessage`, `PickUpNotes`, `PriorAuthorizationRequests`, `QuestionnaireReview`, `rxqAccountReceivableHistory`, `rxqCycleFillAuthorization`, `rxqDUR`, `rxqImmunizationSubmission`, `rxqInterfaceSubmission`, `rxqNcpdpNarrative`, `rxqOnlineHistory`, `rxqResubmit`, `rxqRxChangeRequest`, `rxqScheduledDiscontinuation`, `rxqScriptDrugSplit`, `rxqScriptIOU`, `rxqScriptPartial`, `rxqScriptPayments`, `rxqSpecialtySubmission`, `rxqThirdPartyAccountingAmountExpected`, `rxqUnitDose`, `rxqUnitDoseIndividual`, `rxqWorkComp`, `rxqWorkCompPayment`, `rxqWorkFlowFaxHistory`, `rxqWorkFlowMedSyncCall`, `rxqWorkflowNDCScanHistory`, `ScriptNotes`, `ScriptOperations`, `WorkFlowNotes`

**Indexes**

- `IX_cScriptBase`, `IX_rxqScriptBase_Script_PatientId`, `IX_ScriptBase_WaitingBin` — all on `ScriptNumber` (the PK) with varying INCLUDE payloads, indicating multiple hot lookup paths keyed by script (patient lookup, waiting-bin/fill-queue lookup).
- `IX_ScriptBase_DoctorId` and `IX_ScriptBase_DoctorID_DateWrittenSQL` — prescriber-centric lookups (e.g. prescriber Rx history by date).
- `IX_ScriptBase_DrugKey` — drug-centric lookup (e.g. recall/utilization queries).
- `IX_ScriptBase_PatientId_OnHold` — patient hold-queue lookup (INCLUDEs `ScriptNumber`, `LastRefillNumber`).
- `IX_ScriptBase_StoreNumber` — per-store queries (multi-site support).
- `IX_rxqScriptBase_MedSyncCode` — med-sync program queue lookup (INCLUDEs `ScriptNumber`, `PatientId`, `DrugKey`, `DoctorId`, `AvailableQuantity`, `RefillUntilDate`).
- Wide `_dta_index_...` composite covering index exists but is an auto-tuner artifact, not a documented access path.

**Gotchas**

- Business/natural key columns (`PatientId`, `DrugKey`, `DoctorId`, `StoreNumber`) are all `varchar(50)` rather than typed IDs, despite joining to what are presumably numeric/coded parent keys (e.g. `DrugKey` → `rxqDrug.DrugId`) — no declared FK, so type/format drift between tables is possible and unenforced.
- `cScriptBaseId` (identity numeric surrogate) vs `ScriptNumber` (business-key int, actual PK) are two distinct identifiers on the same row; `StockReturnHistory` references this table via both, so downstream joins must be careful which one is used.
- Several columns sampled as constant/always-null in RXCS data (`OpioidTreatmentType`, `SameChainOrigin`, always null; `IsValid` always true) — may be populated differently in mmed/mdvo tenants or reserved for unused functionality; don't assume they're dead columns schema-wide.
- 6 columns (`cNHHomeId`, `DoNotCF`, `IsLinked`, `StopCfWarning`, `StopEquivalentCfWarning`, `SameChainOrigin`) exist in Liberty but are NOT in the ETL mirror to `liberty_link_stage` — long-term-care and cycle-fill-warning flags are invisible to eMed.
- `ScriptStatus` and `OnHold`/`PrescriptionOrigin`/`DrugSchedule` are coded/flag columns without a documented lookup table in this metadata beyond the sampled numeric domain for `ScriptStatus` — treat code meanings as unconfirmed pending a Liberty reference table or vendor documentation.
- Many inbound "no-data" edges reflect empty tables at sampling time only — absence of evidence, not evidence of absence; re-validate before relying on them.

---

## `rxqScriptTransaction`

Rows (RXCS): 602,607 | Columns: 155 | PK: (`ScriptNumber`, `RefillNumber`) | ETL-mirrored into `liberty_link_stage`: yes

**Purpose**: Stores the per-fill (script × refill) transaction/dispensing record — pricing (Cost, Fee, Tax, Copay, Total, AWP/ACQ/NADAC), NCPDC/NCPDP third-party claim fields (basis-of-cost, reject codes, prior-auth, DAW, submission-clarification codes), and workflow/fulfillment state (WorkFlowStatus, WorkflowLocation, cQueueId, pickup/promise/print timestamps, problem flags) for a single dispense event (inferred). It is the operational fact table that ties a prescription (`rxqScriptBase`, via `ScriptNumber`) to a specific drug lot (`rxqDrug`), a workflow queue (`rxqQueue`), and a third-party payer/plan (`rxqPatientThirdParty`, via `AgencySequence`) at the time of that fill (inferred). `rxqScriptTransactionAudit` references it back by `cScriptTransactionId`, suggesting this table also drives change-history/audit tracking of each transaction (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cScriptTransactionId | numeric(18,0) | No | | identity |
| ScriptNumber | int | No | PK, → rxqScriptBase | |
| RefillNumber | int | No | PK | |
| AdministrativeCharge | decimal(9,2) | Yes | | |
| Agency | varchar(50) | Yes | | |
| AuthorizationNumber | varchar(50) | Yes | | |
| ChargeCode | varchar(50) | Yes | | |
| Copay | decimal(9,2) | Yes | | |
| Cost | decimal(9,2) | Yes | | |
| CostBase | varchar(50) | Yes | | |
| CountedByUser | varchar(50) | Yes | | |
| CouponAmount | decimal(9,2) | Yes | | |
| CouponNumber | varchar(50) | Yes | | |
| CouponType | varchar(50) | Yes | | |
| DateDispensedSQL | date | Yes | | |
| DaysSupply | varchar(50) | Yes | | |
| DeliveryCharge | decimal(9,2) | Yes | | |
| DenialClarification | varchar(50) | Yes | | |
| DiagnosisCode | varchar(50) | Yes | | |
| Discount | varchar(50) | Yes | | |
| DispenseAsWritten | varchar(50) | Yes | | |
| DrugId | varchar(50) | Yes | → rxqDrug | |
| ExpirationDate | date | Yes | | **Per-fill beyond-use date of the dispensed product** (Peaks compounds: mostly 45–180 days after `DateDispensedSQL`), NOT the script's validity — that is `rxqScriptBase.RefillUntilDate`. Gating refill eligibility on this column refused ~63% of refillable Peaks scripts (eMed 1.0.296 fix, 2026-09-02). |
| Fee | decimal(9,2) | Yes | | |
| Icd9Code | varchar(50) | Yes | → rxqIcd9 (unconfirmed, see Relationships) | |
| LevelOfService | varchar(50) | Yes | | |
| LoggedInUser | varchar(50) | Yes | | |
| LotNumber | varchar(50) | Yes | | |
| NCPDCAmountDue | varchar(50) | Yes | | |
| NCPDCBasisOfCost | varchar(50) | Yes | | |
| NCPDCCustomerLocation | varchar(50) | Yes | | |
| NCPDCDenialClarification | varchar(50) | Yes | | |
| NCPDCDispenseAsWritten | varchar(50) | Yes | | |
| NCPDCDispensingFee | varchar(50) | Yes | | |
| NCPDCEligabilityClarification | varchar(50) | Yes | | |
| NCPDCGrossAmountDue | varchar(50) | Yes | | |
| NCPDCIngredientCost | varchar(50) | Yes | | |
| NCPDCLevelOfService | varchar(50) | Yes | | |
| NCPDCOtherPayorAmount | varchar(50) | Yes | | |
| NCPDCPatientPaidAmount | varchar(50) | Yes | | |
| NCPDCPriorAuthorizationCode | varchar(50) | Yes | | |
| NCPDCPriorAuthorizationNumber | varchar(50) | Yes | | |
| NCPDCSalesTax | varchar(50) | Yes | | |
| NCPDCUsualCustomaryCharge | varchar(50) | Yes | | |
| NursingHome | varchar(50) | Yes | | |
| OtherCharge | decimal(9,2) | Yes | | |
| OtherCoverageCode | varchar(50) | Yes | | |
| PaidSwitch | varchar(50) | Yes | | |
| PaidDate | date | Yes | | |
| PcnNumber | varchar(50) | Yes | | |
| PosScanFlag | varchar(50) | Yes | | |
| PostageCharge | decimal(9,2) | Yes | | |
| PriceFormula | varchar(50) | Yes | | |
| PriceFormulaOriginal | varchar(50) | Yes | | |
| PrimaryRejectedFlag | varchar(50) | Yes | | |
| QuantityDispensed | decimal(9,3) | Yes | | |
| RequestedACQ | decimal(9,2) | Yes | | |
| RequestedAWP | decimal(9,2) | Yes | | |
| RequestedCON | decimal(9,2) | Yes | | |
| RequestedCopay | decimal(9,2) | Yes | | |
| RequestedDiscount | decimal(9,2) | Yes | | |
| RequestedFee | decimal(9,2) | Yes | | |
| RequestedTax | decimal(9,2) | Yes | | |
| RequestedTotal | decimal(9,2) | Yes | | |
| RphInitials | varchar(50) | Yes | | |
| RxpIndicator | varchar(50) | Yes | | |
| ShippingCharge | decimal(9,2) | Yes | | |
| Sigs | nvarchar(500) | Yes | | |
| StoreNumber | varchar(50) | Yes | | |
| Tax | decimal(9,2) | Yes | | |
| TimeStampAsOfDate | date | Yes | | |
| Total | decimal(9,2) | Yes | | |
| TriplicateSerialNumber | varchar(50) | Yes | | |
| UnitDoseIndicator | varchar(50) | Yes | | |
| UsualAndCustomary | decimal(9,2) | Yes | | |
| UsualAndCustomarySwitch | varchar(50) | Yes | | |
| WorkersCompFormType | varchar(50) | Yes | | |
| WorkFlowStatus | varchar(50) | Yes | | |
| LastModified | datetime | Yes | | |
| IsValid | bit | Yes | | sampled value: true (602,607/602,607 — 100%) |
| NCPDPProcedureModifierCodes | varchar(50) | Yes | | |
| NCPDPSubmissionClarificationCodes | varchar(50) | Yes | | |
| NCPDPDelayReasonCode | char(2) | Yes | | |
| NCPDPRouteOfAdministration | varchar(50) | Yes | | |
| IncentiveAmount | decimal(9,2) | Yes | | |
| NCPDPRejectCodes | varchar(200) | Yes | | |
| NCPDPResponsePricingSegment | varbinary(max) | Yes | | |
| IntermediaryAuthorizationType | varchar(50) | Yes | | |
| IntermediaryAuthorization | varchar(50) | Yes | | |
| PackingListNumber | int | Yes | | |
| WorkflowLocation | int | Yes | | coded domain (sampled top values): 1003 (522,091), 1008 (40,416), 0 (36,396), 1025 (806), 1010 (696), 1031 (425), 1019 (366), 1033 (312), 1009 (256), 1018 (251), 1021 (208), 1027 (149), 1035 (129), 1037 (34), 1032 (22), 1015 (21), 1038 (11), 1006 (8), 1022 (5), 50 (2), 1020 (1), 1017 (1), 1007 (1) |
| DecodedSigs | nvarchar(500) | Yes | | |
| PosPickupDateTime | datetime | Yes | | |
| cQueueId | int | Yes | → rxqQueue | |
| PickupPatientId | varchar(50) | Yes | | |
| PickupDriversLicense | varchar(50) | Yes | | |
| PickupRelationship | varchar(50) | Yes | | |
| HcfaResubmitCode | varchar(100) | Yes | | |
| HcfaOriginalReferenceCode | varchar(100) | Yes | | |
| HcfaPriorAuthorization | varchar(100) | Yes | | |
| AccountId | varchar(50) | Yes | | |
| ManualPriceChangeUser | varchar(50) | Yes | | |
| EstimatedDirFee | decimal(9,2) | Yes | | |
| DiagnosisCodeType | varchar(50) | Yes | | |
| PromiseDateTime | datetime | Yes | | |
| PickupTimeType | varchar(50) | Yes | | |
| HasProblem | bit | Yes | | |
| WorkQueueNote | varchar(1026) | Yes | | |
| ProblemCategory | varchar(256) | Yes | | |
| PrintLabelDateTime | datetime | Yes | | |
| Printed | bit | Yes | | |
| WorkflowLock | nvarchar(max) | Yes | | |
| CountImage | varchar(256) | Yes | | |
| NextDispensedQuantity | decimal(9,3) | Yes | | |
| TimeStampComputerDateTime | datetime | Yes | | |
| AgencySequence | int | Yes | → rxqPatientThirdParty | |
| PartialFill | int | Yes | | |
| eVoucherAmount | decimal(9,2) | Yes | | |
| WholesalerRebateAmount | decimal(9,3) | Yes | | |
| Confirmed | int | Yes | | |
| Source | varchar(50) | Yes | | |
| PrescriptionDirectionOverflowPrinted | bit | Yes | | |
| AdminSite | varchar(5) | Yes | | |
| TelephoneAuthorizedBy | varchar(200) | Yes | | |
| TelephoneReceivingRph | varchar(200) | Yes | | |
| ArPosted | bit | Yes | | |
| TransactionNumber | int | Yes | | |
| RequestedIncentiveFee | decimal(9,3) | Yes | | |
| RequestedAdministrativeFee | decimal(9,3) | Yes | | |
| PartialPaymentType | int | Yes | | coded domain: 0 (599,297), null (3,276), 1 (34) |
| DaySupplyInsuranceOverride | int | Yes | | |
| VisDate | date | Yes | | |
| VisVersion | varchar(50) | Yes | | |
| NADAC | decimal(12,6) | Yes | | |
| StoreNumberInventory | varchar(50) | Yes | | |
| QuestionnaireReviewId | uniqueidentifier | Yes | | |
| DrugUnitMultiplierId | int | Yes | | |
| DecodedEnglishSigs | nvarchar(500) | Yes | | |
| AppointmentBookingId | uniqueidentifier | Yes | | |
| PrintFirstLabelDateTime | datetime | Yes | | |
| PrintFirstLabelInitials | varchar(50) | Yes | | |
| PatientWaiting | bit | Yes | | |
| PickupPreference | int | Yes | | |
| CentralFillServiceFee | decimal(9,2) | Yes | | |
| PatientThirdPartyId | int | Yes | | |
| DeliveryStatus | int | Yes | | sampled value: null (602,607/602,607 — 100%, column entirely unpopulated in this sample) |
| AverageAcq | decimal(18,4) | Yes | | |
| AdherenceType | int | Yes | | coded domain: null (517,297), 0 (85,265), 1 (26), 3 (19) |
| BinId | int | Yes | | |
| LastAssignedBin | int | Yes | | |
| DrugType | int | Yes | → rxqDirFees (unvalidated, see Relationships) | coded domain: null (526,050), 0 (76,556), 1 (1) |
| AACUnderpaid | bit | Yes | | |
| AACPrinted | bit | Yes | | |
| AccountReceivableID | int | Yes | | |
| RequestedWAC | decimal(15,2) | Yes | | |

Not ETL-mirrored to `liberty_link_stage` (present in Liberty but absent from `mirrored_columns`): `PickupPreference`, `CentralFillServiceFee`, `PatientThirdPartyId`, `DeliveryStatus`, `AverageAcq`, `AdherenceType`, `BinId`, `LastAssignedBin`, `DrugType`, `AACUnderpaid`, `AACPrinted`, `AccountReceivableID`, `RequestedWAC`.

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- Outbound (inferred):
  - `ScriptNumber` → `rxqScriptBase` — inferred, **high** confidence (100.0% referential match, sampled).
  - `DrugId` → `rxqDrug` — inferred, **high** confidence (100.0% referential match, sampled).
  - `cQueueId` → `rxqQueue` — inferred, **high** confidence (100.0% referential match, sampled).
  - `AgencySequence` → `rxqPatientThirdParty` — inferred, **high** confidence (99.97% referential match, sampled; 68 orphans out of 200,000 non-null sampled values).
  - `Icd9Code` → `rxqIcd9` — inferred, **low** confidence (0.0% referential match, sampled — all 200,000 sampled non-null values were orphans; column naming suggests this link but data does not confirm it — treat as unconfirmed/likely-wrong join).
  - `DrugType` → `rxqDirFees` — **unvalidated** (parent table `rxqDirFees` is empty in this instance, so match rate could not be computed; do not rely on this edge).

- Inbound (inferred):
  - `rxqScriptTransactionAudit.cScriptTransactionId` → this table — inferred, **high** confidence (99.9% referential match), consistent with an append-only audit/history trail keyed to this table's identity column.

**Indexes** (join/lookup-relevant; auto-tuning `_dta_`/`missing_index_` entries omitted except where they reveal real access patterns)

- Clustered on `DateDispensedSQL` (`_dta_index_rxqScriptTransaction_c_195_558625033__K18`) — the table's physical sort order is by dispense date, not by PK.
- `IX_cScriptTransaction` (`ScriptNumber`) and `IX_rxqScriptTransaction_cScriptTransactionId_ScriptNumber` (`cScriptTransactionId` incl. `ScriptNumber`) — support lookups both by the natural PK and by the identity surrogate.
- `IDX_rxqScriptTransaction_WorkflowStatus_HasProblem` (`WorkFlowStatus`, `HasProblem`), `IX_ScriptTransaction_HasProblem`, `missing_index_2_1_rxqScriptTransaction` (`HasProblem`), `missing_index_19_18_rxqScriptTransaction` (`WorkFlowStatus`, `DateDispensedSQL`, `HasProblem`) — heavy access pattern around workflow/problem-queue triage screens.
- `IX_ScriptTransactionWorkflowStatus` (`WorkflowLocation`, `DateDispensedSQL`), `IX_rxtRxReport_StoreQty_Incls` (`StoreNumber`, `QuantityDispensed`), `IX_rxqScriptTrans_DateDispSQL_incls` / `IX_ScriptTransaction_DateDispensedSQL[_Included]` (`DateDispensedSQL`) — dispensing/reporting scans by date and store.
- `IX_ScriptTransaction_Agency` (`Agency`), `IX_ScriptTransaction_DrugId_DateDispensedSQLInclude` (`DrugId`, `DateDispensedSQL`) — payer- and drug-scoped lookups.
- `IX_rxqScriptTransaction_AppointmentBookingId` (`AppointmentBookingId` incl. `LastModified`) and `IX_rxqScriptTransaction_BinId` (`BinId`) — support appointment-booking and pick-bin workflows (both are ETL-unmirrored columns, so these access paths are Liberty-internal only).
- `IX_rxqScriptTransactionPackingList` (`PackingListNumber`) — shipping/packing-list lookups.
- `IDX_ScriptTransaction_LastModified_ScriptFill` / `IX_TimeStampComputerDateTime` — change-tracking / CDC-style scans by modification timestamp.

**Gotchas**

- Composite PK is (`ScriptNumber`, `RefillNumber`) — a business-key PK, not the identity `cScriptTransactionId`; joins from other tables use either key depending on whether they target the row identity (audit table) or the business fill (most others).
- Most "coded"/enum-looking fields (`DaysSupply`, `Discount`, `DispenseAsWritten`, all `NCPDC*` fields, `WorkFlowStatus`, etc.) are typed `varchar(50)` rather than int/lookup tables — free-text-capable columns carrying what are effectively NCPDC/NCPDP claim-segment codes.
- `Icd9Code` → `rxqIcd9` looks like an obvious FK by name but is data-invalidated (0% match) — do not treat it as a reliable join; the values likely aren't stored in the same format/domain as `rxqIcd9`'s key (inferred).
- `DrugType` → `rxqDirFees` cannot be validated because `rxqDirFees` is empty in this snapshot; treat as speculative.
- 13 columns exist in Liberty but are NOT in the ETL's mirrored column list (see table above) — anything built in `liberty_link_stage` cannot use `DeliveryStatus`, `AdherenceType`, `DrugType`, `BinId`, etc.; `DeliveryStatus` is additionally 100% null in this sample regardless.
- `WorkflowLocation` and `cQueueId` are both int-coded workflow/queue identifiers but are distinct columns pointing at different concepts (queue vs. location) — don't conflate them.
- Heavy duplication of pricing fields as "Requested" vs. actual (e.g., `RequestedAWP`/`AWP` via `RequestedACQ`, `RequestedCopay`/`Copay`, `RequestedFee`/`Fee`) reflects NCPDC claim request-vs-response segments (inferred) — pick the correct one per use case (submitted claim vs. adjudicated/paid result).

---

## `rxqPendingScript`

Rows (RXCS): 501,678 | Columns: 35 | PK: `TransactionId` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Tracks scripts (or script images/transactions) awaiting fill/pickup action in a pharmacy workqueue — columns like `ScriptStatus`, `cQueueId`, `PickedUp`, `PickupTimeType`, `PatientWaiting`, `IsUrgent`, `HasProblem`/`ProblemCategory`/`ProblemNote`, and `FilledBy` describe a workflow state machine for processing a pending prescription (inferred). `TransactionType` distinguishes two transaction kinds (values 1 and 2, meaning not decoded in metadata) and `eScriptTransactionId` suggests linkage to inbound e-prescribing (SureScripts-style) transactions (inferred). A large cluster of `Transfer*` columns (`TransferScriptNumber`, `TransferRefillNumber`, `TransferStoreId`, `TransferProfileRowString`, `TransferPatient3PList`, `TransferStoreRecordString`, `TransferPatientString`) plus `LastDrugString`/`OrigDrugString` indicate this table also captures pharmacy-to-pharmacy script transfer payloads, likely serialized snapshot strings rather than normalized data (inferred). `ImageFileName` implies a scanned hardcopy/e-script image is associated per row (inferred). Despite naming that suggests FKs to `rxqPatient`, `rxqQueue`, and `rxqDrug`, actual data-validated match rates for all three are effectively zero on this sampled data (see Relationships) — so this table may largely hold historical/transient or transfer-sourced rows whose PatientId/DrugId/cQueueId values don't resolve against the current parent tables (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cPendingScriptId | int | NO | | identity |
| TransactionId | int | NO | PK | |
| TransactionType | int | YES | | lookup values: 2 (400,596), 1 (101,082) |
| ImageFileName | varchar(60) | YES | | |
| PickedUp | datetime | YES | | |
| PickupTimeType | varchar(50) | YES | | |
| ScriptStatus | int | YES | | lookup values: 2 (480,417), 3 (21,062), 1 (190), 4 (9) |
| PatientId | varchar(50) | YES | → rxqPatient | varchar-typed key |
| Created | datetime | YES | | |
| eScriptTransactionId | int | YES | | |
| LastModified | datetime | YES | | |
| IsValid | bit | YES | | lookup values: true (501,678) — all-true in sample |
| FilledBy | varchar(50) | YES | | |
| StoreNumber | varchar(50) | NO | | |
| cQueueId | int | YES | → rxqQueue | lookup values: 0 (501,674), 3 (2), 6 (1), 9 (1) |
| TransferScriptNumber | int | YES | | |
| TransferRefillNumber | int | YES | | |
| TransferStoreId | int | YES | | |
| TransferProfileRowString | varchar(max) | YES | | serialized transfer payload |
| TransferPatient3PList | varchar(max) | YES | | serialized transfer payload |
| TransferStoreRecordString | varchar(max) | YES | | serialized transfer payload |
| LastDrugString | varchar(max) | YES | | |
| OrigDrugString | varchar(max) | YES | | |
| Comment | varchar(max) | YES | | |
| HasProblem | bit | YES | | |
| ProblemCategory | varchar(256) | YES | | |
| ProblemNote | varchar(max) | YES | | |
| AddedBy | varchar(50) | YES | | |
| DrugId | varchar(50) | YES | → rxqDrug | varchar-typed key |
| NumberOfRXs | int | YES | | |
| TransferPatientString | nvarchar(max) | YES | | serialized transfer payload |
| IsUrgent | bit | YES | | |
| AppointmentId | uniqueidentifier | YES | | |
| PatientWaiting | bit | YES | | |
| HasScriptPlan | int | YES | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**
  - `PatientId` → `rxqPatient` — inferred, **low** confidence (13.1% referential match, sampled)
  - `cQueueId` → `rxqQueue` — inferred, **low** confidence (0.0% referential match, sampled)
  - `DrugId` → `rxqDrug` — inferred, **low** confidence (0.0% referential match, sampled)
- **Inbound (inferred)**: none

All three outbound edges are naming-based guesses that data validation largely refutes (match rates 13.1%, 0%, 0%) — treat as weak/unconfirmed; the columns may reference different/legacy value spaces (e.g. transfer-source patient/drug identifiers) rather than the current `rxqPatient`/`rxqQueue`/`rxqDrug` tables.

**Indexes**

- `IDX_PendingScript_Transactionid_Created_ScStatus_Store` (nonclustered): `TransactionId`, `Created`, `ScriptStatus`, `StoreNumber` — primary workqueue access path (status/store/time ordering).
- `IX_PendingScript_eScriptTransactionId` (nonclustered): `eScriptTransactionId` — lookup by inbound e-script transaction.
- `IX_PendingScript_ScriptStatus` (nonclustered): `ScriptStatus` — status-filtered queue scans.
- `IX_PendingScript_StoreNumber_HasProblem` (nonclustered): `StoreNumber`, `HasProblem` — per-store problem-queue triage.

**Gotchas**

- `PatientId` and `DrugId` are varchar(50) rather than typed/int FKs, and both show near-zero data-validated match against `rxqPatient`/`rxqDrug` — do not assume joinability without checking actual values first.
- `cQueueId` is overwhelmingly 0 (501,674 of ~501,678 sampled rows) — near-constant, low discriminating value, and doesn't resolve to `rxqQueue` in this sample.
- Heavy use of `varchar(max)`/`nvarchar(max)` "String" columns (`TransferProfileRowString`, `TransferPatient3PList`, `TransferStoreRecordString`, `LastDrugString`, `OrigDrugString`, `TransferPatientString`) suggests denormalized serialized blobs (e.g. transfer snapshots) coexisting with normalized columns — treat as opaque payloads, not queryable structured data.
- Not mirrored by ETL into liberty_link_stage — any cross-system reporting needs a direct Liberty read.
- `TransactionType` and `ScriptStatus` are coded ints with no decoded label metadata available here — only value/count pairs sampled; consult Liberty application code/docs for meaning.

---

## `rxqProfileOnlyScripts`

Rows (RXCS): 2 | Columns: 14 | PK: `KeyId` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores drug entries carried on a patient's profile/medication list that are not (or not yet) active dispensed scripts — a "profile-only" or medication-history line. Each row ties a patient (`PatientId`) and drug (`DrugKey`) to prescribing/order details (`DoctorId`, `QtyWritten`, `DaysSupply`, `Sigs`/`CodedSigs`, `Discontinue` date) and optionally a real script (`ScriptNumber`, `RefillNumber`), plus a flag (`IncludeOnMedSheets`) controlling whether the entry prints on medication administration/med sheets (inferred). The weak/partial link from `ScriptNumber` to `rxqScriptBase` (50% match in this tiny sample) is consistent with these being patient-profile med-list entries that may or may not correspond to an actual filled script — e.g. a doctor-reported home med with no in-house Rx (inferred). Table is extremely small in RXCS (2 rows) at point-in-time capture, so all match-rate/lookup stats below are low-confidence due to sample size.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| KeyId | int | NO | PK | identity |
| PatientId | varchar(50) | NO | → rxqPatient | |
| DrugKey | varchar(50) | NO | → rxqDrug | joins to rxqDrug.DrugId |
| PharmacyId | varchar(50) | YES | | no inferred ref detected |
| DateAdded | datetime | NO | | |
| QtyWritten | decimal(9,2) | YES | | |
| DaysSupply | decimal(9,2) | YES | | |
| Sigs | nvarchar(500) | YES | | free-text directions |
| Discontinue | date | YES | | discontinue/end date of profile entry |
| ScriptNumber | varchar(50) | YES | → rxqScriptBase | weak link, see Relationships |
| RefillNumber | varchar(50) | YES | | stored as varchar despite numeric meaning |
| DoctorId | varchar(50) | YES | → rxqDoctor | |
| IncludeOnMedSheets | bit | YES | | |
| CodedSigs | varchar(500) | YES | | coded/structured sig representation alongside free-text `Sigs` |

No columns present in `lookups` (none sampled/coded-domain data available).

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

All edges below are INFERRED from column naming and DATA-VALIDATED against actual key values in this RXCS instance — not enforced constraints. Given the table has only 2 rows, match rates are based on a very small population and should be treated cautiously.

- **Outbound (inferred):**
  - `PatientId` → `rxqPatient` (join on `PatientId`) — inferred, **high** confidence (100.0% referential match, 2 non-null, 0 orphans)
  - `DrugKey` → `rxqDrug` (join on `DrugId`) — inferred, **high** confidence (100.0% referential match, 2 non-null, 0 orphans)
  - `DoctorId` → `rxqDoctor` (join on `DoctorId`) — inferred, **high** confidence (100.0% referential match, 2 non-null, 0 orphans)
  - `ScriptNumber` → `rxqScriptBase` (join on `ScriptNumber`) — inferred, **low** confidence (50.0% referential match, 2 non-null, 1 orphan)
- **Inbound (inferred):** none

**Indexes**

- `Patient_Drug` (NONCLUSTERED, non-unique) on (`PatientId`, `DrugKey`) — supports lookup of a patient's profile-only drug entries, matching the outbound `PatientId`/`DrugKey` relationships.

**Gotchas**

- All FK-like columns (`PatientId`, `DrugKey`, `PharmacyId`, `ScriptNumber`, `DoctorId`) are typed varchar(50) rather than matching the likely int/identity types of their parent tables — typical Liberty pattern of loosely-typed pseudo-keys with no enforced constraint.
- `RefillNumber` is varchar despite representing a numeric refill count.
- `ScriptNumber` is only a partial/optional link (50% match on this tiny sample, 1 orphan) — treat rows with a populated `ScriptNumber` as possibly-linked to `rxqScriptBase`, not guaranteed; a null `ScriptNumber` likely indicates a pure profile/med-history entry with no corresponding dispensed script.
- Table not mirrored by ETL into liberty_link_stage — not queryable from the eMed side without a direct Liberty DB connection.
- Row count (2) is a point-in-time RXCS snapshot only; this table may be far larger/smaller and behave differently across tenants or over time.

---

## `rxqScriptNumbers`

Rows (RXCS): 5 | Columns: 9 | PK: `StoreNumber` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Store-level configuration/counter table holding the current numbering-scheme state for script (prescription) number assignment, one row per pharmacy store (`StoreNumber`). It tracks separate counters/flags per DEA-schedule category — `Standard`, `Schedule2` (CII), `Schedule3_5` (CIII-CV), and `OTC` — consistent with pharmacies numbering controlled-substance scripts in distinct series from non-controlled/OTC items (inferred, general pharmacy-ops knowledge). `NumberingScheme` (inferred) selects which numbering algorithm/series format the store uses. `IsValid` flags whether the row's configuration is active/usable, and `LastModified` is a standard audit timestamp. `OfficeUse` is an unlabeled free-form int, purpose not evidenced by the data (inferred: miscellaneous/legacy flag field). With only 5 rows (one per store) and no FK-bearing columns, this is a small config table rather than a transactional one.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| StoreNumber | char(2) | NOT NULL | PK | Store identifier, 2-char code |
| NumberingScheme | int | NOT NULL | | selects numbering algorithm (inferred) |
| Standard | int | NOT NULL | | non-controlled script numbering counter/config (inferred) |
| Schedule2 | int | NOT NULL | | CII controlled-substance counter/config (inferred); sampled values: `0` (count 5) |
| Schedule3_5 | int | NOT NULL | | CIII-CV controlled-substance counter/config (inferred); sampled values: `0` (count 5) |
| OTC | int | NOT NULL | | OTC item numbering counter/config (inferred) |
| LastModified | datetime | NOT NULL | | audit timestamp of last update |
| IsValid | bit | NOT NULL | | row-active flag; sampled values: `true` (count 5) |
| OfficeUse | int | NOT NULL | | unlabeled field, purpose not evidenced |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

No column naming in this table matched other tables' key patterns, and no other table's columns were inferred to reference it — all values above (including `StoreNumber`) are unconfirmed as cross-table keys by the extraction; `StoreNumber` is plausibly a soft link to a stores/locations table elsewhere in the schema but no such edge was detected.

**Indexes**

None declared (empty index list).

**Gotchas**

- Every non-key sampled column (`Schedule2`, `Schedule3_5`, `IsValid`) shows a single constant value across all 5 rows — with only 5 rows total, these samples may not reflect the true domain of the columns (e.g., other stores/tenants could have nonzero or false values).
- `OfficeUse` and `NumberingScheme` have no sampled lookups and no naming precedent elsewhere in this extract; their semantics are speculative.
- Not ETL-mirrored into liberty_link_stage — this config is Liberty-internal only and has no presence in the eMed DB.

---

## `rxqScriptTemplate`

Rows (RXCS): 14 | Columns: 7 | PK: `cScriptTemplateId` | ETL-mirrored into liberty_link_stage: no

**Purpose** — Stores a small set of reusable text templates (column `Template`, up to 8000 chars, named by `TemplateName`) with a display `SortOrder`, keyed to a `StoreNumber` and a `UserId`, and stamped with `LastModified`. Given the table name and a `TemplateName`/`Template` body pair, this most likely holds canned script/note text (e.g. prescription-note or label boilerplate) that pharmacy staff select from rather than retype (inferred). The `StoreNumber`/`UserId` columns suggest templates can be scoped per store and/or attributed to the user who created/last edited them (inferred); with only 14 rows in RXCS, this looks like a small shared/admin-curated list rather than a per-user personal set.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cScriptTemplateId | int | NO | PK | identity |
| Template | varchar(8000) | YES | | template body text |
| TemplateName | varchar(200) | YES | → ReportFilterTemplates (unvalidated) | name/label of the template |
| StoreNumber | nvarchar(50) | YES | | store scoping |
| UserId | nvarchar(50) | YES | | creating/owning user |
| LastModified | datetime | YES | | |
| SortOrder | int | YES | | display ordering |

No columns appear in `lookups` (no small coded-domain columns sampled for this table).

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**:
  - `TemplateName` → `ReportFilterTemplates` (join col `TemplateName`) — inferred, **unvalidated** (reason: parent table empty, no rows to check match against). Treat as a weak/unconfirmed guess only — the column-name similarity may be coincidental rather than a real relationship (e.g. two unrelated features both using "TemplateName").
- **Inbound (inferred)**: none.

**Indexes** — none reported.

**Gotchas**
- Not ETL-mirrored, so this table is invisible to liberty_link_stage/eMed reporting; any downstream use of these templates would require direct Liberty DB access.
- The only inferred relationship is unvalidated because its target table (`ReportFilterTemplates`) is empty — cannot confirm or refute the link from data; do not treat it as reliable.
- `StoreNumber` and `UserId` are typed nvarchar/varchar (not int FKs to a numeric store/user id), consistent with Liberty's general pattern of loosely-typed, non-constrained key-like columns.

---

## `rxqScriptCounsel`

Rows: 1 (RXCS) · Columns: 9 · PK: `ScriptNumber`, `RefillNumber` · ETL-mirrored into liberty_link_stage: no

**Purpose**
Records patient-counseling events tied to a specific script fill (composite-keyed by `ScriptNumber` + `RefillNumber`, so each refill iteration gets its own counsel record). Captures whether counseling occurred/was refused (`Refused`, `DateCounseled`, `RphInitials`), a validity flag (`IsValid`), and a free-text `DenialReason` for documenting refusal — consistent with pharmacy counseling-offer/refusal documentation required for dispensing (inferred). `PatientConsultationId` (indexed, non-PK, nvarchar) appears to link to a broader patient-consultation record/thread, though no parent table is inferable from naming alone (inferred). Table has only 1 live row in the RXCS instance, so this documentation reflects schema shape more than observed data diversity.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cScriptCounselId | int | NO | | identity (surrogate row id) |
| ScriptNumber | int | NO | PK, → `rxqScriptBase` | part of composite PK |
| RefillNumber | int | NO | PK | part of composite PK; distinguishes counsel record per refill |
| DateCounseled | datetime | YES | | timestamp counseling occurred |
| RphInitials | varchar(50) | YES | | initials of counseling pharmacist |
| Refused | bit | YES | | whether patient refused counseling |
| IsValid | bit | YES | | sampled values: `true` (count 1) — only value observed |
| DenialReason | nvarchar(max) | YES | | free-text reason if counseling refused/denied |
| PatientConsultationId | nvarchar(50) | YES | | indexed; likely link to a consultation record, but no confirmed parent table |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):**
  - `ScriptNumber` → `rxqScriptBase` — inferred, **high** confidence (100.0% referential match, not sampled).
- **Inbound (inferred):** none.

These edges are inferred purely from column naming and then data-validated against actual parent-table values — they are not enforced constraints, and the single-row sample size here means the 100% match rate is based on only 1 non-null value.

**Indexes**
- `indexPatientConsultationIdScriptCounsel` (NONCLUSTERED, non-unique) on `PatientConsultationId` — supports lookup of counsel records by consultation, reinforcing that `PatientConsultationId` is a meaningful join/access path despite no inferable parent table.

**Gotchas**
- Composite PK (`ScriptNumber`, `RefillNumber`) rather than a single-column key — joins must include both columns to avoid fan-out across refills.
- `PatientConsultationId` is typed `nvarchar(50)` (not int) and has no detected parent table — likely references an external/consultation system not captured in this table inventory; treat as unconfirmed.
- Only 1 row exists in RXCS — match-rate/lookup statistics here are not statistically meaningful and should be re-validated once more data is available.
- Not ETL-mirrored into liberty_link_stage, so this data is not available to eMed via the standard mirror.

---

## `rxqScriptReconcile`

Rows (RXCS): 1 | Columns: 16 | PK: `Id` | ETL-mirrored into liberty_link_stage: no

**Purpose** — Stores payment/reconciliation records tied to a dispensed script and refill (`ScriptNumber`, `RefillNumber`, `PaymentNumber`, `Amount`, `Fee`, `DatePmtApplied`, `CheckNumber`, `Agency`, `AuthorizationNumber`), i.e. matching a payer/agency remittance against a specific fill (inferred). `IsPrimary` and `IsValid` suggest it supports multiple candidate/secondary payment matches per script, with one flagged as the primary/valid reconciliation record (inferred). `MFPPayment` and `PatientThirdPartyId` point to manufacturer financial program (MFP) and third-party-payer payment tracking, respectively (inferred). Table currently holds only 1 row in RXCS, so patterns below are drawn from schema/index shape, not volume.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| Id | nvarchar(50) | NO | PK | |
| ScriptNumber | int | NO | → rxqScriptBase (low confidence) | indexed (`Script`) |
| RefillNumber | int | NO | | |
| PaymentNumber | int | NO | | |
| Agency | nvarchar(50) | YES | | indexed (`Agency`) |
| DatePmtApplied | datetime | YES | | |
| Amount | decimal(9,2) | YES | | |
| Description | nvarchar(50) | YES | | |
| CheckNumber | nvarchar(50) | YES | | |
| IsPrimary | bit | YES | | |
| IsValid | bit | YES | | sampled value: `true` (count 1) |
| Fee | decimal(9,2) | YES | | |
| GeneralItem | bit | YES | | |
| AuthorizationNumber | nvarchar(50) | YES | | |
| MFPPayment | int | YES | | |
| PatientThirdPartyId | int | YES | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):**
  - `ScriptNumber` → `rxqScriptBase` — inferred, **low** confidence (0.0% referential match; 1 non-null value checked, 1 orphan, not sampled). Treat as an unconfirmed/weak guess given the table's tiny row count.
- **Inbound (inferred):** none.

**Indexes**
- `Agency` (NONCLUSTERED, non-unique) on `Agency` — supports lookup by paying agency.
- `Script` (NONCLUSTERED, non-unique) on `ScriptNumber` — supports lookup/join by script.

**Gotchas**
- Only 1 row present in RXCS at extraction time — schema shape (columns, indexes) is reliable, but relationship match-rate and lookup domain are effectively unvalidated at this scale; do not treat the 0% match on `ScriptNumber`→`rxqScriptBase` as evidence of a broken link, it's just a single-row sample (likely orphaned/test row or a match-rate artifact).
- `Id` is a varchar(50) surrogate/GUID-style key rather than an int identity — typical Liberty pattern of string PKs on peripheral tables.
- Not ETL-mirrored into liberty_link_stage, so this data is not currently queryable from the eMed side.

---

## `rxqTransfers`

Rows: 319 (RXCS) · Columns: 26 · PK: (`TransferType`, `ScriptNumber`, `RecordNumber`, `RefillNumber`) · ETL-mirrored into `liberty_link_stage`: no

**Purpose**

Records prescription transfer transactions — scripts (and specific refills) being moved into or out of the pharmacy from/to another pharmacy (NCPDP-style Rx transfer). Columns like `TransferMethod`, `DirectionType`, `ActionType`, `TransferOption`, `Contact`, `Comments`, `RphInitials`, `RefillsAuth`/`RefillsRemain`, and `OriginalRx` (inferred) capture the who/how/how-many of a transfer, including the pharmacist recording it and the remaining refill balance being transferred. `TransferType` being part of the primary key (inferred) suggests the same script/refill can have multiple transfer records distinguished by transfer type (e.g., in vs. out, or transfer vs. void). `QuantityRemaining` and `RefillsRemain` (inferred) track what's left to fill after the transfer.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| TransferType | varchar(50) | NO | PK | |
| ScriptNumber | int | NO | PK, → `rxqScriptBase` | |
| OriginalDate | datetime | YES | | |
| LastDate | datetime | YES | | |
| LastModified | datetime | YES | | |
| IsValid | bit | YES | | lookup: `true`=319 (100% of rows) |
| PharmacyId | varchar(50) | YES | | |
| TransferDate | datetime | YES | | |
| Contact | varchar(50) | YES | | |
| Comments | text | YES | | |
| RefillsAuth | int | YES | | |
| RefillsRemain | int | YES | | |
| OriginalRx | varchar(50) | YES | | |
| LastFill | datetime | YES | | |
| FirstFill | datetime | YES | | |
| Createdby | varchar(256) | YES | | |
| RphInitials | varchar(50) | YES | | |
| RecordNumber | int | NO | PK | |
| Quantity | decimal(9,3) | NO | | |
| RefillNumber | int | NO | PK | |
| TransferMethod | int | YES | | lookup: `0`=158, `null`=154, `3`=7 |
| Status | int | YES | | lookup: `0`=165, `null`=154 |
| ActionType | int | YES | | lookup: `null`=319 (always null in sample) |
| DirectionType | int | YES | | |
| QuantityRemaining | decimal(9,3) | YES | | |
| TransferOption | int | NO | | lookup: `0`=319 (always 0 in sample) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

These edges are inferred purely from column naming and then data-validated against actual key values — not enforced by the schema.

- **Outbound (inferred):**
  - `ScriptNumber` → `rxqScriptBase` (join on `ScriptNumber`) — inferred, **high** confidence (99.1% referential match; 316/319 non-null values found, 3 orphans).
- **Inbound (inferred):** none.

**Indexes**

None reported (no indexes defined on this table beyond the implicit PK).

**Gotchas**

- Composite 4-part PK with no surrogate key — joins/upserts must match on all of `TransferType`+`ScriptNumber`+`RecordNumber`+`RefillNumber`.
- `TransferMethod`, `Status`, and `ActionType` are heavily/entirely null in the sample (154/319, 154/319, 319/319 respectively) — codes may be sparsely used or only populated for certain `TransferType`/`DirectionType` combinations; treat as unreliable filters until cross-checked against a fuller data set.
- `ActionType` is null for all 319 sampled rows and `TransferOption` is 0 for all 319 — effectively constants in this snapshot; do not assume other codes are invalid, just unobserved.
- `OriginalRx` (varchar) vs `ScriptNumber` (int) — likely stores the transfer-source pharmacy's own Rx number as free text (inferred), not a joinable key into this DB.
- Not ETL-mirrored to `liberty_link_stage` — transfer history is only visible by querying Liberty directly.
- 3 orphaned `ScriptNumber` values (0.9% of rows) don't resolve in `rxqScriptBase` — likely scripts transferred out where the local script record was later purged, or transfers referencing another tenant's script numbering (inferred).

---

## `rxqPharmacyTransfer`

Rows (RXCS): 23 · Columns: 20 · PK: `Id` · ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores a directory of other pharmacies (name, address, phone/fax, NCPDP/NPI/DPS identifiers, contact) used as counterparties for prescription transfers — the "transfer to/from pharmacy" address book referenced when a script is transferred in or out of this pharmacy (inferred, from column set: `Ncpdp`, `NPI`, `DPS`, `FidNumber`, address/contact fields, and the table name itself). The small row count (23) and lack of any inbound/outbound inferred relationships suggest this is a low-volume, largely static reference list of known transfer-partner pharmacies rather than a per-transaction transfer log (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| Id | varchar(50) | NO | PK | |
| Name | varchar(50) | NO | | pharmacy name |
| Street | varchar(50) | YES | | |
| Suite | varchar(50) | YES | | |
| City | varchar(50) | YES | | |
| State | varchar(50) | YES | | |
| Zip | varchar(50) | YES | | |
| ZipPlus | varchar(50) | YES | | |
| Phone | varchar(50) | YES | | |
| Fax | varchar(50) | YES | | |
| Ncpdp | varchar(50) | YES | | NCPDP pharmacy identifier of the transfer-partner pharmacy |
| FidNumber | varchar(50) | YES | | facility ID number |
| Contact | varchar(max) | YES | | free-text contact info/name |
| LastModified | datetime | YES | | |
| IsValid | bit | YES | | sampled values: `true` (23) — every sampled row is currently marked valid |
| Source | int | NO | | sampled values: `-1` (23) — single constant value across all sampled rows; meaning of `-1` not determinable from data alone |
| NPI | nvarchar(50) | YES | | National Provider Identifier of the transfer-partner pharmacy |
| DPS | nvarchar(50) | YES | | state pharmacy licensing/DPS number |
| LastCentralUpdate | datetime | YES | | |
| Nickname | varchar(50) | YES | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

**Indexes**

None defined (no indexes reported, not even on the PK).

**Gotchas**

- `Id` is a varchar(50) primary key, not an integer identity — typical of Liberty's GUID/string-keyed reference tables.
- No inferred or declared relationships at all: nothing in the extracted metadata links this table to a transfer-transaction table (e.g., an rx/order-level "transferred to/from pharmacy Id" column) — the actual transfer event linkage, if any, is not visible from column naming/data validation here.
- `Source = -1` for all 23 sampled rows is a single-value column with no other observed domain values; treat as an unconfirmed coded flag, not a documented enum.
- Not mirrored by ETL, so this data is unavailable in liberty_link_stage/eMed reporting — any eMed-side need for transfer-partner pharmacy directory data would have to source it directly from Liberty.

---

## `rxqAuditAutoRefill`

Rows (RXCS): 1,959 | Columns: 7 | PK: `cAuditAutoRefillId` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Audit log of auto-refill workflow actions taken against individual script/refill records — each row records an `Action` (coded int, domain not sampled), the `ActionDate` it occurred, which `ScriptNumber`/`RefillNumber` it applied to, an optional `WFIDate` (inferred: "workflow item" date, e.g. when the refill was queued into a work-fill queue), and the `LoggedUser` who performed/triggered it (inferred). It functions as an append-only trail of the automated-refill engine's decisions/state transitions per script (inferred) rather than an operational table consumed elsewhere — nothing points back to it (no inbound references) and it is not part of the ETL mirror to liberty_link_stage.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cAuditAutoRefillId | int | NO | PK | identity |
| Action | int | NO | | coded action type; no sampled values available (lookups empty) |
| ActionDate | datetime | NO | → rxqTimeClockEntry (weak, see below) | timestamp of the action |
| ScriptNumber | int | NO | → rxqScriptBase | |
| RefillNumber | int | NO | | refill sequence number on the script; no implicit_ref detected |
| WFIDate | datetime | YES | | nullable; likely a workflow/queue-item date (inferred) |
| LoggedUser | varchar(20) | NO | | username/operator id string, no FK inferred |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**
  - `ScriptNumber` → `rxqScriptBase` — inferred, **high** confidence (97.9% referential match, 1959 non-null / 41 orphans, not sampled).
  - `ActionDate` → `rxqTimeClockEntry` — inferred from column-naming heuristic only, **unvalidated** (parent table `rxqTimeClockEntry` is empty, so the match could not be checked). This is almost certainly a false positive from the naming heuristic (an `ActionDate` datetime column coincidentally matching a time-clock join key) rather than a real relationship — treat as noise, not a genuine edge.
- **Inbound (inferred)**
  - none

**Indexes**

None defined (indexes list is empty for this table — no supporting access paths beyond the clustered PK).

**Gotchas**

- `Action` is an unlabeled coded int with no sampled lookup values captured — the meaning of each code is unknown from this metadata alone; do not guess specific codes.
- The `ActionDate` → `rxqTimeClockEntry` inferred edge is very likely spurious (naming coincidence, unvalidated because the parent is empty) — do not treat it as a real relationship without independent confirmation.
- ~2.1% of `ScriptNumber` values (41 of 1,959) are orphans against `rxqScriptBase`, consistent with normal drift (deleted/renumbered scripts) rather than a data-quality alarm, but worth knowing before joining strictly.
- Not ETL-mirrored to liberty_link_stage — any eMed-side feature needing this audit trail would require a new mirror/ETL addition.

---

## `rxqAuditMedSync`

Rows (RXCS): 5,675 | Columns: 8 | PK: `cAuditMedSyncId` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores an audit trail of actions taken against a "Med Sync" (medication synchronization) workflow item, keyed to a specific `ScriptNumber`/`RefillNumber` pair (inferred). Med Sync is a common pharmacy-operations feature that aligns a patient's multiple refills to a single pickup date; this table appears to log each state-changing `Action` taken on a script within that workflow, along with `ActionDate`, a `WFIDate` (workflow date, inferred), and the `LoggedUser` who performed it (inferred). `LastModified` suggests standard audit-row upkeep. No lookup values were sampled for `Action`, so its coded meaning is not documented here.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cAuditMedSyncId | int | NO | PK | identity |
| Action | int | YES | | no sampled lookup values available (coded action type, meaning undocumented) |
| ActionDate | datetime | YES | → rxqTimeClockEntry (weak, see below) | |
| ScriptNumber | int | YES | → rxqScriptBase | |
| RefillNumber | int | YES | | no implicit_ref detected |
| WFIDate | datetime | YES | | likely "workflow date" (inferred) |
| LoggedUser | varchar(max) | YES | | free-text user identifier, not a validated FK |
| LastModified | datetime | YES | | standard audit timestamp |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- Outbound (inferred):
  - `ScriptNumber` → `rxqScriptBase` (join on `ScriptNumber`) — inferred, **high** confidence (99.74% referential match, 5,675 non-null values, 15 orphans).
  - `ActionDate` → `rxqTimeClockEntry` (join on `ActionDate`) — inferred, **unvalidated** (parent table empty; naming-only guess, treat as unconfirmed — a datetime column matching another table's datetime column by name is weak evidence of a real relationship, likely a false positive from generic column naming rather than a true reference).
- Inbound (inferred): none.

**Indexes**

None declared (empty index list beyond the implicit PK clustered index).

**Gotchas**

- `Action` is an undocumented int code with no sampled lookup domain — do not assume its semantics without checking application code.
- `LoggedUser` is a free-text varchar(max), not a validated join key to any user table — treat as display-only audit data.
- The `ActionDate` → `rxqTimeClockEntry` inferred edge is very likely spurious (parent empty, matched purely by column name); do not rely on it for joins.
- `RefillNumber` has no detected implicit reference despite pairing naturally with `ScriptNumber`/`rxqScriptBase` — the refill-level linkage (if any) is not enforced or discoverable at the schema level.
- Table is NOT ETL-mirrored to liberty_link_stage, so this audit history is only queryable directly against the Liberty source DB.

---

## `rxqTreatmentSchedule`

Rows: 9 (RXCS) · Columns: 26 · PK: `cTreatmentScheduleId` · ETL-mirrored into liberty_link_stage: no

**Purpose** — Stores per-patient dosing/administration schedules: up to 8 named time slots (`Time1`-`Time8`), a `DoseQuantity`, a `RepeatPattern`, an active date range (`StartDate`/`EndDate`), PRN flag, sig text (`Sigs`/`DecodedSigs`), and eMAR print/sort metadata (`EmarPrintCode`, `SortOrder`, `SortWeight`, `CustomSortOrder`). Row count is tiny (9) and `PatientId` links to `rxqPatient`, so this looks like a treatment/eMAR scheduling module used for a small subset of patients (e.g. institutional/long-term-care dosing calendars) rather than a core order-fill table (inferred). `ParentId`/`Index` suggest a self-referencing or ordered hierarchy of schedule entries, and `rxqSigsTreatmentSchedule` appears to hang off this table's PK (inferred, unconfirmed — see below).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cTreatmentScheduleId | int | NO | PK | identity; sampled values 1-9 (one row each) |
| TreatmentScheduleName | varchar(50) | NO | | |
| PatientId | varchar(50) | NO | → rxqPatient | |
| Time1 | varchar(50) | YES | | |
| Time2 | varchar(50) | YES | | |
| Time3 | varchar(50) | YES | | |
| Time4 | varchar(50) | YES | | |
| Time5 | varchar(50) | YES | | |
| LastModified | datetime | YES | | |
| IsValid | bit | YES | | sampled: `true` (9/9) |
| SortOrder | int | YES | | |
| SortWeight | int | YES | | |
| DoseQuantity | decimal(9,3) | YES | | |
| RepeatPattern | varchar(200) | YES | | |
| Time6 | varchar(50) | YES | | |
| Time7 | varchar(50) | YES | | |
| Time8 | varchar(50) | YES | | |
| EmarPrintCode | varchar(3) | YES | | sampled: `""` (empty string, 9/9) |
| CustomSortOrder | int | YES | | |
| PRN | bit | YES | | |
| ParentId | int | NO | | no implicit_ref detected; likely self-referential hierarchy pointer (inferred) |
| Index | int | NO | | reserved-word column name; likely ordinal position within parent (inferred) |
| StartDate | date | YES | | |
| EndDate | date | YES | | |
| Sigs | nvarchar(500) | YES | | |
| DecodedSigs | nvarchar(500) | YES | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

These edges are INFERRED from column naming and DATA-VALIDATED against actual values — not enforced constraints.

- **Outbound (inferred)**
  - `PatientId` → `rxqPatient` (join on `PatientId`) — inferred, **medium** confidence (88.9% referential match, 1 of 9 non-null values orphaned; not sampled).

- **Inbound (inferred)**
  - `rxqSigsTreatmentSchedule.cTreatmentScheduleId` → this table — inferred, **no-data** confidence (parent/child match rate not computable; treat as unconfirmed guess).

**Indexes**

- `IX_TreatmentSchedule` (NONCLUSTERED, non-unique) — key: `PatientId`; includes nearly every other column (`cTreatmentScheduleId`, all `Time1`-`Time8`, `LastModified`, `IsValid`, `SortOrder`, `SortWeight`, `DoseQuantity`, `RepeatPattern`, `EmarPrintCode`, `CustomSortOrder`, `PRN`) — a covering index built for "fetch full schedule by patient" lookups, confirming `PatientId` as the primary access path.

**Gotchas**

- `PatientId` is `varchar(50)`, not an int FK, despite pointing at `rxqPatient` — typical Liberty pattern of typed-as-string identifiers with no enforced constraint; here it's also imperfect (11% orphan rate on only 9 rows, i.e. 1 row's `PatientId` doesn't resolve).
- `Index` is a SQL reserved word used as a column name — will require bracket-quoting (`[Index]`) in all queries/ORMs.
- `ParentId` has no detected implicit_ref; likely self-join to `cTreatmentScheduleId` but not validated — treat as a guess, not a confirmed relationship.
- Table is essentially unused in this tenant (9 rows total) — any generalization about its role should be treated as provisional; behavior may differ meaningfully once populated at scale or in other tenants.
- `EmarPrintCode` sampled as empty string across all rows — coded domain not yet observed, don't assume it's always blank.

---

## `rxqDirection`

Rows (RXCS): 3,575 | Columns: 14 | PK: (`KeyType`, `Language`, `KeyCode`) | ETL-mirrored into liberty_link_stage: no

**Purpose**

A localized lookup/text table storing coded "direction" strings keyed by `KeyType` + `Language` + `KeyCode`, with a `Text` field (up to 500 chars) holding the actual (likely SIG/directions-for-use) content (inferred). Columns `City`/`Zip` suggest some entries are geography-scoped variants (inferred), and `LinkKeyType`/`LinkLanguage`/`LinkKeyCode`/`LinkCount` imply a self-referential or cross-entry linking mechanism between direction records (inferred) — though no declared or data-validated relationship confirms this. `IsValid` is 100% `true` across all 3,575 sampled rows, suggesting either no soft-delete/deprecation flow is currently exercised or this table only ever holds active rows (inferred). `rxqPatient.Language` referencing this table's `Language` column (100% match) indicates this table's `Language` values double as the patient-preferred-language domain (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cDirectionId | int | NOT NULL | | identity |
| KeyType | varchar(50) | NOT NULL | PK | |
| Language | varchar(50) | NOT NULL | PK | referenced by `rxqPatient.Language` (inferred, high confidence) |
| KeyCode | varchar(50) | NOT NULL | PK | |
| Text | nvarchar(500) | NULL | | likely the localized direction/SIG text (inferred) |
| City | varchar(50) | NULL | | possible geo-scoping (inferred) |
| Zip | varchar(50) | NULL | | possible geo-scoping (inferred) |
| LinkKeyType | varchar(50) | NULL | | possible link to another `rxqDirection` row's KeyType (inferred, unconfirmed) |
| LinkLanguage | varchar(50) | NULL | | possible link to another `rxqDirection` row's Language (inferred, unconfirmed) |
| LinkKeyCode | varchar(50) | NULL | | possible link to another `rxqDirection` row's KeyCode (inferred, unconfirmed) |
| LinkCount | int | NULL | | count associated with the link (inferred, unconfirmed) |
| LastModified | datetime | NULL | | audit timestamp |
| IsValid | bit | NULL | | sampled values: `true` (3,575) — 100% of rows; no `false` observed |
| IconIndex | int | NULL | | UI icon reference (inferred) |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):**
  - `rxqPatient.Language` → `rxqDirection.Language` — inferred, **high** confidence (100.0% referential match)

These edges are inferred purely from column naming and cross-checked against actual data values (not declared schema constraints). The `Link*` columns (`LinkKeyType`/`LinkLanguage`/`LinkKeyCode`) strongly resemble a composite self-reference back into `rxqDirection`'s own PK shape, but no inferred_relationship was detected/validated for them — treat this as an unconfirmed structural guess only.

**Indexes**

- `_dta_index_rxqDirection_195_789577851__K3_K2_K4_5` (NONCLUSTERED, non-unique) on (`Language`, `KeyType`, `KeyCode`) including `Text` — an auto-generated tuning index that mirrors the PK column set (reordered) plus the payload column, indicating lookups are commonly performed by `Language`+`KeyType`+`KeyCode` to fetch `Text` directly (covering index).

**Gotchas**

- Composite varchar(50) triple as PK (`KeyType`, `Language`, `KeyCode`) — no surrogate key is enforced despite an identity column (`cDirectionId`) existing alongside it; joins must match all three parts.
- `Link*` columns appear to form a shadow composite FK back into this same table (self-referential linking) but this is entirely unvalidated — no inferred_relationships entry exists for them, likely because Liberty never declares FKs and the linkage may be sparse/nullable in practice.
- Not ETL-mirrored to liberty_link_stage — any eMed feature needing this table's content must query Liberty directly, not the mirror.
- `IsValid` shows only `true` in the sample; do not assume soft-deletion is unused elsewhere without checking a larger/different sample.

---

## `rxqSigsCodes`

Rows: 1,454 (RXCS) · Columns: 8 · PK: `(SigCode, SigLanguage)` · ETL-mirrored into liberty_link_stage: no

**Purpose** — A lookup/reference table mapping a coded sig abbreviation (`SigCode`) plus a language (`SigLanguage`) to its rendered directions-for-use text (`SigText`). The composite PK confirms the same `SigCode` can have multiple localized entries, one per language (inferred: multi-language label printing on Rx labels). `DaySupplyMultiplier` and `PRN` (inferred: "as needed" flag) suggest the table also drives day-supply calculation and PRN dosing logic from the coded sig, not just display text. `cUnitDoseTemplateId` is present but its only sampled value across all 1,454 rows is `0`, and `SupportedLanguageCode` is null/blank in every sampled row, so those two columns appear largely unused/vestigial in this instance (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| SigCode | varchar(50) | NO | PK | Sig abbreviation code |
| SigText | nvarchar(max) | YES | | Rendered/expanded sig directions text |
| SigLanguage | varchar(50) | NO | PK | Language of `SigText` |
| DaySupplyMultiplier | decimal(20,8) | YES | | Multiplier used in day-supply calc (inferred) |
| PRN | bit | YES | | "as needed" flag (inferred) |
| LastModified | datetime | YES | | Audit timestamp |
| cUnitDoseTemplateId | int | YES | → `rxqUnitDoseTemplate` | Sampled value: `0` (count 1454) — i.e. constant/unset across all rows |
| SupportedLanguageCode | varchar(3) | YES | | Sampled values: `NULL` (count 1316), `""` empty string (count 138) — effectively unpopulated |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**
  - `cUnitDoseTemplateId` → `rxqUnitDoseTemplate` — inferred, **unvalidated** (parent table empty, so referential match could not be checked; all sampled values are `0` anyway, casting doubt on this being a live reference).
- **Inbound (inferred)**
  - `rxqSigsTreatmentSchedule.SigLanguage` → this table — inferred, **no-data** confidence (no rows available to validate the match).

These edges are naming-based inferences data-validated where possible — not enforced database constraints. The single outbound edge and single inbound edge are both weak/unconfirmed (unvalidated / no-data), not verified joins.

**Indexes** — none reported.

**Gotchas**
- Composite varchar PK (`SigCode`, `SigLanguage`) rather than a surrogate key — joins to this table must supply both columns.
- `cUnitDoseTemplateId` and `SupportedLanguageCode` look like dead/placeholder columns in this data (constant `0` / effectively all null-or-blank) despite implying relationships or localization support — treat any code path depending on them with suspicion until confirmed live.
- Not ETL-mirrored into liberty_link_stage, so eMed-side reporting/joins cannot reach this table directly.

---

## `rxqSigDays`

Rows: 140 (RXCS) | Columns: 5 | PK: `SigCode` | ETL-mirrored into liberty_link_stage: no

**Purpose**

A small reference/lookup table mapping a Sig (prescription directions) code to a numeric `Multiplier`, with an `IsValid` flag and a `LastModified` audit timestamp. (Inferred) this multiplier is used by Liberty's days-supply calculation logic — given a Sig code (e.g. dosing frequency shorthand like "BID", "TID", "QD") the multiplier likely converts a quantity/dose into an implied number of days supply, a common NCPDP/pharmacy-system pattern for auto-computing days-supply from sig text. All 140 sampled rows have `IsValid = true`, suggesting the table currently holds no soft-deleted/deprecated entries (or none were sampled). No FK-style columns are present and no relationships were inferred, consistent with this being a static/reference code table rather than a transactional one.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| cSigDaysId | int | NOT NULL | | identity column (surrogate/internal id, not the declared PK) |
| SigCode | varchar(50) | NOT NULL | PK | business key identifying the sig/directions code |
| Multiplier | float | NULL | | numeric factor, presumably applied to a quantity or frequency to derive days supply (inferred) |
| LastModified | datetime | NULL | | audit timestamp of last update |
| IsValid | bit | NULL | | sampled domain: `true` (140/140 rows) — no `false` values observed in this sample |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

No inbound or outbound relationships were inferred for this table — column naming produced no candidate joins to other tables in this extract. Any link from other tables' sig-related columns (e.g. a Sig or SigCode field elsewhere) to this table is therefore unconfirmed/not detected by the inference pass and would need manual verification.

**Indexes**

None reported (indexes list is empty in the source metadata).

**Gotchas**

- The declared PK is the varchar `SigCode`, not the identity `cSigDaysId` — joins from other tables should key off `SigCode`, but no such joins were actually detected/validated in this extract, so any consuming code should be located manually (e.g. by grepping for `SigCode` usage) rather than assumed from this metadata.
- `IsValid` and `Multiplier` are both nullable despite apparently being core to the row's meaning — absence of `false`/null samples doesn't guarantee they never occur outside the sampled set.
- Not mirrored by ETL into liberty_link_stage, so any eMed-side reporting/logic needing sig-to-days-supply conversion cannot rely on this table being available downstream; it would need to be sourced live from Liberty or added to the ETL mirror.

---

## `rxqDrugSigs`

Rows (RXCS): 5 | Columns: 4 | PK: `DrugKey` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores canned/default prescription instructions (Sigs, i.e. directions for use) keyed one-per-drug via `DrugKey`. `Sigs` (nvarchar(500)) holds the free-text instruction string, `IsValid` flags whether the sig is currently active/usable, and `LastModified` tracks the last edit timestamp. (inferred) This looks like a small drug-level sig-template/default-instructions lookup table used to pre-populate directions when a drug is prescribed or filled, rather than a per-prescription sig record — the tiny row count (5) and single row per `DrugKey` support a template/reference role rather than a transactional log.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| DrugKey | nchar(4) | NOT NULL | PK, → `rxqDrug` | Fixed-width 4-char drug code |
| Sigs | nvarchar(500) | NULL | | Free-text sig/instructions string |
| LastModified | datetime | NOT NULL | | Last-modified timestamp |
| IsValid | bit | NOT NULL | | Sampled values: `true` (5/5 rows) — only value observed, so `false` is not confirmed to occur |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):**
  - `DrugKey` → `rxqDrug` (join col `DrugId`) — inferred, **high** confidence (100.0% referential match, not sampled — full check of all 5 non-null values).
- **Inbound (inferred):** none.

**Indexes**

None reported.

**Gotchas**

- Fixed-width `nchar(4)` key (`DrugKey`) rather than an integer surrogate — join to `rxqDrug` must account for exact-length padding/blank-trimming behavior of `nchar`.
- Table is tiny (5 rows) relative to a presumably much larger `rxqDrug` table — only a small subset of drugs have a stored default sig; absence of a row for a given `DrugKey` is likely the common case, not an anomaly.
- Not ETL-mirrored into liberty_link_stage, so eMed-side reporting/joins cannot reference this table directly today.
- `IsValid` domain is only observed as `true` in the current sample; whether `false` rows ever exist (e.g. soft-deleted/superseded sigs) is unconfirmed from this data.

---

## `rxqAuxiliaryLabels`

Rows (RXCS): 3,741 | Columns: 9 | PK: `AuxiliaryLabelId` | ETL-mirrored into liberty_link_stage: no

**Purpose** — Stores auxiliary warning/instruction label text printed on prescription vials/packaging (e.g. "may cause drowsiness"-style stickers), scoped to a drug (`DrugId`) and, apparently, tied to a specific script/fill (`ScriptNumber`, `RefillNumber`) with an ordering slot (`LabelPosition`) for multi-label layouts (inferred). `LabelType` is a small coded field (values 2 and 3 observed, 2 dominant at 3,738/3,741 rows) distinguishing label categories/sources (inferred — exact meaning of 2 vs 3 not determinable from metadata alone). `MedispanId` suggests the label text/content may originate from or be cross-referenced to Medispan drug-knowledge data (inferred). Not mirrored by ETL, so this data is invisible to liberty_link_stage/eMed reporting.

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| AuxiliaryLabelId | int | NO | PK | identity |
| LabelType | int | YES | | coded domain: `2` (3,738 rows), `3` (3 rows) |
| DrugId | varchar(50) | YES | → rxqDrug | |
| MedispanId | varchar(256) | YES | | |
| ScriptNumber | int | YES | → rxqScriptBase (unconfirmed) | |
| RefillNumber | int | YES | | |
| LabelPosition | int | YES | | |
| Text | nvarchar(max) | YES | | label text content |
| LastModified | datetime | YES | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred)**:
  - `DrugId` → `rxqDrug` — inferred, **high** confidence (99.8% referential match, 3,741 non-null, 6 orphans, not sampled).
  - `ScriptNumber` → `rxqScriptBase` — inferred, **low** confidence (0.0% referential match — all 3,741 non-null values are orphans, not sampled). This edge is a naming-based guess only and appears **unconfirmed by data**; do not treat `ScriptNumber` here as a reliable link to `rxqScriptBase`.
- **Inbound (inferred)**: none.

**Indexes** — none reported.

**Gotchas**
- `ScriptNumber`'s inferred link to `rxqScriptBase` has a 0% match rate despite full population (3,741/3,741 non-null) — this strongly suggests either a different join target/key format, a stale/legacy column, or that `ScriptNumber` here is not a true script identifier at all. Treat any join through this column with caution.
- `DrugId` is a varchar(50) key rather than an int, consistent with other Liberty drug-keyed tables.
- Not ETL-mirrored: this table's contents (label text, drug/script associations) are not available in liberty_link_stage for downstream eMed queries.
- `LabelType` domain is heavily skewed (99.9% value=2); value=3 is a rare edge case (only 3 rows) — worth confirming its meaning before building logic that branches on it.

---

## `rxqSavedAuxiliaryLabels`

Rows (RXCS): 50 | Columns: 4 | PK: `SavedAuxiliaryLabelId` | ETL-mirrored into liberty_link_stage: no

**Purpose** — Stores a small library of reusable "auxiliary label" text snippets (the supplemental warning/instruction stickers affixed to prescription vials, e.g. "Take with food", "May cause drowsiness") keyed by an internal identity ID and an optional short `QuickCode` for fast lookup/entry (inferred). `LastModified` suggests these are user-maintained/editable templates rather than static reference data (inferred). No relationship to patient, drug, or order tables is evidenced in this table — it holds only the label catalog, not applications of labels to specific fills (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| SavedAuxiliaryLabelId | int | NO | PK | identity |
| Text | nvarchar(max) | YES | | label body text |
| QuickCode | nvarchar(8) | YES | | sampled values: `""` (empty string) ×50 — all 50 rows have blank QuickCode in this sample |
| LastModified | datetime | YES | | |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none
- **Inbound (inferred):** none

**Indexes** — none reported.

**Gotchas**
- `QuickCode` is empty string (not NULL) across all 50 sampled rows — despite the column existing for short-code lookup, it appears unused/unpopulated in this tenant; don't assume it's a reliable lookup key.
- No inferred or declared relationships to any other table — this table is an isolated lookup/catalog with no visible link to where/how labels are applied to specific prescriptions.
- Not mirrored by ETL, so unavailable in liberty_link_stage; any reporting needing auxiliary-label text must query Liberty directly.

---

## `rxqVoidedItem`

Rows (RXCS): 1,105 | Columns: 5 | PK: `voidedItemID` | ETL-mirrored into liberty_link_stage: no

**Purpose**

Stores an audit trail of deleted/voided pharmacy records, capturing the entire deleted row as an XML blob (`itemXML`) rather than as discrete relational columns (inferred). `itemType` (varchar(100)) presumably classifies which kind of record was voided (e.g. item/order/refill type) (inferred), `deletedByUser` records the operator who performed the deletion, and `datetimeCreated` timestamps the void event. Because the deleted entity is serialized into XML instead of foreign-keyed columns, this table carries no explicit or inferable link back to the source record's own primary key — it functions as a generic "soft-delete/undo log" rather than a normal child/detail table (inferred).

**Columns**

| Column | Type | Null | Key | Notes |
|---|---|---|---|---|
| voidedItemID | int | NO | PK | identity |
| itemXML | xml | NO | | full serialized copy of the deleted record |
| datetimeCreated | datetime | NO | | timestamp of the void/delete event |
| deletedByUser | varchar(50) | YES | | operator/user who performed the deletion; no lookup values sampled |
| itemType | varchar(100) | NO | | classifies the type of voided item; no lookup values sampled |

**Relationships**

Declared foreign keys: none (verified via sys.foreign_keys — Liberty declares no FK constraints).

- **Outbound (inferred):** none — no columns in this table matched naming/data patterns to any parent table (the voided entity's identity lives only inside `itemXML`, not in a relational column).
- **Inbound (inferred):** none — no other table's columns were inferred to reference `rxqVoidedItem`.

**Indexes**

None defined beyond the PK (indexes list is empty).

**Gotchas**

- The deleted record's original ID/type-specific fields are locked inside the `itemXML` blob — there is no relational way to join this table back to the source row or table; any reconstruction requires parsing the XML.
- `itemType` and `deletedByUser` have no sampled lookup values in this extract, so their coded domains are unknown/undocumented here.
- Not ETL-mirrored into liberty_link_stage, so this audit trail is invisible to downstream eMed reporting/analytics — only present in the live Liberty pharmacy DB.

---
