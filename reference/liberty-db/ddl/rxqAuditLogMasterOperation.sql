-- rxqAuditLogMasterOperation   (6 rows, 2 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAuditLogMasterOperation] (
    [id] int NOT NULL,
    [operation] varchar(20) NOT NULL,
    CONSTRAINT [PK_rxqAuditLogMasterOperation] PRIMARY KEY ([id], [operation])
);
