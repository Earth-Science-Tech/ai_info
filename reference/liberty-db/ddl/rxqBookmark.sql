-- rxqBookmark   (0 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqBookmark] (
    [cBookmarkId] int IDENTITY NOT NULL,
    [BookmarkName] varchar(75) NULL,
    [Address] varchar(250) NULL,
    [UserId] varchar(50) NULL,
    CONSTRAINT [PK_rxqBookmark] PRIMARY KEY ([cBookmarkId])
);
