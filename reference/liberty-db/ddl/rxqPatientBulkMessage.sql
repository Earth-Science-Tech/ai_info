-- rxqPatientBulkMessage   (0 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPatientBulkMessage] (
    [PatientBulkMessageId] int IDENTITY NOT NULL,
    [BulkMessageId] int NOT NULL,
    [PatientId] varchar(50) NOT NULL,
    [PatientMessageId] varchar(50) NOT NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqPatientBulkMessage] PRIMARY KEY ([PatientBulkMessageId])
);

-- Indexes
CREATE INDEX [rxqPatientBulkMessage_BulkMessageId_index] ON [dbo].[rxqPatientBulkMessage] ([BulkMessageId]);
