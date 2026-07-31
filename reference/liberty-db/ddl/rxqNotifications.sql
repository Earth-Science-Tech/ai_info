-- rxqNotifications   (0 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqNotifications] (
    [cNotificationId] int IDENTITY NOT NULL,
    [Title] nvarchar(1024) NOT NULL,
    [NotificationContent] nvarchar(1024) NOT NULL,
    [Priority] nvarchar(50) NOT NULL,
    [CreatedDate] datetime NOT NULL,
    [ExpirationDate] datetime NOT NULL,
    [CreatedBy] varchar(50) NULL,
    [IsGrpReadAck] varchar(50) NOT NULL,
    CONSTRAINT [PK_rxqNotifications] PRIMARY KEY ([cNotificationId])
);
