-- rxqBCell   (0 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqBCell] (
    [cBCellId] int IDENTITY NOT NULL,
    [StoreNumber] varchar(50) NOT NULL,
    [PollCode] varchar(50) NOT NULL,
    [CellNumber] varchar(50) NOT NULL,
    [DrugKey] varchar(50) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    CONSTRAINT [PK_rxqBCell] PRIMARY KEY ([StoreNumber], [PollCode], [CellNumber])
);
