-- rxqMessages   (1 rows, 12 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqMessages] (
    [cMessageId] int IDENTITY NOT NULL,
    [Subject] nvarchar(1024) NOT NULL,
    [MessageBody] nvarchar(1024) NOT NULL,
    [Priority] nvarchar(50) NOT NULL,
    [AddressedFrom] varchar(50) NULL,
    [IsGrpMsg] bit NOT NULL,
    [AddressedToGrp] int NULL,
    [AddressedToInd] varchar(50) NULL,
    [CreatedDateYYYYMMHH] datetime NOT NULL,
    [CreatedBy] varchar(50) NULL,
    [IsRead] bit NOT NULL,
    [IsGrpReadAck] varchar(50) NOT NULL,
    CONSTRAINT [PK_rxqMessages] PRIMARY KEY ([cMessageId])
);
