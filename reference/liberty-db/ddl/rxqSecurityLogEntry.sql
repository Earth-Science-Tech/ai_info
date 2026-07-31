-- rxqSecurityLogEntry   (328,613 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqSecurityLogEntry] (
    [cSecurityLogEntryId] int IDENTITY NOT NULL,
    [EntryDate] datetime NULL,
    [UserId] varchar(50) NULL,
    [SecurityEvent] varchar(50) NULL,
    [EventData] varchar(500) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    CONSTRAINT [PK_rxqSecurityLogEntry] PRIMARY KEY ([cSecurityLogEntryId])
);
