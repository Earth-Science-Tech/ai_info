-- rxqPatientConsultation   (1 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPatientConsultation] (
    [id] nvarchar(50) NOT NULL,
    [patientId] nvarchar(50) NULL,
    [consultationDate] datetime NULL,
    [notes] nvarchar(max) NULL,
    [rphInitials] nvarchar(50) NULL,
    [IsActive] bit NULL,
    [TicketNumber] nvarchar(50) NULL,
    [StoreNumber] nvarchar(50) NULL,
    [ConsultationCompletedDate] datetime NULL,
    CONSTRAINT [PK_rxqPatientConsultation] PRIMARY KEY ([id])
);

-- Indexes
CREATE INDEX [indexDatePatientConsultation] ON [dbo].[rxqPatientConsultation] ([consultationDate]);
CREATE INDEX [storeIndexPatientConsultation] ON [dbo].[rxqPatientConsultation] ([StoreNumber]);
