-- rxqWorkflowStages   (35 rows, 16 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqWorkflowStages] (
    [cWorkflowStageId] int IDENTITY NOT NULL,
    [Name] varchar(50) NULL,
    [WorkflowStage] varchar(50) NULL,
    [Description] varchar(250) NULL,
    [LastUpdatedText] varchar(50) NULL,
    [FilterString] varchar(max) NULL,
    [LocationChange] bit NULL,
    [InActive] bit NULL,
    [IncludeOnHoldScripts] bit NULL,
    [StoreNumber] varchar(50) NULL,
    [ImageId] int NULL,
    [StageType] int NULL,
    [IncludeTransmitLater] bit NULL,
    [FilterDate] varchar(2000) NULL,
    [LastModified] date NULL,
    [UnitDoseExport] int NULL,
    CONSTRAINT [PK_rxqWorkflowStages] PRIMARY KEY ([cWorkflowStageId])
);
