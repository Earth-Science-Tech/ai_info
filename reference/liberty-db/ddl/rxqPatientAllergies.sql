-- rxqPatientAllergies   (142,771 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPatientAllergies] (
    [PatientId] varchar(50) NOT NULL,
    [Allergy] varchar(50) NOT NULL,
    [AllergyNotes] varchar(1250) NULL,
    [AllergyDateAdded] datetime NULL,
    [LastModified] datetime NULL,
    [SystemType] int NOT NULL,
    [SourceDrugId] varchar(200) NULL,
    [AllergyName] varchar(200) NULL,
    [AllergyType] int NOT NULL,
    CONSTRAINT [PK_rxqPatientAllergies] PRIMARY KEY ([PatientId], [Allergy], [SystemType], [AllergyType])
);
