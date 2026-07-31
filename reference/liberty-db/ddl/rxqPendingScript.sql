-- rxqPendingScript   (501,678 rows, 35 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPendingScript] (
    [cPendingScriptId] int IDENTITY NOT NULL,
    [TransactionId] int NOT NULL,
    [TransactionType] int NULL,
    [ImageFileName] varchar(60) NULL,
    [PickedUp] datetime NULL,
    [PickupTimeType] varchar(50) NULL,
    [ScriptStatus] int NULL,
    [PatientId] varchar(50) NULL,
    [Created] datetime NULL,
    [eScriptTransactionId] int NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    [FilledBy] varchar(50) NULL,
    [StoreNumber] varchar(50) NOT NULL,
    [cQueueId] int NULL,
    [TransferScriptNumber] int NULL,
    [TransferRefillNumber] int NULL,
    [TransferStoreId] int NULL,
    [TransferProfileRowString] varchar(max) NULL,
    [TransferPatient3PList] varchar(max) NULL,
    [TransferStoreRecordString] varchar(max) NULL,
    [LastDrugString] varchar(max) NULL,
    [OrigDrugString] varchar(max) NULL,
    [Comment] varchar(max) NULL,
    [HasProblem] bit NULL,
    [ProblemCategory] varchar(256) NULL,
    [ProblemNote] varchar(max) NULL,
    [AddedBy] varchar(50) NULL,
    [DrugId] varchar(50) NULL,
    [NumberOfRXs] int NULL,
    [TransferPatientString] nvarchar(max) NULL,
    [IsUrgent] bit NULL,
    [AppointmentId] uniqueidentifier NULL,
    [PatientWaiting] bit NULL,
    [HasScriptPlan] int NULL,
    CONSTRAINT [PK_rxqPendingScript] PRIMARY KEY ([TransactionId])
);

-- Indexes
CREATE INDEX [IDX_PendingScript_Transactionid_Created_ScStatus_Store] ON [dbo].[rxqPendingScript] ([TransactionId], [Created], [ScriptStatus], [StoreNumber]);
CREATE INDEX [IX_PendingScript_eScriptTransactionId] ON [dbo].[rxqPendingScript] ([eScriptTransactionId]);
CREATE INDEX [IX_PendingScript_ScriptStatus] ON [dbo].[rxqPendingScript] ([ScriptStatus]);
CREATE INDEX [IX_PendingScript_StoreNumber_HasProblem] ON [dbo].[rxqPendingScript] ([StoreNumber], [HasProblem]);
CREATE INDEX [LibertyAuto_32_31_rxqPendingScript] ON [dbo].[rxqPendingScript] ([cPendingScriptId]);
