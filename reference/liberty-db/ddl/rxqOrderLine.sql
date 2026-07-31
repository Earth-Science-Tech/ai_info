-- rxqOrderLine   (23 rows, 28 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqOrderLine] (
    [cOrderLineId] int IDENTITY NOT NULL,
    [Origin] nvarchar(50) NULL,
    [Status] varchar(200) NULL,
    [RxqId] varchar(50) NULL,
    [BzqId] varchar(50) NULL,
    [Qty] decimal(9,3) NULL,
    [AllowSubstitution] bit NULL,
    [Description] varchar(150) NULL,
    [OrderId] int NULL,
    [RequestedQty] decimal(9,3) NULL,
    [UpdatedQty] decimal(9,3) NULL,
    [Cost] decimal(9,2) NULL,
    [VendorName] nvarchar(50) NULL,
    [VendorId] int NULL,
    [OrderNumber] nvarchar(50) NULL,
    [NDCUPC] nvarchar(50) NULL,
    [LastChanged] datetime NULL,
    [ConfirmationNote] nvarchar(max) NULL,
    [RequestedDescription] varchar(150) NULL,
    [InventoryUpdated] bit NULL,
    [ConfirmationMode] int NULL,
    [OrderLineType] int NULL,
    [OrderConfirmationId] int NULL,
    [RequestedItemNumber] varchar(200) NULL,
    [RequestedNDCUPC] varchar(200) NULL,
    [ACQ] decimal(12,5) NULL,
    [BulkOrder] bit NULL,
    [UnexpectedLine] bit NULL,
    CONSTRAINT [PK_rxqOrderLine] PRIMARY KEY ([cOrderLineId])
);

-- Indexes
CREATE INDEX [BzqId] ON [dbo].[rxqOrderLine] ([BzqId]);
CREATE INDEX [OrderId] ON [dbo].[rxqOrderLine] ([OrderId]);
CREATE INDEX [RxqId] ON [dbo].[rxqOrderLine] ([RxqId]);
