# Liberty schema — empty / unused tables

These **187 tables exist in the Liberty schema but hold 0 rows in the RXCS instance** — they correspond to Liberty features Rx Compound Store does not use (LTC/nursing-home sub-modules, some clinical/immunization sub-tables, unused integrations, etc.). They are present in the schema across all tenants (rxcs/mmed/mdvo); another tenant *could* populate some of them. Full column-level DDL for each is in [`ddl/`](ddl/) (e.g. `ddl/<TableName>.sql`), and machine-readable metadata is in [`catalog/liberty_catalog.json`](catalog/liberty_catalog.json).

They are listed here (not given narrative docs) because with no data there is nothing operational to describe. If a feature ever needs one, read its DDL and confirm whether the target tenant actually populates it.

| Table | Columns | PK |
|---|---|---|
| `AcceptInventoryDetailPackageLink` | 2 | AcceptInventoryDetailId, PackageId |
| `AppointmentBase` | 17 | Id |
| `AppointmentDay` | 5 | Id |
| `AppointmentItem` | 12 | Id |
| `AppointmentSetting` | 18 | Id |
| `BillingEvents` | 7 | ScriptNumber, RefillNumber, Sequence, PayerOrder |
| `BillingStatus` | 11 | ScriptNumber, RefillNumber, PayerOrder |
| `BinAssignmentHistory` | 8 | Id |
| `BulkInventoryEvent` | 5 | Id |
| `CentralFillCompletedOrders` | 8 | ID |
| `CentralFillDeliveryAudit` | 10 | Id |
| `CentralFillSchedule` | 7 | DeliveryNumber, ServiceId |
| `CentralFillScheduleException` | 7 | Id, DeliveryNumber, ServiceId |
| `CentralFillScriptDetails` | 18 | Id |
| `CentralFillService` | 19 | Id |
| `CompoundMonographNotes` | 2 | NoteID |
| `CustomViewsPickedUp` | 6 | ID |
| `CustomViewsWaitingBin` | 6 | ID |
| `DeliveryRoutes` | 4 | ID |
| `DiscountCard` | 4 | DiscountType, FieldType, Value |
| `DocumentGenerated` | 8 | ID |
| `DrugEquivalentNotes` | 2 | NoteID |
| `DrugNotes` | 2 | NoteID |
| `DrugPreference` | 4 | ID |
| `DscsaSharing` | 6 | ID |
| `dsmAttachment` | 5 | AttachmentId |
| `dsmContact` | 12 | ContactId |
| `dsmFax` | 5 | FaxId |
| `dsmMessage` | 15 | MessageId |
| `dsmPractice` | 3 | PracticeId |
| `dsmUser` | 7 | UserId |
| `ECRSSubmission` | 8 | TransactionCode, ScriptNumber, RefillNumber, PartialNumber |
| `EPCISData` | 3 | Id |
| `EPCISPackage` | 8 | Id |
| `GerGroup` | 3 | Id |
| `HistoricalAppointment` | 25 | Id |
| `InsuranceNotes` | 2 | NoteID |
| `InventoryEventLog` | 9 | Id |
| `InventoryOperations` | 10 | Id |
| `InventoryTransactions` | 9 | Id |
| `InventoryTransferPackageLink` | 4 | InventoryTransferHeaderId, InventoryTransferLineId, PackageId |
| `ItemNotes` | 2 | NoteID |
| `LtcMessage` | 8 | Id |
| `LtcOutboundMessage` | 12 | Id |
| `MasterNotes` | 11 | NoteID |
| `MedSyncNotes` | 2 | NoteID |
| `MedSyncPatientReview` | 6 | PatientId, ProgramDays |
| `OrderLinePackageLink` | 2 | OrderLineId, PackageId |
| `PatientAuxiliary` | 6 | PatientId |
| `PatientConsolidationHistory` | 6 | Id |
| `PatientConsultationDefaultNotes` | 2 | NoteID |
| `PatientConsultationNotes` | 2 | NoteID |
| `PatientNotes` | 2 | NoteID |
| `PickUpNotes` | 3 | NoteID |
| `PrescriberNotes` | 2 | NoteID |
| `PriorAuthorizationRequests` | 11 | ID |
| `Question` | 6 | Id |
| `Questionnaire` | 8 | Id |
| `QuestionnaireCondition` | 5 | Id |
| `QuestionnaireReview` | 8 | Id |
| `ReportFilterTemplates` | 3 | TemplateName, ReportCategory |
| `Rx365PatientAppendix` | 5 | PatientId |
| `RX365PatientLink` | 7 | PatientId, LinkedPatientId |
| `Rx365PushNotification` | 6 | Id |
| `rxqAcceptInventory` | 11 | cAcceptInventoryId |
| `rxqAcceptInventoryDetail` | 9 | cAcceptInventoryDetailId |
| `rxqAccountReceivableHistory` | 28 | AgingDate, Partition, ARBatch, AccountId, ARType, RecordNumber |
| `rxqAccountReceivablePrintCode` | 3 | cAccountReceivablePrintCodeId |
| `rxqAgencyGroup` | 2 | GroupId, AgencyId |
| `rxqALAAC` | 6 | Id |
| `rxqAlternateBarcode` | 2 | Id |
| `rxqAlternateBarcodeDetail` | 3 | Identifier, Type, AlternateBarcodeId |
| `rxqAudit835` | 7 | cAudit835Id |
| `rxqAuditThirdPartyAccounting` | 6 | Id |
| `rxqAwpResubmit` | 27 | id |
| `rxqBCell` | 7 | StoreNumber, PollCode, CellNumber |
| `rxqBookmark` | 4 | cBookmarkId |
| `rxqBulkMessage` | 6 | BulkMessageId |
| `rxqBulkOrderHistory` | 7 | cBulkOrderHistoryId |
| `rxqBulkOrderHistoryDetail` | 5 | cBulkOrderHistoryDetailId |
| `rxqCentralInterfaceHistory` | 6 | Id |
| `rxqClinicalOppAnswer` | 12 | cClinicalOppAnswerId |
| `rxqClinicalOppAnswerHistory` | 4 | Id |
| `rxqClinicalOppSetting` | 15 | cClinicalOppSettingId |
| `rxqCopayPriceBreaks` | 7 | StoreNumber, PriceFormulaCode, CopayType, PriceBreak |
| `rxqCouponDrug` | 4 | id |
| `rxqCouponEntry` | 8 | id |
| `rxqCourier` | 12 | Id |
| `rxqCycleFillAuthorization` | 6 | CycleFillAuthorizationId |
| `rxqDeletedDoctor` | 3 | deletedDoctorID |
| `rxqDirFees` | 5 | Id, DrugType |
| `rxqDirFeesConditional` | 6 | cDirFeesConditionalId |
| `rxqDisease` | 9 | DiseaseCode |
| `rxqDispenser` | 16 | cDispenserId |
| `rxqDrugCatalog` | 7 | cDrugCatalogId |
| `rxqDrugHotList` | 4 | id |
| `rxqDrugXM` | 8 | KeyType, DrugKey, AgencyCode |
| `rxqDUR` | 11 | ScriptNumber, RefillNumber, Ins_Type, SequenceNumber |
| `rxqEScriptDoctor` | 59 | SurescriptProviderId |
| `rxqFaxModems` | 3 | id |
| `RxqHL7Interfaces` | 9 | InterfaceId |
| `rxqIcd9CrossReference` | 8 | cIcd9CrossReferenceId |
| `rxqImmunizationSubmission` | 6 | SubmissionId |
| `rxqInsuranceCard` | 12 | cInsuranceCardId |
| `rxqInsuranceCardsImages` | 14 | cInsuranceCardsImagesId |
| `rxqInterfaceOptions` | 6 | cInterfaceOptionsId |
| `rxqInterfaceSubmission` | 5 | id |
| `rxqInventoryTransferHeader` | 34 | cInventoryTransferHeaderId, StoreNumber |
| `rxqInventoryTransferLine` | 13 | cInventoryTransferLineId, cInventoryTransferHeaderId, StoreNumber |
| `rxqMedicalInsurance` | 4 | Id |
| `rxqMTMAlert` | 47 | id |
| `rxqMTMOutcomesUsers` | 9 | id |
| `rxqNcpdpNarrative` | 5 | ScriptNumber, RefillNumber |
| `rxqNewRxRequest` | 13 | MessageId |
| `rxqNHMedsheetReport` | 24 | id |
| `rxqNHMedSheetReportDefaultOrdering` | 3 | PatientId, DefaultStandingOrderId |
| `rxqNHOrd` | 18 | m_keyvalue, Prefix, Suffix |
| `rxqNotifications` | 8 | cNotificationId |
| `rxqOnlineHistory` | 202 | cOnlineHistoryId |
| `rxqOnlineNotifications` | 7 | NotificationsId |
| `rxqOrder` | 21 | cOrderId |
| `rxqOrderConfirmation` | 10 | cOrderConfirmationId |
| `rxqOrderDiscrepancy` | 6 | Id |
| `rxqOrderDiscrepancyItem` | 5 | Id |
| `rxqOrderInvoice` | 8 | cOrderInvoiceId |
| `rxqOrderInvoiceLine` | 7 | cOrderInvoiceLineId |
| `rxqOrderVendorSettings` | 118 | cOrderVendorSettingsId |
| `rxqPatientAccountReceivableHistory` | 29 | AgingDate, AccountId |
| `rxqPatientAlias` | 5 | cPatientAliasId |
| `rxqPatientBulkMessage` | 5 | PatientBulkMessageId |
| `rxqPatientCreditCard` | 10 | cPatientCreditCardId |
| `rxqPatientMedicalInsurance` | 7 | Id |
| `rxqPatientPickupDisplayImages` | 4 | id |
| `rxqPlugin` | 9 | PluginId |
| `rxqPriceFormulaClass` | 2 | PriceFormulaPrimaryCode, PriceFormulaChildrenCode |
| `rxqPrintableAttachment` | 8 | cPrintableAttachmentId |
| `rxqQuotes` | 17 | QuoteNumber |
| `rxqRefillRequestTemplate` | 5 | cRefillRequestTemplateId |
| `rxqResubmit` | 198 | ScriptNumber, RefillNumber |
| `rxqRule` | 6 | cRuleId |
| `rxqRuleFilter` | 8 | cFilterId |
| `rxqRX365Chats` | 12 | cRX365ChatsId |
| `rxqRX365PendingPatient` | 20 | Id |
| `rxqRX365TransferInItems` | 5 | cRX365TransferInItemsId |
| `rxqRX365TransferIns` | 15 | cRX365TransferInsId |
| `rxqRxAlertReadyWorkflowLocationSettings` | 5 | SettingId |
| `rxqRxAppointmentAlertSettings` | 13 | RxAppointmentAlertSettingId |
| `rxqRxChangeRequest` | 6 | RequestEscriptId |
| `rxqScheduledDiscontinuation` | 7 | ScriptNumber |
| `rxqScriptDrugSplit` | 6 | cScriptDrugSplitId |
| `rxqScriptIOU` | 7 | cScriptIOUId |
| `rxqScriptLinks` | 5 | ScriptLinkId |
| `rxqScriptPartial` | 20 | cScriptPartialId |
| `rxqScriptPayments` | 62 | ScriptNumber, RefillNumber, SequenceNumber |
| `rxqSecurityBadge` | 4 | UserId |
| `rxqSigsTreatmentSchedule` | 6 | cSigsTreatmentSchedule |
| `rxqSpecialtySubmission` | 7 | ScriptNumber, RefillNumber |
| `rxqStoreContacts` | 9 | cStoreContactsId |
| `rxqStoreHolidays` | 8 | cStoreHolidaysId |
| `rxqSubmitOverride` | 5 | TableId |
| `rxqThirdPartyAccountingAmountExpected` | 5 | ScriptNumber, RefillNumber, ClaimType, IsMFP |
| `rxqTimeClockEntry` | 7 | UserId, ActionDate |
| `rxqUnitDose` | 14 | ScriptNumber |
| `rxqUnitDoseIndividual` | 5 | id |
| `rxqUnitDoseTemplate` | 6 | cUnitDoseTemplateId |
| `rxqUnitDoseTimesQtys` | 4 | id |
| `rxqUserBiometric` | 5 | cUserId |
| `rxqUserDictionary` | 2 | cUserDictionaryId |
| `rxqVideoConference` | 10 | id |
| `rxqWorkComp` | 16 | ScriptNumber, RefillNumber |
| `rxqWorkCompAgency` | 20 | AgencyId |
| `rxqWorkCompEmployer` | 23 | cWorkCompEmployerId |
| `rxqWorkCompLawyer` | 16 | LawKey |
| `rxqWorkCompPayment` | 10 | ScriptNumber, RefillNumber, SequenceNumber |
| `rxqWorkCompPlan` | 19 | cWorkCompPlanId |
| `rxqWorkflowCustomStage` | 5 | WorkflowCustomStageId |
| `rxqWorkFlowFaxHistory` | 7 | cWorkFlowFaxHistoryId |
| `rxqWorkFlowMedSyncCall` | 8 | cWorkFlowMedSyncCallId |
| `rxqWorkflowNDCScanHistory` | 9 | cWorkflowNDCScanHistoryId |
| `ScriptNotes` | 4 | NoteID |
| `ScriptOperations` | 15 | Id |
| `SettingNotes` | 2 | NoteID |
| `SupportedLanguages` | 6 | ID |
| `TransferNotes` | 2 | NoteID |
| `UserPermissions` | 3 | Id |
| `WorkflowEventLog` | 9 | Id |
| `WorkFlowNotes` | 5 | NoteID |
