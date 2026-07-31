-- rxqPatientMessageAttachment   (96 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPatientMessageAttachment] (
    [id] nvarchar(50) NOT NULL,
    [PatientMessageId] nvarchar(50) NULL,
    [Data] nvarchar(max) NULL,
    [DataType] int NULL,
    CONSTRAINT [PK_rxqPatientMessageAttachment] PRIMARY KEY ([id])
);
