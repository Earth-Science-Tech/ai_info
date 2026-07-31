-- rxqClinicalInteractionsAndAlerts   (39,787 rows, 14 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqClinicalInteractionsAndAlerts] (
    [cClinicalInteractionsAndAlertsId] int IDENTITY NOT NULL,
    [ScriptNumber] int NULL,
    [RefillNumber] int NULL,
    [Type] int NULL,
    [Subject] varchar(400) NULL,
    [Description] varchar(max) NULL,
    [Significance] int NULL,
    [RPhInitials] varchar(50) NULL,
    [LoggedInUser] varchar(50) NULL,
    [AlertDate] datetime NULL,
    [LastModified] datetime NULL,
    [ClinicalNoteId] varchar(200) NULL,
    [PrescriptionProcessingMode] int NULL,
    [AlertLocation] int NULL,
    CONSTRAINT [PK_rxqClinicalInteractionsAndAlerts] PRIMARY KEY ([cClinicalInteractionsAndAlertsId])
);
