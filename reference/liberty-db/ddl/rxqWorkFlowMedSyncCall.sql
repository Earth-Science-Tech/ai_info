-- rxqWorkFlowMedSyncCall   (0 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqWorkFlowMedSyncCall] (
    [cWorkFlowMedSyncCallId] int IDENTITY NOT NULL,
    [PatientId] varchar(20) NULL,
    [CallStatus] int NULL,
    [NextSync] datetime NULL,
    [LastModified] datetime NULL,
    [Attempts] int NULL,
    [Log] varchar(max) NULL,
    [ScriptNumber] int NULL,
    CONSTRAINT [PK_rxqWorkFlowMedSyncCall] PRIMARY KEY ([cWorkFlowMedSyncCallId])
);
