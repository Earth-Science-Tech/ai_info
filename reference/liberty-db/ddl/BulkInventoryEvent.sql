-- BulkInventoryEvent   (0 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[BulkInventoryEvent] (
    [Id] int IDENTITY NOT NULL,
    [Reason] nvarchar(256) NOT NULL,
    [User] nvarchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [Undone] bit NOT NULL,
    CONSTRAINT [PK_BulkInventoryEvent] PRIMARY KEY ([Id])
);
