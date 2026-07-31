-- rxqDrugInventory   (2,550 rows, 12 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDrugInventory] (
    [cDrugInventoryId] int IDENTITY NOT NULL,
    [DrugInventoryKey] varchar(50) NOT NULL,
    [QtyInStock] decimal(12,3) NULL,
    [ReorderPoint] decimal(12,3) NULL,
    [ReorderQty] decimal(12,3) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NOT NULL,
    [StoreNumber] varchar(50) NOT NULL,
    [SnoozeOrder] bit NULL,
    [SnoozeUntil] datetime NULL,
    [InventoryType] int NULL,
    [ContainerQuantityPartition] bit NULL,
    CONSTRAINT [PK_rxqDrugInventory] PRIMARY KEY ([DrugInventoryKey], [StoreNumber])
);

-- Indexes
CREATE INDEX [IDX_DrugInventory_IsValidDrugInventoryKeyStoreNumber] ON [dbo].[rxqDrugInventory] ([StoreNumber], [IsValid], [DrugInventoryKey]);
