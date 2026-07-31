-- EPCISPackage   (0 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[EPCISPackage] (
    [Id] int IDENTITY NOT NULL,
    [EPCISDataId] uniqueidentifier NOT NULL,
    [NDC] varchar(50) NOT NULL,
    [SerialNumber] varchar(50) NOT NULL,
    [LotNumber] varchar(50) NULL,
    [ExpirationDate] datetime NULL,
    [DateParsed] datetime NULL,
    [OrderLineId] int NULL,
    CONSTRAINT [PK_EPCISPackage] PRIMARY KEY ([Id])
);
