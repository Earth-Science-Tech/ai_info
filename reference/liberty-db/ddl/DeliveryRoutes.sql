-- DeliveryRoutes   (0 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[DeliveryRoutes] (
    [ID] int IDENTITY NOT NULL,
    [Name] varchar(50) NOT NULL,
    [Color] varchar(12) NULL,
    [StoreNumber] varchar(50) NOT NULL,
    CONSTRAINT [PK_DeliveryRoutes] PRIMARY KEY ([ID])
);
