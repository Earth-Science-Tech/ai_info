-- rxqDrugInventoryLogChange   (691,346 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDrugInventoryLogChange] (
    [id] int IDENTITY NOT NULL,
    [MasterId] int NOT NULL,
    [PropertyChanged] varchar(50) NOT NULL,
    [ChangeAmount] decimal(12,3) NOT NULL,
    [ValueAfterChange] decimal(12,3) NOT NULL,
    [ValueBeforeChange] decimal(12,3) NOT NULL,
    CONSTRAINT [PK_rxqDrugInventoryLogChange] PRIMARY KEY ([id])
);

-- Indexes
CREATE INDEX [IX_DrugInventoryLogChange_MasterId] ON [dbo].[rxqDrugInventoryLogChange] ([MasterId]);
