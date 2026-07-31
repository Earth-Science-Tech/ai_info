-- rxqCancelRx   (837 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqCancelRx] (
    [RequestEscriptId] int NOT NULL,
    [StoreNumber] varchar(2) NOT NULL,
    [ScriptNumber] int NULL,
    [PendingScriptTransactionId] int NULL,
    [DateCreated] datetime NOT NULL,
    [LastModified] datetime NOT NULL,
    [Status] int NOT NULL,
    CONSTRAINT [PK_rxqCancelRx] PRIMARY KEY ([RequestEscriptId])
);
