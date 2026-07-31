-- PrescriptionRequests   (36 rows, 16 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[PrescriptionRequests] (
    [ID] int IDENTITY NOT NULL,
    [ScriptNumber] int NULL,
    [PatientId] varchar(50) NULL,
    [DrugKey] varchar(50) NULL,
    [DoctorId] varchar(50) NULL,
    [Method] int NULL,
    [Type] int NOT NULL,
    [Status] int NULL,
    [FirstRequest] datetime NULL,
    [LastRequest] datetime NULL,
    [Attempts] int NULL,
    [History] varchar(max) NULL,
    [StoreNumber] varchar(2) NULL,
    [Completed] bit NOT NULL,
    [eScriptTransactionId] int NULL,
    [DateDenied] datetime NULL,
    CONSTRAINT [PK_PrescriptionRequests] PRIMARY KEY ([ID])
);

-- Indexes
CREATE INDEX [IX_PrescriptionRequests_FirstRequest] ON [dbo].[PrescriptionRequests] ([FirstRequest]);
CREATE INDEX [IX_PrescriptionRequests_LastRequest] ON [dbo].[PrescriptionRequests] ([LastRequest]);
