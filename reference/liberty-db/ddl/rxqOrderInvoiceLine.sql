-- rxqOrderInvoiceLine   (0 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqOrderInvoiceLine] (
    [cOrderInvoiceLineId] int IDENTITY NOT NULL,
    [OrderInvoiceId] int NULL,
    [OrderLineId] int NULL,
    [Qty] decimal(12,3) NULL,
    [Status] varchar(200) NULL,
    [InventoryUpdated] bit NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqOrderInvoiceLine] PRIMARY KEY ([cOrderInvoiceLineId])
);

-- Indexes
CREATE INDEX [IX_OrderInvoiceIdDESC] ON [dbo].[rxqOrderInvoiceLine] ([OrderInvoiceId]);
