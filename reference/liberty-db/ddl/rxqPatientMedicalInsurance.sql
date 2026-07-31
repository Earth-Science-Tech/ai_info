-- rxqPatientMedicalInsurance   (0 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPatientMedicalInsurance] (
    [Id] int IDENTITY NOT NULL,
    [PatientId] varchar(50) NOT NULL,
    [MedicalInsuranceId] int NOT NULL,
    [MemberId] varchar(50) NOT NULL,
    [GroupNumber] varchar(50) NOT NULL,
    [Notes] varchar(255) NOT NULL,
    [Inactive] bit NOT NULL,
    CONSTRAINT [PK_rxqPatientMedicalInsurance] PRIMARY KEY ([Id])
);

-- Indexes
CREATE INDEX [IX_rxqPatientMedicalInsurance_PatientId] ON [dbo].[rxqPatientMedicalInsurance] ([PatientId]);
