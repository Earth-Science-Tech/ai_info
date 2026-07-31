-- rxqAuditMedSync   (5,675 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAuditMedSync] (
    [cAuditMedSyncId] int IDENTITY NOT NULL,
    [Action] int NULL,
    [ActionDate] datetime NULL,
    [ScriptNumber] int NULL,
    [RefillNumber] int NULL,
    [WFIDate] datetime NULL,
    [LoggedUser] varchar(max) NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqAuditMedSync] PRIMARY KEY ([cAuditMedSyncId])
);
