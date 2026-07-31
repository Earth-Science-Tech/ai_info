-- rxqProfileOnlyScripts   (2 rows, 14 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqProfileOnlyScripts] (
    [KeyId] int IDENTITY NOT NULL,
    [PatientId] varchar(50) NOT NULL,
    [DrugKey] varchar(50) NOT NULL,
    [PharmacyId] varchar(50) NULL,
    [DateAdded] datetime NOT NULL,
    [QtyWritten] decimal(9,2) NULL,
    [DaysSupply] decimal(9,2) NULL,
    [Sigs] nvarchar(500) NULL,
    [Discontinue] date NULL,
    [ScriptNumber] varchar(50) NULL,
    [RefillNumber] varchar(50) NULL,
    [DoctorId] varchar(50) NULL,
    [IncludeOnMedSheets] bit NULL,
    [CodedSigs] varchar(500) NULL,
    CONSTRAINT [PK_rxqProfileOnlyScripts] PRIMARY KEY ([KeyId])
);

-- Indexes
CREATE INDEX [Patient_Drug] ON [dbo].[rxqProfileOnlyScripts] ([PatientId], [DrugKey]);
