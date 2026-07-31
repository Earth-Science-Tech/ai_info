-- rxqDrugPricingHistory   (5,165 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDrugPricingHistory] (
    [cDrugPricingHistoryId] int IDENTITY NOT NULL,
    [DrugId] varchar(50) NULL,
    [VendorId] int NULL,
    [PriceType] int NULL,
    [LastChanged] datetime NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqDrugPricingHistory] PRIMARY KEY ([cDrugPricingHistoryId])
);
