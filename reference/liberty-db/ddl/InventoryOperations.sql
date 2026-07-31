-- InventoryOperations   (0 rows, 10 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[InventoryOperations] (
    [Id] int IDENTITY NOT NULL,
    [DrugId] varchar(50) NULL,
    [StoreNumber] varchar(50) NULL,
    [Amount] decimal(12,3) NULL,
    [Completed] bit NULL,
    [cOrderId] int NULL,
    [cAcceptInventoryId] int NULL,
    [cInventoryTransferHeaderId] varchar(50) NULL,
    [CreatedOn] datetime NULL,
    [LotNumber] varchar(50) NULL,
    CONSTRAINT [PK_InventoryOperations] PRIMARY KEY ([Id])
);
