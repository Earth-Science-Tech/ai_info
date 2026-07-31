-- rxqOrderInvoice   (0 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqOrderInvoice] (
    [cOrderInvoiceId] int IDENTITY NOT NULL,
    [OrderId] int NULL,
    [VendorId] int NULL,
    [Amount] decimal(12,3) NULL,
    [InvoiceDate] datetime NULL,
    [InvoiceNumber] varchar(50) NULL,
    [ReferenceNumber] varchar(50) NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqOrderInvoice] PRIMARY KEY ([cOrderInvoiceId])
);

-- Indexes
CREATE INDEX [IX_cOrderIdDESC] ON [dbo].[rxqOrderInvoice] ([OrderId]);
