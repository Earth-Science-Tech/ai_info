-- rxqInterfaceOptions   (0 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqInterfaceOptions] (
    [cInterfaceOptionsId] int IDENTITY NOT NULL,
    [InterfaceName] int NULL,
    [SortOrder] int NULL,
    [ShowInterface] bit NULL,
    [StoreNumber] varchar(50) NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqInterfaceOptions] PRIMARY KEY ([cInterfaceOptionsId])
);
