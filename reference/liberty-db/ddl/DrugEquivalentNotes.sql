-- DrugEquivalentNotes   (0 rows, 2 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[DrugEquivalentNotes] (
    [NoteID] int NOT NULL,
    [DrugGPI] varchar(255) NULL,
    CONSTRAINT [PK_DrugEquivalentNotes] PRIMARY KEY ([NoteID])
);
