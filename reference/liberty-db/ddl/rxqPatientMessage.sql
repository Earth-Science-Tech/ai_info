-- rxqPatientMessage   (68,412 rows, 21 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPatientMessage] (
    [id] varchar(50) NOT NULL,
    [MessageBody] nvarchar(max) NULL,
    [MessageSubject] varchar(255) NULL,
    [MessageCreatedOn] datetime NULL,
    [MessageSent] bit NULL,
    [MessageTo] varchar(max) NULL,
    [MessageSuccess] bit NULL,
    [MessageType] int NULL,
    [PatientId] varchar(50) NULL,
    [MessageResult] varchar(max) NULL,
    [MessageReferenceNumber] varchar(max) NULL,
    [SentBy] varchar(50) NULL,
    [MessageRetryCount] int NULL,
    [AlertType] int NULL,
    [StoreNumber] varchar(50) NULL,
    [MessageRead] bit NULL,
    [Outbound] bit NULL,
    [MessageFrom] varchar(max) NULL,
    [EncodedMessageBody] varchar(max) NULL,
    [HasAttachments] bit NULL,
    [LoggedInUser] varchar(200) NULL,
    CONSTRAINT [PK_rxqPatientMessage] PRIMARY KEY ([id])
);

-- Indexes
CREATE INDEX [IX_PatientMessage_StoreNumber, MessageRead, Outbound] ON [dbo].[rxqPatientMessage] ([StoreNumber], [MessageRead], [Outbound]);
CREATE INDEX [MessageCreateDateIndex] ON [dbo].[rxqPatientMessage] ([MessageCreatedOn]);
CREATE INDEX [PatientIdIndex] ON [dbo].[rxqPatientMessage] ([PatientId]);
