-- rxqWorkFlowFaxHistory   (0 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqWorkFlowFaxHistory] (
    [cWorkFlowFaxHistoryId] int IDENTITY NOT NULL,
    [TaskCode] varchar(50) NULL,
    [StatusCode] varchar(50) NULL,
    [ScriptNumber] int NULL,
    [RefillNumber] int NULL,
    [EntryDate] datetime NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqWorkFlowFaxHistory] PRIMARY KEY ([cWorkFlowFaxHistoryId])
);
