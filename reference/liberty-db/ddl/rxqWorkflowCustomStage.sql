-- rxqWorkflowCustomStage   (0 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqWorkflowCustomStage] (
    [WorkflowCustomStageId] int IDENTITY NOT NULL,
    [Index] int NULL,
    [cWorkflowStageId] int NULL,
    [cSecurityGroupId] int NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqWorkflowCustomStage] PRIMARY KEY ([WorkflowCustomStageId])
);
