-- rxqInternalMessaging   (3 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqInternalMessaging] (
    [cInternalMessagingId] int IDENTITY NOT NULL,
    [Message] varchar(max) NULL,
    [FromUser] varchar(400) NULL,
    [AllUsers] varchar(max) NULL,
    [MessageDate] datetime NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqInternalMessaging] PRIMARY KEY ([cInternalMessagingId])
);
