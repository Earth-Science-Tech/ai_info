-- rxqRxAppointmentAlertSettings   (0 rows, 13 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqRxAppointmentAlertSettings] (
    [RxAppointmentAlertSettingId] int IDENTITY NOT NULL,
    [CampaignId] int NULL,
    [Enabled] bit NULL,
    [AlertEmailMessage] nvarchar(max) NULL,
    [AlertEmailSubject] nvarchar(max) NULL,
    [AlertTextMessage] nvarchar(max) NULL,
    [AlertVoiceMessage] nvarchar(max) NULL,
    [StoreNumber] varchar(6) NULL,
    [AlertType] int NULL,
    [AlertDays] int NULL,
    [AlertHours] int NULL,
    [AlertMinutes] int NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqRxAppointmentAlertSettings] PRIMARY KEY ([RxAppointmentAlertSettingId])
);
