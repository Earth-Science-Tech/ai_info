-- PickUpNotes   (0 rows, 3 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[PickUpNotes] (
    [NoteID] int NOT NULL,
    [ScriptNumber] varchar(255) NULL,
    [RefillNumber] varchar(255) NULL,
    CONSTRAINT [PK_PickUpNotes] PRIMARY KEY ([NoteID])
);
