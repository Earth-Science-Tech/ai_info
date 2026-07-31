-- DrugNotes   (0 rows, 2 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[DrugNotes] (
    [NoteID] int NOT NULL,
    [DrugID] varchar(255) NULL,
    CONSTRAINT [PK_DrugNotes] PRIMARY KEY ([NoteID])
);
