-- rxqShipmentScriptNumber   (327,094 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
-- NOTE: mirrored into liberty_link_stage by the eMed ETL.
CREATE TABLE [dbo].[rxqShipmentScriptNumber] (
    [id] nvarchar(50) NOT NULL,
    [ShipmentId] int NULL,
    [ScriptNumber] int NULL,
    [RefillNumber] int NULL,
    [ShipmentWorkflowStatus] int NULL,
    [StatusClearedBy] varchar(50) NULL,
    [ClearedAt] datetime NULL,
    CONSTRAINT [PK_rxqShipmentScriptNumber] PRIMARY KEY ([id])
);

-- Indexes
CREATE INDEX [IX_rxqShipmentScriptNumber] ON [dbo].[rxqShipmentScriptNumber] ([ScriptNumber], [RefillNumber]);
CREATE INDEX [IX_ShipmentScript_ScriptRefill_ID] ON [dbo].[rxqShipmentScriptNumber] ([ScriptNumber], [RefillNumber]) INCLUDE ([ShipmentId]);
