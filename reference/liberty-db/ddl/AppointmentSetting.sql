-- AppointmentSetting   (0 rows, 18 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[AppointmentSetting] (
    [Id] uniqueidentifier NOT NULL,
    [Name] nvarchar(max) NULL,
    [StoreNumber] varchar(50) NULL,
    [StartDate] date NULL,
    [EndDate] date NULL,
    [Interval] int NULL,
    [SlotsPerInterval] int NULL,
    [RollingUnlockDays] int NULL,
    [AdditionalInfo] nvarchar(max) NULL,
    [AfterMessage] nvarchar(max) NULL,
    [AppointmentSettingType] int NULL,
    [Inactive] bit NULL,
    [DateAdded] datetime NULL,
    [LastModified] datetime NULL,
    [SchedulingLeadTime] int NULL,
    [SchedulingBuffer] int NULL,
    [DeepLinkOnly] bit NULL,
    [SupportedLanguages] nvarchar(max) NULL,
    CONSTRAINT [PK_AppointmentSetting] PRIMARY KEY ([Id])
);
