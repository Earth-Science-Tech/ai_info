-- rxqPatientDisease   (2,403 rows, 11 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPatientDisease] (
    [cPatientDiseaseId] int IDENTITY NOT NULL,
    [PatientId] varchar(50) NOT NULL,
    [ICD9_CM_CODE] varchar(50) NOT NULL,
    [DiseaseCode] int NULL,
    [DiseaseDescription] varchar(500) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    [CodeType] varchar(5) NOT NULL,
    [DateAdded] date NULL,
    [Source] int NULL,
    [Inactive] bit NULL,
    CONSTRAINT [PK_rxqPatientDisease] PRIMARY KEY ([PatientId], [CodeType], [ICD9_CM_CODE])
);
