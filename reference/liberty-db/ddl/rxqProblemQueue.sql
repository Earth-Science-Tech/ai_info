-- rxqProblemQueue   (1,156 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqProblemQueue] (
    [cProblemQueueId] int IDENTITY NOT NULL,
    [ScriptNumber] int NULL,
    [RefillNumber] int NULL,
    [UserId] nvarchar(50) NULL,
    [ProblemCategory] varchar(100) NULL,
    [ProblemNotes] varchar(max) NULL,
    [ProblemDate] datetime NULL,
    [LastModified] datetime NULL,
    [eScriptId] int NULL,
    CONSTRAINT [PK_rxqProblemQueue] PRIMARY KEY ([cProblemQueueId])
);
