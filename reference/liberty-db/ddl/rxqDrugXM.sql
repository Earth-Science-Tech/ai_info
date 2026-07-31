-- rxqDrugXM   (0 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDrugXM] (
    [cDrugXMId] int IDENTITY NOT NULL,
    [KeyType] varchar(50) NOT NULL,
    [DrugKey] varchar(50) NOT NULL,
    [AgencyCode] varchar(50) NOT NULL,
    [MaxCost] float NULL,
    [MaxQuantity] float NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    CONSTRAINT [PK_rxqDrugXM] PRIMARY KEY ([KeyType], [DrugKey], [AgencyCode])
);
