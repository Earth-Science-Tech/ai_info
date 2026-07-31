-- AppointmentBase   (0 rows, 17 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[AppointmentBase] (
    [Id] uniqueidentifier NOT NULL,
    [AppointmentSettingsId] uniqueidentifier NULL,
    [StoreNumber] varchar(50) NULL,
    [Subject] nvarchar(500) NULL,
    [Description] nvarchar(500) NULL,
    [StartTime] datetime NULL,
    [EndTime] datetime NULL,
    [FirstName] nvarchar(200) NULL,
    [LastName] nvarchar(200) NULL,
    [DateOfBirth] datetime NULL,
    [Phone] nvarchar(15) NULL,
    [Email] nvarchar(200) NULL,
    [Notes] nvarchar(1000) NULL,
    [Scheduled] bit NULL,
    [IsReturnCustomer] bit NULL,
    [SlotId] int NULL,
    [AppointmentItemId] uniqueidentifier NULL,
    CONSTRAINT [PK_AppointmentBase] PRIMARY KEY ([Id])
);

-- Indexes
CREATE INDEX [missing_index_62_61_AppointmentBase] ON [dbo].[AppointmentBase] ([Scheduled], [StartTime]) INCLUDE ([AppointmentSettingsId], [Subject], [Description], [EndTime], [FirstName], [LastName], [DateOfBirth], [Phone], [Email], [IsReturnCustomer], [SlotId]);
