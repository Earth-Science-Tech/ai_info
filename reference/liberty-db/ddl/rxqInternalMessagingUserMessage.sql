-- rxqInternalMessagingUserMessage   (5 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqInternalMessagingUserMessage] (
    [cInternalMessagingUserMessageId] int IDENTITY NOT NULL,
    [InternalMessagingId] int NULL,
    [MessageUser] varchar(400) NULL,
    [MessageRead] bit NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqInternalMessagingUserMessage] PRIMARY KEY ([cInternalMessagingUserMessageId])
);
