-- rxqDrugCatalog   (0 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDrugCatalog] (
    [cDrugCatalogId] int IDENTITY NOT NULL,
    [DrugVendorNumber] varchar(50) NULL,
    [DrugVendorId] int NULL,
    [DrugNdc] varchar(50) NULL,
    [Acq] decimal(12,2) NULL,
    [LastModified] datetime NULL,
    [VendorGeneric] bit NULL,
    CONSTRAINT [PK_rxqDrugCatalog] PRIMARY KEY ([cDrugCatalogId])
);

-- Indexes
CREATE INDEX [IX_cDrugCatalog] ON [dbo].[rxqDrugCatalog] ([DrugVendorNumber], [DrugVendorId]);
CREATE INDEX [IX_rxqDrugCatalog_DrugNDC] ON [dbo].[rxqDrugCatalog] ([DrugNdc]);
