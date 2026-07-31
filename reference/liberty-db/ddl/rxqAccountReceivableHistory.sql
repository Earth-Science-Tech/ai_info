-- rxqAccountReceivableHistory   (0 rows, 28 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAccountReceivableHistory] (
    [cAccountReceivableHistoryId] int IDENTITY NOT NULL,
    [AgingDate] datetime NOT NULL,
    [Partition] varchar(50) NOT NULL,
    [ARBatch] varchar(50) NOT NULL,
    [AccountId] varchar(50) NOT NULL,
    [ARType] varchar(50) NOT NULL,
    [RecordNumber] varchar(50) NOT NULL,
    [PostDate] date NULL,
    [RecordStatus] varchar(50) NULL,
    [ReferenceNumber] varchar(50) NULL,
    [Description] varchar(200) NULL,
    [AppliedToDue] varchar(50) NULL,
    [Amount] varchar(50) NULL,
    [TaxAmount] varchar(50) NULL,
    [TaxRateCode] varchar(50) NULL,
    [StoreNumber] varchar(50) NULL,
    [TaxFlag] varchar(50) NULL,
    [RelStatus] varchar(50) NULL,
    [Comment] varchar(200) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    [CreatedDateTime] datetime NULL,
    [ItemPatientId] nvarchar(50) NULL,
    [ScriptNumber] int NULL,
    [RefillNumber] int NULL,
    [CHECK_NUM] varchar(25) NULL,
    [TicketNumber] varchar(50) NULL,
    [AccountReceivableID] int NULL,
    CONSTRAINT [PK_rxqAccountReceivableHistory] PRIMARY KEY ([AgingDate], [Partition], [ARBatch], [AccountId], [ARType], [RecordNumber])
);

-- Indexes
CREATE INDEX [IX_AccountReceivableHistory_FamilyIdentification] ON [dbo].[rxqAccountReceivableHistory] ([AccountId]);
CREATE INDEX [IX_rxqAccountReceivableHistory_ItemFamilyId] ON [dbo].[rxqAccountReceivableHistory] ([ItemPatientId]);
