-- rxqParameterImage   (1 rows, 3 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqParameterImage] (
    [StoreNumber] varchar(50) NOT NULL,
    [ImageKey] varchar(50) NOT NULL,
    [Image] varbinary(max) NULL,
    CONSTRAINT [PK_rxqParameterImage] PRIMARY KEY ([StoreNumber], [ImageKey])
);
