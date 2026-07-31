-- PatientConsultationDefaultNotes   (0 rows, 2 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[PatientConsultationDefaultNotes] (
    [NoteID] int NOT NULL,
    [Field] varchar(255) NULL,
    CONSTRAINT [PK_PatientConsultationDefaultNotes] PRIMARY KEY ([NoteID])
);
