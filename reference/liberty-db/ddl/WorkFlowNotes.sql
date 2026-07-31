-- WorkFlowNotes   (0 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[WorkFlowNotes] (
    [NoteID] int NOT NULL,
    [SubType] varchar(255) NULL,
    [ScriptNumber] varchar(255) NULL,
    [RefillNumber] varchar(255) NULL,
    [PendingID] varchar(255) NULL,
    CONSTRAINT [PK_WorkFlowNotes] PRIMARY KEY ([NoteID])
);
