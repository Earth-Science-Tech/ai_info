-- rxqOrderDiscrepancyItem   (0 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqOrderDiscrepancyItem] (
    [Id] int IDENTITY NOT NULL,
    [OrderDiscrepancyId] int NOT NULL,
    [cOrderLineId] int NOT NULL,
    [ScannedCount] int NOT NULL,
    [Resolution] int NULL,
    CONSTRAINT [PK_rxqOrderDiscrepancyItem] PRIMARY KEY ([Id])
);
