-- TransferNotes   (0 rows, 2 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[TransferNotes] (
    [NoteID] int NOT NULL,
    [PharmacyID] varchar(255) NULL,
    CONSTRAINT [PK_TransferNotes] PRIMARY KEY ([NoteID])
);
