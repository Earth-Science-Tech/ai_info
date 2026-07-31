-- InventoryTransactions   (0 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[InventoryTransactions] (
    [Id] int IDENTITY NOT NULL,
    [DrugId] varchar(50) NOT NULL,
    [StoreNumber] varchar(50) NULL,
    [Amount] decimal(12,3) NULL,
    [CreatedOn] datetime NULL,
    [ScriptOperationsId] int NULL,
    [InventoryOperationsId] int NULL,
    [AverageContainerAcq] decimal(18,4) NULL,
    [AverageUnitAcq] decimal(18,4) NULL,
    CONSTRAINT [PK_InventoryTransactions] PRIMARY KEY ([Id])
);
