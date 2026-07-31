-- rxqRX365TransferInItems   (0 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqRX365TransferInItems] (
    [cRX365TransferInItemsId] int IDENTITY NOT NULL,
    [TransferInItemsId] int NULL,
    [ScriptOrDrug] varchar(500) NULL,
    [TransferInId] int NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqRX365TransferInItems] PRIMARY KEY ([cRX365TransferInItemsId])
);
