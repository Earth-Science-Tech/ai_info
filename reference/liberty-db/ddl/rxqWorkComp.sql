-- rxqWorkComp   (0 rows, 16 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqWorkComp] (
    [cWorkCompId] numeric(18,0) IDENTITY NOT NULL,
    [ScriptNumber] int NOT NULL,
    [RefillNumber] int NOT NULL,
    [PatientId] varchar(50) NULL,
    [InvoiceNumber] varchar(50) NULL,
    [InvoiceDate] date NULL,
    [Amount] decimal(9,2) NULL,
    [PayAmount] float NULL,
    [PurgeFlag] varchar(50) NULL,
    [ChkNumber] varchar(50) NULL,
    [StoreNumber] varchar(50) NULL,
    [PatientId_Y2K] varchar(50) NULL,
    [m_InjuryDate] date NULL,
    [FormType] varchar(50) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    CONSTRAINT [PK_rxqWorkComp] PRIMARY KEY ([ScriptNumber], [RefillNumber])
);

-- Indexes
CREATE INDEX [IX_WorkComp_PlanKey] ON [dbo].[rxqWorkComp] ([PatientId], [m_InjuryDate]);
