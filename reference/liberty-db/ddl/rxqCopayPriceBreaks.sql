-- rxqCopayPriceBreaks   (0 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqCopayPriceBreaks] (
    [StoreNumber] varchar(50) NOT NULL,
    [PriceFormulaCode] varchar(50) NOT NULL,
    [CopayType] char(1) NOT NULL,
    [PriceBreak] decimal(12,2) NOT NULL,
    [CopayAmount] decimal(12,2) NOT NULL,
    [LastModified] datetime NOT NULL,
    [IsValid] bit NOT NULL,
    CONSTRAINT [PK_rxqCopayPriceBreaks] PRIMARY KEY ([StoreNumber], [PriceFormulaCode], [CopayType], [PriceBreak])
);
