-- rxqDrugHotList   (0 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDrugHotList] (
    [id] int IDENTITY NOT NULL,
    [drug_key] varchar(50) NOT NULL,
    [quantity] decimal(9,2) NOT NULL,
    [price] decimal(9,2) NOT NULL,
    CONSTRAINT [PK_rxqDrugHotList] PRIMARY KEY ([id])
);

-- Indexes
CREATE UNIQUE INDEX [IX_rxqDrugHotList] ON [dbo].[rxqDrugHotList] ([drug_key], [quantity]);
