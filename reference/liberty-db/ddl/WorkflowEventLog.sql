-- WorkflowEventLog   (0 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[WorkflowEventLog] (
    [Id] int IDENTITY NOT NULL,
    [ScriptOperationsId] int NULL,
    [Event] int NULL,
    [Message] varchar(max) NULL,
    [CreatedOn] datetime NULL,
    [RphInitials] varchar(50) NULL,
    [UserInitials] varchar(50) NULL,
    [SubType] int NULL,
    [Reason] int NULL,
    CONSTRAINT [PK_WorkflowEventLog] PRIMARY KEY ([Id])
);
