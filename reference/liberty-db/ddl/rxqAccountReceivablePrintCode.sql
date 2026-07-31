-- rxqAccountReceivablePrintCode   (0 rows, 3 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAccountReceivablePrintCode] (
    [cAccountReceivablePrintCodeId] int IDENTITY NOT NULL,
    [PrintCode] varchar(50) NOT NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqAccountReceivablePrintCode] PRIMARY KEY ([cAccountReceivablePrintCodeId])
);
