-- rxqShipment   (190,121 rows, 16 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
-- NOTE: mirrored into liberty_link_stage by the eMed ETL.
CREATE TABLE [dbo].[rxqShipment] (
    [id] int IDENTITY NOT NULL,
    [ShipmentMethod] nvarchar(50) NULL,
    [ShipmentType] nvarchar(50) NULL,
    [Reference] nvarchar(50) NULL,
    [ShipmentCost] float NULL,
    [ShipDate] datetime NULL,
    [ShippedAddress] nvarchar(50) NULL,
    [ShippedCity] nvarchar(50) NULL,
    [ShippedState] nvarchar(2) NULL,
    [ShippedZip] varchar(12) NULL,
    [ShippedName] nvarchar(50) NULL,
    [ShippedPhone] nvarchar(50) NULL,
    [PackageCount] int NULL,
    [TrackingNumber] nvarchar(50) NULL,
    [UserCreatingShipment] varchar(50) NULL,
    [StoreNumber] varchar(50) NULL,
    CONSTRAINT [PK_rxqShipment] PRIMARY KEY ([id])
);

-- Indexes
CREATE INDEX [IX_cDateTimeDESC] ON [dbo].[rxqShipment] ([ShipDate]);
CREATE INDEX [IX_Shipment_ID_DateTypeTacking] ON [dbo].[rxqShipment] ([id]) INCLUDE ([ShipDate], [ShipmentType], [TrackingNumber]);
CREATE INDEX [IX_Shipment_Reference] ON [dbo].[rxqShipment] ([Reference]);
