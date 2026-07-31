-- rxqWorkflowNDCScanHistory   (0 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqWorkflowNDCScanHistory] (
    [cWorkflowNDCScanHistoryId] int IDENTITY NOT NULL,
    [ScriptNumber] int NULL,
    [RefillNumber] int NULL,
    [PartialNumber] int NULL,
    [ScanDate] datetime NULL,
    [ExpectedPackages] int NULL,
    [ActualPackages] int NULL,
    [LoggedInUser] varchar(50) NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqWorkflowNDCScanHistory] PRIMARY KEY ([cWorkflowNDCScanHistoryId])
);
