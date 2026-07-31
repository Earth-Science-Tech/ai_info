-- rxqAcceptInventoryDetail   (0 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAcceptInventoryDetail] (
    [cAcceptInventoryDetailId] int IDENTITY NOT NULL,
    [cAcceptInventoryId] int NULL,
    [InventoryChange] decimal(14,5) NULL,
    [PackagesScanned] int NULL,
    [DateAdded] datetime NULL,
    [NDCNumber] varchar(50) NULL,
    [DrugId] varchar(50) NULL,
    [LastModified] datetime NULL,
    [BulkOrder] bit NULL,
    CONSTRAINT [PK_rxqAcceptInventoryDetail] PRIMARY KEY ([cAcceptInventoryDetailId])
);
