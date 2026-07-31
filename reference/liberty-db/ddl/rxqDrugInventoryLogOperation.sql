-- rxqDrugInventoryLogOperation   (14 rows, 2 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDrugInventoryLogOperation] (
    [id] int IDENTITY NOT NULL,
    [operation] varchar(100) NOT NULL,
    CONSTRAINT [PK_rxqDrugInventoryLogOperation] PRIMARY KEY ([id])
);
