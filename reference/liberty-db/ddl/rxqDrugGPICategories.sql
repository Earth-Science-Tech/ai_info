-- rxqDrugGPICategories   (101 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDrugGPICategories] (
    [cDrugGPINotesID] int IDENTITY NOT NULL,
    [CategoryKey] varchar(50) NOT NULL,
    [GPI] varchar(50) NOT NULL,
    [GenericOrBrand] char(1) NULL,
    CONSTRAINT [PK_rxqDrugGPICategories] PRIMARY KEY ([cDrugGPINotesID])
);

-- Indexes
CREATE INDEX [IX_GPI] ON [dbo].[rxqDrugGPICategories] ([GPI]);
CREATE INDEX [IX_NoteKey] ON [dbo].[rxqDrugGPICategories] ([CategoryKey]);
CREATE UNIQUE INDEX [unKeyGPI] ON [dbo].[rxqDrugGPICategories] ([CategoryKey], [GPI]);
