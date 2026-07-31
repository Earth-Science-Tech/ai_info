-- rxqScriptIOU   (0 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqScriptIOU] (
    [cScriptIOUId] int IDENTITY NOT NULL,
    [ScriptNumber] int NULL,
    [Refill] int NULL,
    [Notes] varchar(500) NULL,
    [QuantityOwed] varchar(20) NULL,
    [Complete] bit NULL,
    [CompleteDate] datetime NULL,
    CONSTRAINT [PK_rxqScriptIOU] PRIMARY KEY ([cScriptIOUId])
);

-- Indexes
CREATE INDEX [IX_Complete] ON [dbo].[rxqScriptIOU] ([Complete]);
CREATE INDEX [IX_Refill] ON [dbo].[rxqScriptIOU] ([Refill]);
CREATE INDEX [IX_ScriptNumber] ON [dbo].[rxqScriptIOU] ([ScriptNumber]);
