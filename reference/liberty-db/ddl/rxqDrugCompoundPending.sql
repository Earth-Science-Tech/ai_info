-- rxqDrugCompoundPending   (4,876 rows, 13 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDrugCompoundPending] (
    [cDrugCompoundPendingId] int IDENTITY NOT NULL,
    [DrugId] nvarchar(50) NULL,
    [StoreNumber] nvarchar(50) NULL,
    [QtyInMake] decimal(12,5) NULL,
    [DateAdded] datetime NULL,
    [LastModified] datetime NULL,
    [Stage] int NULL,
    [BatchId] varchar(50) NULL,
    [ProblemNotes] varchar(500) NULL,
    [ItemType] int NULL,
    [ScriptNumber] int NULL,
    [RefillNumber] int NULL,
    [Wastage] decimal(18,8) NULL,
    CONSTRAINT [PK_rxqDrugCompoundPending] PRIMARY KEY ([cDrugCompoundPendingId])
);
