-- dsmMessage   (0 rows, 15 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[dsmMessage] (
    [MessageId] int IDENTITY NOT NULL,
    [UpDoxMessageId] bigint NULL,
    [UserId] varchar(200) NULL,
    [MsgDate] datetime NULL,
    [MsgBody] varchar(max) NULL,
    [From] varchar(200) NULL,
    [Subject] varchar(200) NULL,
    [HasAttachment] bit NULL,
    [IsReply] bit NULL,
    [Isread] bit NULL,
    [Isdeleted] bit NULL,
    [Priority] int NULL,
    [MsgMailType] int NULL,
    [MsgMailFolder] int NULL,
    [MsgUpDoxStatus] int NULL,
    CONSTRAINT [PK_dsmMessage] PRIMARY KEY ([MessageId])
);
