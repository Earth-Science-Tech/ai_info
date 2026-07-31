-- rxqDrugOptions   (2,820 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDrugOptions] (
    [StoreNumber] varchar(50) NOT NULL,
    [DrugId] varchar(50) NOT NULL,
    [InActive] bit NOT NULL,
    [InAutoDispenser] bit NOT NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    [IsCentralFill] bit NULL,
    [AltPackSize] decimal(10,3) NULL,
    CONSTRAINT [PK_rxqDrugOptions] PRIMARY KEY ([StoreNumber], [DrugId])
);
