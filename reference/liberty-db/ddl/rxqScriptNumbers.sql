-- rxqScriptNumbers   (5 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqScriptNumbers] (
    [StoreNumber] char(2) NOT NULL,
    [NumberingScheme] int NOT NULL,
    [Standard] int NOT NULL,
    [Schedule2] int NOT NULL,
    [Schedule3_5] int NOT NULL,
    [OTC] int NOT NULL,
    [LastModified] datetime NOT NULL,
    [IsValid] bit NOT NULL,
    [OfficeUse] int NOT NULL,
    CONSTRAINT [PK_rxqScriptNumbers] PRIMARY KEY ([StoreNumber])
);
