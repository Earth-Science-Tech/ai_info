-- MedSyncPatientReview   (0 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[MedSyncPatientReview] (
    [PatientId] varchar(50) NOT NULL,
    [ReviewDate] datetime NOT NULL,
    [ReviewerUserId] varchar(50) NULL,
    [SyncDate] datetime NOT NULL,
    [WorkflowDate] datetime NOT NULL,
    [ProgramDays] int NOT NULL,
    CONSTRAINT [PK_MedSyncPatientReview] PRIMARY KEY ([PatientId], [ProgramDays])
);
