-- DrugPreference   (0 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[DrugPreference] (
    [ID] int IDENTITY NOT NULL,
    [PatientID] nvarchar(50) NULL,
    [DrugID] nvarchar(50) NULL,
    [Notes] nvarchar(max) NULL,
    CONSTRAINT [PK_DrugPreference] PRIMARY KEY ([ID])
);
