-- rxqSigsTreatmentSchedule   (0 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqSigsTreatmentSchedule] (
    [cSigsTreatmentSchedule] int IDENTITY NOT NULL,
    [cTreatmentScheduleId] int NULL,
    [SigCode] varchar(50) NULL,
    [SigLanguage] varchar(50) NULL,
    [LastModified] datetime NULL,
    [SupportedLanguageCode] varchar(3) NULL,
    CONSTRAINT [PK_rxqSigsTreatmentSchedule] PRIMARY KEY ([cSigsTreatmentSchedule])
);
