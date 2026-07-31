-- sync_ColumnUpdates   (1 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[sync_ColumnUpdates] (
    [updateId] int NOT NULL,
    [tableName] varchar(100) NOT NULL,
    [RowPrimaryKey] varchar(700) NOT NULL,
    [columnName] varchar(100) NOT NULL,
    [columnValue] varchar(700) NOT NULL,
    CONSTRAINT [PK_sync_ColumnUpdates] PRIMARY KEY ([updateId])
);
