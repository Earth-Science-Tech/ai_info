-- rxqPriceFormulaClass   (0 rows, 2 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPriceFormulaClass] (
    [PriceFormulaPrimaryCode] varchar(50) NOT NULL,
    [PriceFormulaChildrenCode] varchar(50) NOT NULL,
    CONSTRAINT [PK_rxqPriceFormulaClass] PRIMARY KEY ([PriceFormulaPrimaryCode], [PriceFormulaChildrenCode])
);
