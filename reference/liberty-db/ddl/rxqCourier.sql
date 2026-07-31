-- rxqCourier   (0 rows, 12 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqCourier] (
    [Id] int IDENTITY NOT NULL,
    [Enabled] bit NOT NULL,
    [SoftwareType] int NOT NULL,
    [StoreNumber] varchar(2) NOT NULL,
    [Name] varchar(50) NOT NULL,
    [CourierCode] varchar(50) NULL,
    [ApiKey] varchar(50) NULL,
    [Username] varchar(50) NULL,
    [Password] varchar(50) NULL,
    [CustomerCode] varchar(50) NULL,
    [PriceSets] varchar(max) NULL,
    [LastModified] datetime NOT NULL,
    CONSTRAINT [PK_rxqCourier] PRIMARY KEY ([Id])
);
