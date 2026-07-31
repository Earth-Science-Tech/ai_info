-- rxqScheduledDiscontinuation   (0 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqScheduledDiscontinuation] (
    [ScriptNumber] int NOT NULL,
    [DiscontinueOn] date NULL,
    [CreatedBy] varchar(50) NULL,
    [CreatedAt] datetime NULL,
    [Success] bit NULL,
    [DiscontinuedAt] datetime NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqScheduledDiscontinuation] PRIMARY KEY ([ScriptNumber])
);

-- Indexes
CREATE INDEX [rxqScheduledDiscontinue_ScriptNumber_index] ON [dbo].[rxqScheduledDiscontinuation] ([ScriptNumber]);
