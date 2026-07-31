-- rxqPriceUpdateHistory   (1,742 rows, 13 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPriceUpdateHistory] (
    [id] int IDENTITY NOT NULL,
    [priceUpdateSettingsId] int NULL,
    [dateStarted] datetime NULL,
    [dateFinished] datetime NULL,
    [numberOfRecordsInFile] int NULL,
    [numberOfBzqMatchesFound] int NULL,
    [numberOfRxqMatchesFound] int NULL,
    [numberOfRxqPricesChanged] int NULL,
    [numberOfBzqPricesChanged] int NULL,
    [numberOfItemsAddedToRxqDatabase] int NULL,
    [numberOfItemsAddedToBzqDatabase] int NULL,
    [startOrigin] nvarchar(50) NULL,
    [filePath] nvarchar(max) NULL,
    CONSTRAINT [PK_rxqPriceUpdateHistory] PRIMARY KEY ([id])
);

-- Indexes
CREATE INDEX [settings id and date] ON [dbo].[rxqPriceUpdateHistory] ([priceUpdateSettingsId], [dateStarted]);
