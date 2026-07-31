-- rxqOnlineNotifications   (0 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqOnlineNotifications] (
    [NotificationsId] varchar(50) NOT NULL,
    [Subject] varchar(max) NULL,
    [Body] varchar(max) NULL,
    [URL] varchar(max) NULL,
    [LastUpdated] datetime NULL,
    [ZendeskId] varchar(50) NULL,
    [BodyHtml] varchar(max) NULL,
    CONSTRAINT [PK_rxqOnlineNotifications] PRIMARY KEY ([NotificationsId])
);
