-- PrescriberNotes   (0 rows, 2 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[PrescriberNotes] (
    [NoteID] int NOT NULL,
    [PrescriberID] varchar(255) NULL,
    CONSTRAINT [PK_PrescriberNotes] PRIMARY KEY ([NoteID])
);
