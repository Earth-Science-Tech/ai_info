-- InventoryTransferPackageLink   (0 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[InventoryTransferPackageLink] (
    [InventoryTransferHeaderId] varchar(50) NOT NULL,
    [InventoryTransferLineId] varchar(50) NOT NULL,
    [PackageId] int NOT NULL,
    [Quantity] decimal(18,4) NULL,
    CONSTRAINT [PK_InventoryTransferPackageLink] PRIMARY KEY ([InventoryTransferHeaderId], [InventoryTransferLineId], [PackageId])
);

-- Indexes
CREATE INDEX [idx_InventoryTransferPackageLink_PackageId] ON [dbo].[InventoryTransferPackageLink] ([PackageId]);
