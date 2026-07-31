-- rxqAccountReceivable   (49,909 rows, 27 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAccountReceivable] (
    [cAccountReceivableId] int IDENTITY NOT NULL,
    [Partition] varchar(50) NOT NULL,
    [ARBatch] varchar(50) NOT NULL,
    [AccountId] varchar(50) NOT NULL,
    [ARType] int NOT NULL,
    [RecordNumber] int NOT NULL,
    [PostDate] date NULL,
    [RecordStatus] varchar(50) NULL,
    [ReferenceNumber] varchar(50) NULL,
    [Description] varchar(200) NULL,
    [AppliedToDue] float NULL,
    [Amount] float NULL,
    [TaxAmount] float NULL,
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
    CONSTRAINT [PK_rxqAccountReceivable] PRIMARY KEY ([Partition], [ARBatch], [AccountId], [ARType], [RecordNumber])
);

-- Indexes
CREATE INDEX [IX_AccountReceivable_FamilyIdentification] ON [dbo].[rxqAccountReceivable] ([AccountId]);
CREATE INDEX [IX_rxqAccountReceivable_ItemFamilyId] ON [dbo].[rxqAccountReceivable] ([ItemPatientId]);
