-- rxqClinicalOppAnswer   (0 rows, 12 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqClinicalOppAnswer] (
    [cClinicalOppAnswerId] nvarchar(200) NOT NULL,
    [cClinicalOppSettingId] nvarchar(200) NULL,
    [PatientId] varchar(50) NULL,
    [DateModified] datetime NULL,
    [DateSnoozed] datetime NULL,
    [AdditionalData] varchar(max) NULL,
    [AdditionalDataType] int NULL,
    [PreChosen] bit NULL,
    [Answered] bit NULL,
    [Attempts] int NULL,
    [LastAttempt] datetime NULL,
    [LastAnswer] int NULL,
    CONSTRAINT [PK_rxqClinicalOppAnswer] PRIMARY KEY ([cClinicalOppAnswerId])
);
