-- rxqDirFeesConditional   (0 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDirFeesConditional] (
    [cDirFeesConditionalId] int IDENTITY NOT NULL,
    [cDirFeesId] int NULL,
    [BIN] int NULL,
    [PCN] varchar(50) NULL,
    [GroupNumber] varchar(50) NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqDirFeesConditional] PRIMARY KEY ([cDirFeesConditionalId])
);
