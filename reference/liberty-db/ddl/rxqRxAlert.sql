-- rxqRxAlert   (164,804 rows, 12 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqRxAlert] (
    [id] nvarchar(50) NOT NULL,
    [ScriptNumber] int NULL,
    [RefillNumber] int NULL,
    [AlertType] int NULL,
    [PatientId] nvarchar(50) NULL,
    [CreatedOn] datetime NULL,
    [Sent] bit NULL,
    [SendAfter] datetime NULL,
    [StoreNumber] varchar(3) NULL,
    [AppointmentId] int NULL,
    [AppointmentAlertSettingId] int NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqRxAlert] PRIMARY KEY ([id])
);

-- Indexes
CREATE INDEX [IDX_rxqRxAlert_alertType_Sent_store] ON [dbo].[rxqRxAlert] ([AlertType], [Sent], [StoreNumber]) INCLUDE ([id], [ScriptNumber], [RefillNumber], [PatientId], [CreatedOn], [SendAfter], [AppointmentId], [AppointmentAlertSettingId], [LastModified]);
CREATE INDEX [PatientIdIndex] ON [dbo].[rxqRxAlert] ([PatientId]);
CREATE INDEX [ScriptFillIndex] ON [dbo].[rxqRxAlert] ([ScriptNumber], [RefillNumber]);
CREATE INDEX [SentDateFlagIndex] ON [dbo].[rxqRxAlert] ([Sent], [SendAfter]);
