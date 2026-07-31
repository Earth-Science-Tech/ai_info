-- ScannedPackage   (6 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[ScannedPackage] (
    [Id] int IDENTITY NOT NULL,
    [GTIN] varchar(14) NULL,
    [NDC] varchar(11) NULL,
    [SerialNumber] varchar(20) NULL,
    [LotNumber] varchar(20) NULL,
    [ExpirationDate] datetime NULL,
    [DateAdded] datetime NULL,
    [Barcode] varchar(80) NULL,
    [FirstScanLocation] varchar(50) NULL,
    CONSTRAINT [PK_ScannedPackage] PRIMARY KEY ([Id])
);

-- Indexes
CREATE INDEX [idx_ScannedPackage_Barcode] ON [dbo].[ScannedPackage] ([Barcode]);
CREATE INDEX [idx_ScannedPackage_DateAdded] ON [dbo].[ScannedPackage] ([DateAdded]);
CREATE INDEX [idx_ScannedPackage_ExpirationDate] ON [dbo].[ScannedPackage] ([ExpirationDate]);
CREATE INDEX [idx_ScannedPackage_GTIN] ON [dbo].[ScannedPackage] ([GTIN]);
CREATE INDEX [idx_ScannedPackage_LotNumber] ON [dbo].[ScannedPackage] ([LotNumber]);
CREATE INDEX [idx_ScannedPackage_NDC] ON [dbo].[ScannedPackage] ([NDC]);
CREATE INDEX [idx_ScannedPackage_SerialNumber] ON [dbo].[ScannedPackage] ([SerialNumber]);
