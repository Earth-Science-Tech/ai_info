-- MasterNotes   (0 rows, 11 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[MasterNotes] (
    [NoteID] int IDENTITY NOT NULL,
    [OldId] int NULL,
    [Message] nvarchar(max) NULL,
    [OriginalDate] datetime NULL,
    [LastModified] datetime NULL,
    [OriginalTech] varchar(255) NULL,
    [LastTech] varchar(255) NULL,
    [Pinned] datetime NULL,
    [ListOfDisplayLocations] varchar(255) NULL,
    [DisplayFill] varchar(255) NULL,
    [CategoryId] int NULL,
    CONSTRAINT [PK_MasterNotes] PRIMARY KEY ([NoteID])
);
