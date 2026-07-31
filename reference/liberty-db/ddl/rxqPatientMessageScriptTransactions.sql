-- rxqPatientMessageScriptTransactions   (62,421 rows, 3 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPatientMessageScriptTransactions] (
    [PatientMessageId] varchar(50) NOT NULL,
    [ScriptNumber] int NOT NULL,
    [RefillNumber] int NOT NULL,
    CONSTRAINT [PK_rxqPatientMessageScriptTransactions] PRIMARY KEY ([PatientMessageId], [ScriptNumber], [RefillNumber])
);
