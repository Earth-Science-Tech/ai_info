-- InventoryEventLog   (0 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[InventoryEventLog] (
    [Id] int IDENTITY NOT NULL,
    [InventoryOperationsId] int NULL,
    [Event] int NULL,
    [Message] varchar(max) NULL,
    [CreatedOn] datetime NULL,
    [User] varchar(50) NULL,
    [SubType] int NULL,
    [Reason] varchar(50) NULL,
    [BulkId] int NULL,
    CONSTRAINT [PK_InventoryEventLog] PRIMARY KEY ([Id])
);
