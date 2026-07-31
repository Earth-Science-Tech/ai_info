-- rxqTasksRecurrence   (5 rows, 20 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqTasksRecurrence] (
    [cTaskRecurrenceId] int IDENTITY NOT NULL,
    [cTaskId] int NOT NULL,
    [RecurrenceType] smallint NULL,
    [Periodicity] int NULL,
    [AllDay] bit NULL,
    [DayNumber] int NULL,
    [WeekDays] varchar(20) NULL,
    [WeekOfMonth] varchar(20) NULL,
    [FirstDayOfWeek] varchar(20) NULL,
    [Month] int NULL,
    [StartDate] datetime NULL,
    [Range] int NULL,
    [OccurrenceCount] int NULL,
    [EndDate] datetime NULL,
    [CreatedBy] varchar(50) NULL,
    [CreatedDateTime] datetime NULL,
    [ModifiedBy] varchar(50) NULL,
    [ModifiedDateTime] datetime NULL,
    [VersionNumber] int NULL,
    [CompletedRecurrenceDate] nvarchar(max) NULL,
    CONSTRAINT [PK_rxqTasksRecurrence] PRIMARY KEY ([cTaskRecurrenceId])
);
