-- rxqPrintingTemplate   (82 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPrintingTemplate] (
    [TemplateKey] varchar(50) NOT NULL,
    [TemplatePath] varchar(256) NULL,
    [SecondPagePrinter] int NULL,
    [StoreNumber] varchar(50) NOT NULL,
    CONSTRAINT [PK_rxqPrintingTemplate] PRIMARY KEY ([TemplateKey], [StoreNumber])
);
