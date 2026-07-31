-- rxqAutoRunItem   (7 rows, 10 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAutoRunItem] (
    [cAutoRunItemId] int IDENTITY NOT NULL,
    [StoreNumber] varchar(50) NULL,
    [Type] int NULL,
    [Frequency] int NULL,
    [Day] int NULL,
    [EntryTime] time(7) NULL,
    [Options] varchar(150) NULL,
    [LastDateRun] datetime NULL,
    [Status] int NULL,
    [Notes] varchar(50) NULL,
    CONSTRAINT [PK_rxqAutoRunItem] PRIMARY KEY ([cAutoRunItemId])
);
