-- EPCISData   (0 rows, 3 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[EPCISData] (
    [Id] uniqueidentifier NOT NULL,
    [XmlData] varchar(max) NOT NULL,
    [PurchaseOrderName] nvarchar(50) NULL,
    CONSTRAINT [PK_EPCISData] PRIMARY KEY ([Id])
);
