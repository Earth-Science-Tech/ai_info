-- PatientAuxiliary   (0 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[PatientAuxiliary] (
    [PatientId] varchar(50) NOT NULL,
    [MpppLastRequired] datetime NULL,
    [Rx365MedicationReminders] varchar(max) NULL,
    [SuppressInactiveLtcWarning] bit NULL,
    [PickupPreference] tinyint NULL,
    [DeliveryInstructions] varchar(250) NULL,
    CONSTRAINT [PK_PatientAuxiliary] PRIMARY KEY ([PatientId])
);
