-- rxqScriptDrugSplit   (0 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqScriptDrugSplit] (
    [cScriptDrugSplitId] int IDENTITY NOT NULL,
    [DrugId] varchar(50) NOT NULL,
    [ScriptNumber] int NOT NULL,
    [RefillNumber] int NOT NULL,
    [Qty] decimal(12,3) NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqScriptDrugSplit] PRIMARY KEY ([cScriptDrugSplitId])
);

-- Indexes
CREATE INDEX [IX_cScriptDrugSplit] ON [dbo].[rxqScriptDrugSplit] ([ScriptNumber], [RefillNumber]);
