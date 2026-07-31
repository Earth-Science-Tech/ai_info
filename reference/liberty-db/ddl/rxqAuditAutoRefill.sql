-- rxqAuditAutoRefill   (1,959 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAuditAutoRefill] (
    [cAuditAutoRefillId] int IDENTITY NOT NULL,
    [Action] int NOT NULL,
    [ActionDate] datetime NOT NULL,
    [ScriptNumber] int NOT NULL,
    [RefillNumber] int NOT NULL,
    [WFIDate] datetime NULL,
    [LoggedUser] varchar(20) NOT NULL,
    CONSTRAINT [PK_rxqAuditAutoRefill] PRIMARY KEY ([cAuditAutoRefillId])
);
