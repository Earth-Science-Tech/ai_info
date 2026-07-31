-- rxqScriptDrugBatch   (464,932 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqScriptDrugBatch] (
    [id] nvarchar(50) NOT NULL,
    [ScriptNumber] int NULL,
    [RefillNumber] int NULL,
    [BatchId] nvarchar(50) NULL,
    [Qty] decimal(12,3) NULL,
    CONSTRAINT [PK_rxqScriptDrugBatch] PRIMARY KEY ([id])
);

-- Indexes
CREATE INDEX [_dta_index_rxqScriptDrugBatch_36_1531152500__K2_3_4] ON [dbo].[rxqScriptDrugBatch] ([ScriptNumber]) INCLUDE ([RefillNumber], [BatchId]);
CREATE INDEX [batchScriptBatch] ON [dbo].[rxqScriptDrugBatch] ([BatchId]);
CREATE INDEX [scriptrefillDrugBatch] ON [dbo].[rxqScriptDrugBatch] ([ScriptNumber], [RefillNumber]);
