-- rxqMultipleStatesLicense   (1 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqMultipleStatesLicense] (
    [cMultipleStatesLicenseId] int IDENTITY NOT NULL,
    [StoreNumber] varchar(50) NULL,
    [LicenseType] int NULL,
    [LicenseNumber] varchar(max) NULL,
    [State] varchar(50) NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqMultipleStatesLicense] PRIMARY KEY ([cMultipleStatesLicenseId])
);
