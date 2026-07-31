-- rxqAgencyStore   (5 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAgencyStore] (
    [StoreNumber] varchar(50) NOT NULL,
    [AgencyCode] varchar(50) NOT NULL,
    [StoreProviderId] varchar(50) NOT NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    CONSTRAINT [PK_rxqAgencyStore] PRIMARY KEY ([StoreNumber], [AgencyCode])
);
