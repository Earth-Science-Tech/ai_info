-- rxqOrderDiscrepancy   (0 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqOrderDiscrepancy] (
    [Id] int IDENTITY NOT NULL,
    [cOrderId] int NOT NULL,
    [Status] int NOT NULL,
    [Note] nvarchar(max) NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [CreatedAt] datetime NOT NULL,
    CONSTRAINT [PK_rxqOrderDiscrepancy] PRIMARY KEY ([Id])
);
