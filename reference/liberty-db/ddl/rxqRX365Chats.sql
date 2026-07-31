-- rxqRX365Chats   (0 rows, 12 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqRX365Chats] (
    [cRX365ChatsId] int IDENTITY NOT NULL,
    [Id] int NULL,
    [Sender] int NULL,
    [SendTime] datetime2(7) NULL,
    [Text] nvarchar(max) NULL,
    [UserId] int NULL,
    [Read] bit NULL,
    [PharmacyId] int NULL,
    [RXQPatientId] varchar(50) NULL,
    [StoreNumber] varchar(50) NULL,
    [LastModified] datetime NULL,
    [Attachment] nvarchar(max) NULL,
    CONSTRAINT [PK_rxqRX365Chats] PRIMARY KEY ([cRX365ChatsId])
);
