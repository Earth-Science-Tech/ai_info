-- rxqTimeClockEntry   (0 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqTimeClockEntry] (
    [cTimeClockEntryId] int IDENTITY NOT NULL,
    [UserId] varchar(50) NOT NULL,
    [ActionDate] datetime NOT NULL,
    [ActionCode] varchar(50) NULL,
    [EntryEdited] varchar(50) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    CONSTRAINT [PK_rxqTimeClockEntry] PRIMARY KEY ([UserId], [ActionDate])
);
