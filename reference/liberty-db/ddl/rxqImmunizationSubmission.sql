-- rxqImmunizationSubmission   (0 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqImmunizationSubmission] (
    [SubmissionId] int IDENTITY NOT NULL,
    [ScriptNumber] int NOT NULL,
    [RefillNumber] int NOT NULL,
    [DateCreated] datetime NOT NULL,
    [SMPID] int NULL,
    [ErrorMessage] varchar(max) NULL,
    CONSTRAINT [PK_rxqImmunizationSubmission] PRIMARY KEY ([SubmissionId])
);
