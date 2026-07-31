-- rxqScriptBase   (573,164 rows, 49 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
-- NOTE: mirrored into liberty_link_stage by the eMed ETL.
CREATE TABLE [dbo].[rxqScriptBase] (
    [cScriptBaseId] numeric(18,0) IDENTITY NOT NULL,
    [ScriptNumber] int NOT NULL,
    [LastRefillNumber] int NULL,
    [PatientId] varchar(50) NULL,
    [DrugKey] varchar(50) NULL,
    [DrugSchedule] varchar(50) NULL,
    [DateWrittenSQL] date NULL,
    [DoctorId] varchar(50) NULL,
    [FullDispenseQuantity] decimal(9,3) NULL,
    [AuthorizedQuantity] decimal(12,3) NULL,
    [AvailableQuantity] decimal(12,3) NULL,
    [RefillsAuthorized] int NULL,
    [NumberOfLabels] int NULL,
    [ScriptStatus] int NULL,
    [StoreNumber] varchar(50) NULL,
    [CvtFrom] int NULL,
    [InjuryDate] date NULL,
    [OnHold] varchar(50) NULL,
    [TransferSwitch] varchar(50) NULL,
    [RefillUntilDate] date NULL,
    [EScriptTransactionId] int NULL,
    [UsersReference] varchar(50) NULL,
    [CycleFill] bit NOT NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    [OriginationDate] date NULL,
    [PetsName] varchar(50) NULL,
    [PetsSpecies] varchar(50) NULL,
    [OfficeUse] bit NULL,
    [AccuFloPriority] varchar(50) NULL,
    [MedSyncCode] int NULL,
    [RxFromNumber] int NULL,
    [NewScriptNumber] int NULL,
    [AuthorizedBy] varchar(50) NULL,
    [NewDateDone] date NULL,
    [PrescriptionOrigin] varchar(50) NULL,
    [EffectiveDate] date NULL,
    [XDeaFlag] int NULL,
    [OpioidTreatmentType] int NULL,
    [PRN] bit NULL,
    [DefaultAgencyUpdatedCheck] bit NULL,
    [DrugUnitMultiplierId] int NULL,
    [DataEnteredBy] varchar(50) NULL,
    [cNHHomeId] int NULL,
    [DoNotCF] bit NULL,
    [IsLinked] bit NULL,
    [StopCfWarning] bit NULL,
    [StopEquivalentCfWarning] bit NULL,
    [SameChainOrigin] bit NULL,
    CONSTRAINT [PK_rxqScriptBase] PRIMARY KEY ([ScriptNumber])
);

-- Indexes
CREATE INDEX [_dta_index_rxqScriptBase_36_142623551__K21_K2_K4_K23_K14_3_8_15_17_18_20_22_24_25_30_31_33_43_45_47] ON [dbo].[rxqScriptBase] ([StoreNumber], [ScriptNumber], [PatientId], [InjuryDate], [DoctorId]) INCLUDE ([LastRefillNumber], [DateWrittenSQL], [FullDispenseQuantity], [AvailableQuantity], [RefillsAuthorized], [ScriptStatus], [CvtFrom], [OnHold], [TransferSwitch], [RefillUntilDate], [EScriptTransactionId], [CycleFill], [RxFromNumber], [AuthorizedBy], [PrescriptionOrigin]);
CREATE INDEX [IX_cScriptBase] ON [dbo].[rxqScriptBase] ([ScriptNumber]);
CREATE INDEX [IX_rxqScriptBase_MedSyncCode] ON [dbo].[rxqScriptBase] ([MedSyncCode]) INCLUDE ([ScriptNumber], [PatientId], [DrugKey], [DoctorId], [AvailableQuantity], [RefillUntilDate]);
CREATE INDEX [IX_rxqScriptBase_Script_PatientId] ON [dbo].[rxqScriptBase] ([ScriptNumber]) INCLUDE ([PatientId]);
CREATE INDEX [IX_ScriptBase_DoctorId] ON [dbo].[rxqScriptBase] ([DoctorId]);
CREATE INDEX [IX_ScriptBase_DoctorID_DateWrittenSQL] ON [dbo].[rxqScriptBase] ([DoctorId], [DateWrittenSQL]) INCLUDE ([ScriptNumber]);
CREATE INDEX [IX_ScriptBase_DrugKey] ON [dbo].[rxqScriptBase] ([DrugKey]);
CREATE INDEX [IX_ScriptBase_PatientId_OnHold] ON [dbo].[rxqScriptBase] ([PatientId], [OnHold]) INCLUDE ([ScriptNumber], [LastRefillNumber]);
CREATE INDEX [IX_ScriptBase_StoreNumber] ON [dbo].[rxqScriptBase] ([StoreNumber]);
CREATE INDEX [IX_ScriptBase_WaitingBin] ON [dbo].[rxqScriptBase] ([ScriptNumber]) INCLUDE ([PatientId], [DoctorId], [StoreNumber], [CycleFill], [MedSyncCode]);
CREATE INDEX [missing_index_4_3_rxqScriptBase] ON [dbo].[rxqScriptBase] ([OnHold]) INCLUDE ([ScriptStatus], [TransferSwitch]);
