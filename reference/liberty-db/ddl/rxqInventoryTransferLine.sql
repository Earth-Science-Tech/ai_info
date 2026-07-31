-- rxqInventoryTransferLine   (0 rows, 13 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqInventoryTransferLine] (
    [cInventoryTransferLineId] varchar(50) NOT NULL,
    [cInventoryTransferHeaderId] varchar(50) NOT NULL,
    [Type] int NULL,
    [DrugId] varchar(50) NULL,
    [NdcNumber] varchar(50) NULL,
    [DrugName] varchar(50) NULL,
    [Strength] varchar(50) NULL,
    [DrugForm] varchar(50) NULL,
    [Manufacturer] varchar(50) NULL,
    [QtyToTransfer] decimal(12,3) NULL,
    [ContainerQty] decimal(18,4) NULL,
    [StoreNumber] varchar(50) NOT NULL,
    [PreferredVendorACQ] decimal(10,2) NULL,
    CONSTRAINT [PK_rxqInventoryTransferLine] PRIMARY KEY ([cInventoryTransferLineId], [cInventoryTransferHeaderId], [StoreNumber])
);
