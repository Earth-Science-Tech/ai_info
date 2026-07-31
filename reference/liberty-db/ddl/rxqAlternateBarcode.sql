-- rxqAlternateBarcode   (0 rows, 2 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAlternateBarcode] (
    [Id] int IDENTITY NOT NULL,
    [Value] nvarchar(max) NULL,
    CONSTRAINT [PK_rxqAlternateBarcode] PRIMARY KEY ([Id])
);
