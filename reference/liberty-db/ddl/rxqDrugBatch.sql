-- rxqDrugBatch   (17,379 rows, 15 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDrugBatch] (
    [BatchId] nvarchar(50) NOT NULL,
    [DrugId] nvarchar(50) NULL,
    [StoreNumber] nvarchar(50) NULL,
    [LotNumber] nvarchar(max) NULL,
    [ExpirationDate] datetime NULL,
    [QtyInStock] decimal(12,3) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    [CreatedOn] datetime NULL,
    [CreatedBy] nvarchar(max) NULL,
    [LastDateDispensed] datetime NULL,
    [AuditTracking] nvarchar(max) NULL,
    [QtyOriginal] decimal(9,3) NULL,
    [VerifiedBy] varchar(200) NULL,
    [Wastage] decimal(18,8) NULL,
    CONSTRAINT [PK_rxqDrugBatch] PRIMARY KEY ([BatchId])
);

-- Indexes
CREATE INDEX [Batch-DrugIdIndex] ON [dbo].[rxqDrugBatch] ([DrugId]);
