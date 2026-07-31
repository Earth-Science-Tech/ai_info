-- RxqWorkflowDevice   (20 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[RxqWorkflowDevice] (
    [DeviceKey] int NOT NULL,
    [DeviceName] nvarchar(max) NULL,
    [LastLng] decimal(8,8) NULL,
    [LastLat] decimal(8,8) NULL,
    [LastConnected] datetime NULL,
    [DeviceType] int NULL,
    [StoreNumber] nvarchar(max) NULL,
    [LastIpAddressDate] datetime NULL,
    [LastIpAddress] nvarchar(50) NULL,
    CONSTRAINT [PK_RxqWorkflowDevice] PRIMARY KEY ([DeviceKey])
);
