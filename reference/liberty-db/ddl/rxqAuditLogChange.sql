-- rxqAuditLogChange   (18,125,646 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAuditLogChange] (
    [Id] int IDENTITY NOT NULL,
    [master_id] int NOT NULL,
    [property] varchar(256) NULL,
    [specific_operation] int NOT NULL,
    [old_value] varchar(256) NULL,
    [new_value] varchar(256) NULL,
    [parent_id] int NULL,
    [summary] varchar(256) NULL,
    CONSTRAINT [PK_rxqAuditLogChange] PRIMARY KEY ([Id])
);

-- Indexes
CREATE INDEX [auditchangeparent] ON [dbo].[rxqAuditLogChange] ([parent_id]);
CREATE INDEX [auditchangesmaster] ON [dbo].[rxqAuditLogChange] ([master_id]);
CREATE INDEX [IDX_AuditLogChange_SpecificOperationParentId_IdValues] ON [dbo].[rxqAuditLogChange] ([specific_operation], [parent_id]) INCLUDE ([Id], [property], [old_value], [new_value]);
