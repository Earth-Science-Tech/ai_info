-- rxqScriptTransactionAudit   (2,182,822 rows, 14 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqScriptTransactionAudit] (
    [cTranAuditId] numeric(18,0) IDENTITY NOT NULL,
    [cScriptTransactionId] numeric(18,0) NOT NULL,
    [ScriptNumber] int NOT NULL,
    [RefillNumber] int NOT NULL,
    [StatusChange] bit NULL,
    [NewWorkFlowStatus] varchar(50) NULL,
    [OldWorkFlowStatus] varchar(50) NULL,
    [LocationChange] bit NULL,
    [NewWorkFlowLocation] int NULL,
    [OldWorkFlowLocation] int NULL,
    [ModifiedBy] varchar(50) NOT NULL,
    [ModifiedDate] datetime NOT NULL,
    [Transition] int NULL,
    [PartialFill] int NULL,
    CONSTRAINT [PK_rxqScriptTransactionAudit] PRIMARY KEY ([cTranAuditId])
);

-- Indexes
CREATE INDEX [IX_ScriptTransactionAudit_ScriptNmRefillNm] ON [dbo].[rxqScriptTransactionAudit] ([ScriptNumber], [RefillNumber]);
