-- BinAssignmentHistory   (0 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[BinAssignmentHistory] (
    [Id] int IDENTITY NOT NULL,
    [Bin] int NOT NULL,
    [ScriptNumber] int NULL,
    [RefillNumber] int NULL,
    [DateAdded] datetime NULL,
    [AddMethod] varchar(50) NULL,
    [AddedByUser] varchar(50) NULL,
    [Comment] varchar(50) NULL,
    CONSTRAINT [PK_BinAssignmentHistory] PRIMARY KEY ([Id])
);
