-- AppointmentItem   (0 rows, 12 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[AppointmentItem] (
    [Id] uniqueidentifier NOT NULL,
    [AppointmentSettingId] uniqueidentifier NOT NULL,
    [Status] int NULL,
    [Name] nvarchar(max) NULL,
    [Notes] nvarchar(400) NULL,
    [StartDate] date NULL,
    [EndDate] date NULL,
    [AllowFillQueue] bit NULL,
    [FillQueueType] int NULL,
    [FillQueueId] varchar(50) NULL,
    [QuestionnaireId] uniqueidentifier NULL,
    [Ordering] int NULL,
    CONSTRAINT [PK_AppointmentItem] PRIMARY KEY ([Id])
);
