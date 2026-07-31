-- rxqNotes   (407,166 rows, 14 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
-- NOTE: mirrored into liberty_link_stage by the eMed ETL.
CREATE TABLE [dbo].[rxqNotes] (
    [cNotesId] int IDENTITY NOT NULL,
    [Type] varchar(50) NOT NULL,
    [TypeKey] varchar(50) NOT NULL,
    [OriginalDate] datetime NULL,
    [LastDate] datetime NULL,
    [Message] text NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    [Behavior] char(1) NULL,
    [CategoryId] int NULL,
    [OriginalTech] varchar(50) NULL,
    [LastTech] varchar(50) NULL,
    [ShowAtRegister] bit NULL,
    [Pinned] datetime NULL,
    CONSTRAINT [PK_rxqNotes] PRIMARY KEY ([cNotesId])
);

-- Indexes
CREATE INDEX [IDX_rxqNotes_Type_IsValid] ON [dbo].[rxqNotes] ([Type], [IsValid]) INCLUDE ([TypeKey]);
CREATE INDEX [IX_rxqNotes] ON [dbo].[rxqNotes] ([Type], [TypeKey]);
