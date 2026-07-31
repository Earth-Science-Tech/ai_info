-- rxqPrintableAttachment   (0 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPrintableAttachment] (
    [cPrintableAttachmentId] int IDENTITY NOT NULL,
    [PrintType] int NULL,
    [LookupId] varchar(50) NULL,
    [AttachmentDescription] varchar(200) NULL,
    [cImageControlId] varchar(200) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    [DocumentType] int NULL,
    CONSTRAINT [PK_rxqPrintableAttachment] PRIMARY KEY ([cPrintableAttachmentId])
);
