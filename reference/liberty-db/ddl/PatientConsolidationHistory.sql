-- PatientConsolidationHistory   (0 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[PatientConsolidationHistory] (
    [Id] uniqueidentifier NOT NULL,
    [ConsolidatedPatientId] varchar(50) NOT NULL,
    [ToPatientId] varchar(50) NOT NULL,
    [FromPatientId] varchar(50) NOT NULL,
    [ConsolidatedDateTime] datetime NOT NULL,
    [ConsolidationHistory] varchar(max) NULL,
    CONSTRAINT [PK_PatientConsolidationHistory] PRIMARY KEY ([Id])
);
