-- rxqAddress   (341,175 rows, 12 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAddress] (
    [cAddressId] int IDENTITY NOT NULL,
    [LookUpId] varchar(200) NULL,
    [AddressType] int NULL,
    [Street] varchar(200) NULL,
    [City] varchar(200) NULL,
    [State] varchar(200) NULL,
    [Zip] varchar(200) NULL,
    [ZipPlus] varchar(200) NULL,
    [Suite] varchar(200) NULL,
    [CountryCode] varchar(200) NULL,
    [Notes] varchar(200) NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqAddress] PRIMARY KEY ([cAddressId])
);

-- Indexes
CREATE INDEX [rxqAddress_LookUpId] ON [dbo].[rxqAddress] ([LookUpId]);
