-- dsmAttachment   (0 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[dsmAttachment] (
    [AttachmentId] int IDENTITY NOT NULL,
    [UpDoxMessageId] bigint NULL,
    [Description] varchar(200) NULL,
    [FileName] varchar(50) NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_dsmAttachment] PRIMARY KEY ([AttachmentId])
);
