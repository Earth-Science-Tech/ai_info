-- sync_ScopeConfig   (2 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[sync_ScopeConfig] (
    [ScopeId] int NOT NULL,
    [ScopeName] varchar(200) NULL,
    [ScopeRunTime] int NULL,
    [LastSyncTime] datetime NULL,
    CONSTRAINT [PK_sync_ScopeConfig] PRIMARY KEY ([ScopeId])
);
