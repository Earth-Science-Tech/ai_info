-- PatientConsultationNotes   (0 rows, 2 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[PatientConsultationNotes] (
    [NoteID] int NOT NULL,
    [PatientID] varchar(255) NULL,
    CONSTRAINT [PK_PatientConsultationNotes] PRIMARY KEY ([NoteID])
);
