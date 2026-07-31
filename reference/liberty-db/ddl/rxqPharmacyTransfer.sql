-- rxqPharmacyTransfer   (23 rows, 20 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPharmacyTransfer] (
    [Id] varchar(50) NOT NULL,
    [Name] varchar(50) NOT NULL,
    [Street] varchar(50) NULL,
    [Suite] varchar(50) NULL,
    [City] varchar(50) NULL,
    [State] varchar(50) NULL,
    [Zip] varchar(50) NULL,
    [ZipPlus] varchar(50) NULL,
    [Phone] varchar(50) NULL,
    [Fax] varchar(50) NULL,
    [Ncpdp] varchar(50) NULL,
    [FidNumber] varchar(50) NULL,
    [Contact] varchar(max) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    [Source] int NOT NULL,
    [NPI] nvarchar(50) NULL,
    [DPS] nvarchar(50) NULL,
    [LastCentralUpdate] datetime NULL,
    [Nickname] varchar(50) NULL,
    CONSTRAINT [PK_rxqPharmacyTransfer] PRIMARY KEY ([Id])
);
