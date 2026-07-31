-- rxqPatientHipaaAcknowledge   (67,745 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPatientHipaaAcknowledge] (
    [cPatientHipaaAcknowledgeId] int IDENTITY NOT NULL,
    [PatientId] varchar(50) NOT NULL,
    [StoreNumber] varchar(50) NOT NULL,
    [AcknowledgeDate] datetime NOT NULL,
    [LastModified] datetime NULL,
    [Acknowledged] bit NULL,
    [Signature] varchar(max) NULL,
    [CurrentStatus] int NULL,
    CONSTRAINT [PK_rxqPatientHipaaAcknowledge] PRIMARY KEY ([cPatientHipaaAcknowledgeId])
);

-- Indexes
CREATE INDEX [rxqPatientHipaaAcknowledge_PatientIdStoreNumberAcknowledgeDate] ON [dbo].[rxqPatientHipaaAcknowledge] ([PatientId], [StoreNumber], [AcknowledgeDate]);
