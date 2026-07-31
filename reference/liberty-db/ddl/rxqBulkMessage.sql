-- rxqBulkMessage   (0 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqBulkMessage] (
    [BulkMessageId] int IDENTITY NOT NULL,
    [Text] varchar(max) NULL,
    [SentDate] datetime NULL,
    [SentBy] nvarchar(50) NULL,
    [Name] varchar(256) NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqBulkMessage] PRIMARY KEY ([BulkMessageId])
);
