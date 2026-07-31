-- rxqOrderConfirmation   (0 rows, 10 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqOrderConfirmation] (
    [cOrderConfirmationId] int IDENTITY NOT NULL,
    [cOrderId] int NULL,
    [ConfirmationFile] nvarchar(max) NULL,
    [ConfirmationFileType] int NULL,
    [ConfirmationFileName] nvarchar(max) NULL,
    [DateReceived] datetime NULL,
    [LastModified] datetime NULL,
    [cOrderVendorSettingsId] int NULL,
    [POStatus] varchar(max) NULL,
    [CheckSum] varchar(50) NULL,
    CONSTRAINT [PK_rxqOrderConfirmation] PRIMARY KEY ([cOrderConfirmationId])
);
