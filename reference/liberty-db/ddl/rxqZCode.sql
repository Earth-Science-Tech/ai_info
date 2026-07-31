-- rxqZCode   (42,069 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqZCode] (
    [cZCodeId] int IDENTITY NOT NULL,
    [ZipCode] char(5) NOT NULL,
    [CityName] varchar(64) NULL,
    [StateAbbr] char(2) NULL,
    [AreaCode] char(3) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    CONSTRAINT [PK_rxqZCode] PRIMARY KEY ([ZipCode])
);
