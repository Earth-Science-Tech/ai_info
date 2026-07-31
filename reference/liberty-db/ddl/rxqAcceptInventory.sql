-- rxqAcceptInventory   (0 rows, 11 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAcceptInventory] (
    [cAcceptInventoryId] int IDENTITY NOT NULL,
    [POName] varchar(200) NULL,
    [cVendorId] int NULL,
    [DateAdded] datetime NULL,
    [DateUpdated] datetime NULL,
    [OrderStatus] int NOT NULL,
    [OrderInventoryType] int NOT NULL,
    [StoreNumber] varchar(2) NULL,
    [LastModified] datetime NULL,
    [UpdatedInventoryUser] varchar(200) NULL,
    [OrderType] int NULL,
    CONSTRAINT [PK_rxqAcceptInventory] PRIMARY KEY ([cAcceptInventoryId])
);
