-- rxqAppointments   (12 rows, 16 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAppointments] (
    [UniqueID] int IDENTITY NOT NULL,
    [Type] int NULL,
    [StartDate] smalldatetime NULL,
    [EndDate] smalldatetime NULL,
    [AllDay] bit NULL,
    [Subject] nvarchar(50) NULL,
    [Location] nvarchar(50) NULL,
    [Description] nvarchar(max) NULL,
    [Status] int NULL,
    [Label] int NULL,
    [ResourceID] int NULL,
    [ResourceIDs] nvarchar(max) NULL,
    [ReminderInfo] nvarchar(max) NULL,
    [RecurrenceInfo] nvarchar(max) NULL,
    [TimeZoneId] nvarchar(max) NULL,
    [CustomField1] nvarchar(max) NULL,
    CONSTRAINT [PK_rxqAppointments] PRIMARY KEY ([UniqueID])
);
