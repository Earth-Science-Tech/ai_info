-- InsuranceNotes   (0 rows, 2 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[InsuranceNotes] (
    [NoteID] int NOT NULL,
    [AgencyID] varchar(255) NULL,
    CONSTRAINT [PK_InsuranceNotes] PRIMARY KEY ([NoteID])
);
