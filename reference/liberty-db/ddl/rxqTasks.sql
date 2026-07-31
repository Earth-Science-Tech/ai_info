-- rxqTasks   (1,353 rows, 16 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqTasks] (
    [cTaskId] int IDENTITY NOT NULL,
    [TaskName] varchar(50) NULL,
    [DueDate] datetime NULL,
    [Assigned] varchar(50) NULL,
    [CategoryId] int NULL,
    [Completed] bit NULL,
    [Notes] varchar(500) NULL,
    [CreatedBy] varchar(50) NULL,
    [CreatedDateTime] datetime NULL,
    [CompletedBy] varchar(50) NULL,
    [CompletedDateTime] datetime NULL,
    [LinkedScript] int NULL,
    [PatientId] varchar(50) NULL,
    [IsRecurrence] bit NOT NULL,
    [IsAcknowledge] varchar(256) NOT NULL,
    [StoreNumber] varchar(3) NULL,
    CONSTRAINT [PK_rxqTasks] PRIMARY KEY ([cTaskId])
);

-- Indexes
CREATE INDEX [IX_Tasks_Completed_Assigned] ON [dbo].[rxqTasks] ([Completed], [Assigned]);
CREATE INDEX [IX_Tasks_LinkedScript] ON [dbo].[rxqTasks] ([LinkedScript]);
