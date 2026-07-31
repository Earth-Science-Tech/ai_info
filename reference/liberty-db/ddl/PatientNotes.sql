-- PatientNotes   (0 rows, 2 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[PatientNotes] (
    [NoteID] int NOT NULL,
    [PatientID] varchar(255) NULL,
    CONSTRAINT [PK_PatientNotes] PRIMARY KEY ([NoteID])
);
