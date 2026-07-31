-- sync_ScopeTables   (349 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[sync_ScopeTables] (
    [ScopeId] int NOT NULL,
    [TableName] varchar(200) NOT NULL,
    [SyncValid] int NOT NULL,
    [BatchSize] int NULL,
    [BatchSizeInitial] int NULL,
    CONSTRAINT [PK_sync_ScopeTables] PRIMARY KEY ([ScopeId], [TableName])
);
