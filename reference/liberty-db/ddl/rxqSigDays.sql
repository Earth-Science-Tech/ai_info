-- rxqSigDays   (140 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqSigDays] (
    [cSigDaysId] int IDENTITY NOT NULL,
    [SigCode] varchar(50) NOT NULL,
    [Multiplier] float NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    CONSTRAINT [PK_rxqSigDays] PRIMARY KEY ([SigCode])
);
