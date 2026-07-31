-- rxqSpecialtySubmission   (0 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqSpecialtySubmission] (
    [ScriptNumber] int NOT NULL,
    [RefillNumber] int NOT NULL,
    [LastModified] datetime NOT NULL,
    [ID1] varchar(50) NULL,
    [ID2] varchar(50) NULL,
    [Status] varchar(50) NULL,
    [SubStatus] varchar(50) NULL,
    CONSTRAINT [PK_rxqSpecialtySubmission] PRIMARY KEY ([ScriptNumber], [RefillNumber])
);
