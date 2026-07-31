-- rxqClinicalInteractionsAndAlertsNotes   (34,626 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqClinicalInteractionsAndAlertsNotes] (
    [cClinicalInteractionsAndAlertsNoteId] int IDENTITY NOT NULL,
    [ScriptNumber] int NULL,
    [RefillNumber] int NULL,
    [ClinicalNoteId] varchar(200) NULL,
    [NotesDate] datetime NULL,
    [ClinicalNote] varchar(max) NULL,
    [LastModified] datetime NULL,
    [RPhInitials] varchar(50) NULL,
    [LoggedInUser] varchar(50) NULL,
    CONSTRAINT [PK_rxqClinicalInteractionsAndAlertsNotes] PRIMARY KEY ([cClinicalInteractionsAndAlertsNoteId])
);
