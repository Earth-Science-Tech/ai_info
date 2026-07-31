-- rxqPatientAlias   (0 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPatientAlias] (
    [cPatientAliasId] int IDENTITY NOT NULL,
    [PatientId] varchar(50) NOT NULL,
    [LastName] varchar(50) NULL,
    [FirstName] varchar(50) NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqPatientAlias] PRIMARY KEY ([cPatientAliasId])
);
