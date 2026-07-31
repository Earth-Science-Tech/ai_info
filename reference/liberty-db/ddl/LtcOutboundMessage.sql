-- LtcOutboundMessage   (0 rows, 12 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[LtcOutboundMessage] (
    [Id] int IDENTITY NOT NULL,
    [LtcVendor] int NULL,
    [ScriptNumber] int NULL,
    [RefillNumber] int NULL,
    [MessageId] varchar(50) NULL,
    [XmlData] varchar(max) NULL,
    [StoreNumber] varchar(10) NULL,
    [DateSent] datetime NULL,
    [LastModified] datetime NULL,
    [MessageType] int NULL,
    [ResponseReceivedType] int NULL,
    [ErrorResponseCode] varchar(10) NULL,
    CONSTRAINT [PK_LtcOutboundMessage] PRIMARY KEY ([Id])
);
