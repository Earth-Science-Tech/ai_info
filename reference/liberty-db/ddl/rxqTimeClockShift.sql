-- rxqTimeClockShift   (2 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqTimeClockShift] (
    [id] nvarchar(50) NOT NULL,
    [UserId] nvarchar(50) NULL,
    [TimeIn] datetime NULL,
    [TimeOut] datetime NULL,
    [ShiftType] int NULL,
    [EntryEdited] bit NULL,
    CONSTRAINT [PK_rxqTimeClockShift] PRIMARY KEY ([id])
);

-- Indexes
CREATE INDEX [IX_TimeClockShift_TimeOut] ON [dbo].[rxqTimeClockShift] ([TimeOut]);
CREATE INDEX [IX_TimeClockShift_UserId_TimeOut] ON [dbo].[rxqTimeClockShift] ([UserId], [TimeOut]);
CREATE INDEX [NonClusteredIndex-20180320-161631] ON [dbo].[rxqTimeClockShift] ([UserId]);
CREATE INDEX [NonClusteredIndex-20180320-161813] ON [dbo].[rxqTimeClockShift] ([TimeIn], [TimeOut]);
