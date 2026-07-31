-- CustomViewsWaitingBin   (0 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[CustomViewsWaitingBin] (
    [ID] int IDENTITY NOT NULL,
    [Name] varchar(50) NOT NULL,
    [Source] int NOT NULL,
    [DxFilter] varchar(max) NULL,
    [Icon] int NOT NULL,
    [StoreNumber] varchar(50) NOT NULL,
    CONSTRAINT [PK_CustomViewsWaitingBin] PRIMARY KEY ([ID])
);
