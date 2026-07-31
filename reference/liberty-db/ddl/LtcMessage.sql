-- LtcMessage   (0 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[LtcMessage] (
    [Id] int IDENTITY NOT NULL,
    [MessageType] int NOT NULL,
    [eScriptId] int NOT NULL,
    [DateReceived] datetime NOT NULL,
    [DateLastModified] datetime NOT NULL,
    [Status] int NOT NULL,
    [StoreNumber] varchar(50) NULL,
    [LtcOutboundMessageId] int NULL,
    CONSTRAINT [PK_LtcMessage] PRIMARY KEY ([Id])
);
