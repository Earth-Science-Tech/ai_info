-- rxqDrugSigs   (5 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDrugSigs] (
    [DrugKey] nchar(4) NOT NULL,
    [Sigs] nvarchar(500) NULL,
    [LastModified] datetime NOT NULL,
    [IsValid] bit NOT NULL,
    CONSTRAINT [PK_rxqDrugSigs] PRIMARY KEY ([DrugKey])
);
