-- rxqNcpdpNarrative   (0 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqNcpdpNarrative] (
    [ScriptNumber] int NOT NULL,
    [RefillNumber] int NOT NULL,
    [NarrativeMessage] varchar(200) NOT NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    CONSTRAINT [PK_rxqNcpdpNarrative] PRIMARY KEY ([ScriptNumber], [RefillNumber])
);
