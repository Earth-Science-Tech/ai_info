-- rxqUnitDoseIndividual   (0 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqUnitDoseIndividual] (
    [id] nvarchar(50) NOT NULL,
    [ScriptNumber] int NULL,
    [RefillNumber] int NULL,
    [Quantity] decimal(9,3) NULL,
    [DoseDate] datetime NULL,
    CONSTRAINT [PK_rxqUnitDoseIndividual] PRIMARY KEY ([id])
);

-- Indexes
CREATE INDEX [ScriptRefillIndexUnitDose] ON [dbo].[rxqUnitDoseIndividual] ([ScriptNumber], [RefillNumber]);
