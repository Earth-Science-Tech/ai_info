-- rxqPif   (60 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPif] (
    [cPifId] int IDENTITY NOT NULL,
    [KeyName] varchar(50) NOT NULL,
    [KeySequence] varchar(50) NOT NULL,
    [ValueBuffer] varchar(50) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    CONSTRAINT [PK_rxqPif] PRIMARY KEY ([KeyName], [KeySequence])
);
