-- rxqSigsCodes   (1,454 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqSigsCodes] (
    [SigCode] varchar(50) NOT NULL,
    [SigText] nvarchar(max) NULL,
    [SigLanguage] varchar(50) NOT NULL,
    [DaySupplyMultiplier] decimal(20,8) NULL,
    [PRN] bit NULL,
    [LastModified] datetime NULL,
    [cUnitDoseTemplateId] int NULL,
    [SupportedLanguageCode] varchar(3) NULL,
    CONSTRAINT [PK_rxqSigsCodes] PRIMARY KEY ([SigCode], [SigLanguage])
);
