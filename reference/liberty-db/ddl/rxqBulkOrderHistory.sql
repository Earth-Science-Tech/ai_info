-- rxqBulkOrderHistory   (0 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqBulkOrderHistory] (
    [cBulkOrderHistoryId] int IDENTITY NOT NULL,
    [StoreNumber] varchar(2) NULL,
    [DateSubmitted] datetime NULL,
    [ImageKey] varchar(200) NULL,
    [SubmitType] int NULL,
    [LastModified] datetime NULL,
    [ReportSent] bit NULL,
    CONSTRAINT [PK_rxqBulkOrderHistory] PRIMARY KEY ([cBulkOrderHistoryId])
);
