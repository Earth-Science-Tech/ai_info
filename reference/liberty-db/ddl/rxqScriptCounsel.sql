-- rxqScriptCounsel   (1 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqScriptCounsel] (
    [cScriptCounselId] int IDENTITY NOT NULL,
    [ScriptNumber] int NOT NULL,
    [RefillNumber] int NOT NULL,
    [DateCounseled] datetime NULL,
    [RphInitials] varchar(50) NULL,
    [Refused] bit NULL,
    [IsValid] bit NULL,
    [DenialReason] nvarchar(max) NULL,
    [PatientConsultationId] nvarchar(50) NULL,
    CONSTRAINT [PK_rxqScriptCounsel] PRIMARY KEY ([ScriptNumber], [RefillNumber])
);

-- Indexes
CREATE INDEX [indexPatientConsultationIdScriptCounsel] ON [dbo].[rxqScriptCounsel] ([PatientConsultationId]);
