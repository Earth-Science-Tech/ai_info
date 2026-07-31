-- rxqProLicense   (24 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqProLicense] (
    [MacAddress] varchar(50) NOT NULL,
    [ComputerName] varchar(50) NOT NULL,
    [LastAccessDate] date NOT NULL,
    [ActiveFlag] bit NOT NULL,
    CONSTRAINT [PK_rxqProLicense] PRIMARY KEY ([MacAddress])
);
