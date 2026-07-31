-- rxqPendingStockReturn   (1 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPendingStockReturn] (
    [ScriptNumber] int NOT NULL,
    [Source] varchar(50) NULL,
    [DateAdded] datetime NOT NULL,
    [Status] int NULL,
    CONSTRAINT [PK_rxqPendingStockReturn] PRIMARY KEY ([ScriptNumber])
);
