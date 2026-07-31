-- ScriptNotes   (0 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[ScriptNotes] (
    [NoteID] int NOT NULL,
    [ScriptNumber] varchar(255) NULL,
    [RefillNumber] varchar(255) NULL,
    [PrintOnLabel] bit NULL,
    CONSTRAINT [PK_ScriptNotes] PRIMARY KEY ([NoteID])
);
