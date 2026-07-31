-- rxqVendor   (56 rows, 16 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqVendor] (
    [cVendorId] int IDENTITY NOT NULL,
    [VendorName] varchar(50) NULL,
    [Notes] varchar(500) NULL,
    [System] bit NOT NULL,
    [SystemKey] char(3) NULL,
    [Active] bit NOT NULL,
    [PrimaryVendor] bit NOT NULL,
    [GenericRate] decimal(9,3) NULL,
    [BrandRate] decimal(9,3) NULL,
    [CustomerNumber] varchar(200) NULL,
    [UseInRXQ] bit NULL,
    [UseInBZQ] bit NULL,
    [PrimaryVendorRXQ] bit NULL,
    [PrimaryVendorBZQ] bit NULL,
    [DscsaProvider] varchar(50) NULL,
    [IsFlavoRx] bit NULL,
    CONSTRAINT [PK_rxqVendor] PRIMARY KEY ([cVendorId])
);

-- Indexes
CREATE INDEX [IX_Active] ON [dbo].[rxqVendor] ([Active]);
CREATE INDEX [IX_SystemKey] ON [dbo].[rxqVendor] ([SystemKey]);
