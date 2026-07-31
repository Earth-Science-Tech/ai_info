-- dsmFax   (0 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[dsmFax] (
    [FaxId] int IDENTITY NOT NULL,
    [StoreNumber] varchar(255) NULL,
    [UpDoxAccountId] varchar(255) NULL,
    [FaxNumber] decimal(12,0) NULL,
    [FaxNumberStatus] int NULL,
    CONSTRAINT [PK_dsmFax] PRIMARY KEY ([FaxId])
);
