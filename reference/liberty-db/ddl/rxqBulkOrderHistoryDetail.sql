-- rxqBulkOrderHistoryDetail   (0 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqBulkOrderHistoryDetail] (
    [cBulkOrderHistoryDetailId] int IDENTITY NOT NULL,
    [cBulkOrderHistoryId] int NOT NULL,
    [BulkOrderHistoryType] int NULL,
    [BulkOrderHistoryLookId] int NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqBulkOrderHistoryDetail] PRIMARY KEY ([cBulkOrderHistoryDetailId])
);
