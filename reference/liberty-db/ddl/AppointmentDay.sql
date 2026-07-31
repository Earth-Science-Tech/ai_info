-- AppointmentDay   (0 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[AppointmentDay] (
    [Id] uniqueidentifier NOT NULL,
    [AppointmentSettingId] uniqueidentifier NOT NULL,
    [DaySelection] int NULL,
    [StartTime] time(7) NULL,
    [EndTime] time(7) NULL,
    CONSTRAINT [PK_AppointmentDay] PRIMARY KEY ([Id])
);
