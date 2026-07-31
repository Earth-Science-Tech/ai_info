-- CentralFillCompletedOrders   (0 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[CentralFillCompletedOrders] (
    [ID] uniqueidentifier NOT NULL,
    [CfServiceId] int NOT NULL,
    [OrderId] nvarchar(50) NULL,
    [PrescriptionCount] int NULL,
    [ShippedDate] datetime NULL,
    [CheckedInDate] datetime NULL,
    [CheckedInBy] varchar(50) NULL,
    [StoreNumber] varchar(50) NULL,
    CONSTRAINT [PK_CentralFillCompletedOrders] PRIMARY KEY ([ID])
);
