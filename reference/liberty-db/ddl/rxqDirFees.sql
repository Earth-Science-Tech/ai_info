-- rxqDirFees   (0 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDirFees] (
    [Id] varchar(50) NOT NULL,
    [Name] varchar(50) NOT NULL,
    [FormulaType] varchar(50) NOT NULL,
    [DrugType] varchar(50) NOT NULL,
    [FeeAmount] float NOT NULL,
    CONSTRAINT [PK_rxqDirFees] PRIMARY KEY ([Id], [DrugType])
);
