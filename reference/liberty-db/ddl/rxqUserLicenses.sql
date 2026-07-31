-- rxqUserLicenses   (8 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqUserLicenses] (
    [cUserLicenseId] int IDENTITY NOT NULL,
    [RecordId] varchar(50) NOT NULL,
    [LicenseType] int NOT NULL,
    [LicenseNumber] varchar(200) NULL,
    [LicenseState] varchar(25) NOT NULL,
    [LicenseExpiration] date NULL,
    [LastModified] datetime NULL,
    [DateSnoozed] date NULL,
    CONSTRAINT [PK_rxqUserLicenses] PRIMARY KEY ([RecordId], [LicenseType], [LicenseState])
);
