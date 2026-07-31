-- Rx365PushNotification   (0 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[Rx365PushNotification] (
    [Id] int IDENTITY NOT NULL,
    [StoreId] varchar(50) NULL,
    [UserId] varchar(50) NULL,
    [DateSent] datetime NULL,
    [Header] varchar(max) NULL,
    [Message] varchar(max) NULL,
    CONSTRAINT [PK_Rx365PushNotification] PRIMARY KEY ([Id])
);
