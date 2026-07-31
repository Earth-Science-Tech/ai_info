-- rxqRxChangeRequest   (0 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqRxChangeRequest] (
    [RequestEscriptId] int NOT NULL,
    [ScriptNumber] int NOT NULL,
    [ChangeType] int NOT NULL,
    [Status] int NOT NULL,
    [DateCreated] datetime NOT NULL,
    [LastModified] datetime NOT NULL,
    CONSTRAINT [PK_rxqRxChangeRequest] PRIMARY KEY ([RequestEscriptId])
);
