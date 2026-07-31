-- rxqWorkflowOptions   (19 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqWorkflowOptions] (
    [cWorkflowOptionsId] int IDENTITY NOT NULL,
    [WorkflowStage] int NULL,
    [SortOrder] int NULL,
    [ShowQueue] bit NULL,
    [StoreNumber] varchar(50) NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqWorkflowOptions] PRIMARY KEY ([cWorkflowOptionsId])
);
