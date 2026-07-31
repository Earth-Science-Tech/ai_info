-- RX365PatientLink   (0 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[RX365PatientLink] (
    [cRX365PatientLinkId] int IDENTITY NOT NULL,
    [PatientId] varchar(50) NOT NULL,
    [LinkedPatientId] varchar(50) NOT NULL,
    [LinkExpirationDate] datetime NOT NULL,
    [DateCreated] datetime NOT NULL,
    [LastModified] datetime NOT NULL,
    [LockLink] int NOT NULL,
    CONSTRAINT [PK_RX365PatientLink] PRIMARY KEY ([PatientId], [LinkedPatientId])
);

-- Indexes
CREATE INDEX [idx_RX365PatientLink_LinkedPatientId] ON [dbo].[RX365PatientLink] ([LinkedPatientId]);
CREATE INDEX [idx_RX365PatientLink_PatientId] ON [dbo].[RX365PatientLink] ([PatientId]);
