-- rxqScriptLinks   (0 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqScriptLinks] (
    [ScriptLinkId] uniqueidentifier NOT NULL,
    [cScriptBaseId1] int NOT NULL,
    [ScriptNumber1] int NOT NULL,
    [cScriptBaseId2] int NOT NULL,
    [ScriptNumber2] int NOT NULL,
    CONSTRAINT [PK_rxqScriptLinks] PRIMARY KEY ([ScriptLinkId])
);
