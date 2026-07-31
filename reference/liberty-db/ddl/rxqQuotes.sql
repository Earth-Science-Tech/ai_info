-- rxqQuotes   (0 rows, 17 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqQuotes] (
    [QuoteNumber] int IDENTITY NOT NULL,
    [PatientId] varchar(50) NOT NULL,
    [PrescribedDrugId] varchar(50) NOT NULL,
    [DispenseDrugId] varchar(50) NOT NULL,
    [DispenseQuantity] decimal(9,3) NOT NULL,
    [PriceFormula] varchar(50) NOT NULL,
    [ACQ] decimal(9,2) NOT NULL,
    [Cost] decimal(9,2) NOT NULL,
    [Fee] decimal(9,2) NOT NULL,
    [Discount] decimal(9,2) NOT NULL,
    [Tax] decimal(9,2) NOT NULL,
    [Total] decimal(9,2) NOT NULL,
    [Copay] decimal(9,2) NOT NULL,
    [UsualAndCustomary] decimal(9,2) NOT NULL,
    [Created] datetime NOT NULL,
    [LastModified] datetime NOT NULL,
    [DaysSupply] int NULL,
    CONSTRAINT [PK_rxqQuotes] PRIMARY KEY ([QuoteNumber])
);

-- Indexes
CREATE INDEX [IX_rxqQuotes_Created] ON [dbo].[rxqQuotes] ([Created]);
CREATE INDEX [IX_rxqQuotes_Patient] ON [dbo].[rxqQuotes] ([PatientId]);
