-- rxqAlternateBarcodeDetail   (0 rows, 3 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAlternateBarcodeDetail] (
    [Identifier] varchar(256) NOT NULL,
    [Type] int NOT NULL,
    [AlternateBarcodeId] int NOT NULL,
    CONSTRAINT [PK_rxqAlternateBarcodeDetail] PRIMARY KEY ([Identifier], [Type], [AlternateBarcodeId])
);
