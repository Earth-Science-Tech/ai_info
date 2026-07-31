-- rxqFaxCenter   (1 rows, 13 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqFaxCenter] (
    [cFaxCenterId] int IDENTITY NOT NULL,
    [FaxType] int NULL,
    [FaxNumber] varchar(max) NULL,
    [FaxRecipient] varchar(max) NULL,
    [FaxSent] datetime NULL,
    [WFISequenceNumber] int NULL,
    [ImageKeyType] varchar(1) NULL,
    [ImageKey] varchar(200) NULL,
    [FaxCreated] datetime NULL,
    [Trash] bit NULL,
    [LastModified] datetime NULL,
    [FaxRead] bit NULL,
    [StoreNumber] varchar(50) NOT NULL,
    CONSTRAINT [PK_rxqFaxCenter] PRIMARY KEY ([cFaxCenterId])
);

-- Indexes
CREATE INDEX [IDX_rxqFaxCenter_faxType_FaxRead] ON [dbo].[rxqFaxCenter] ([FaxType], [FaxRead]) INCLUDE ([Trash]);
