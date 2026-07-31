-- CentralFillScriptDetails   (0 rows, 18 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[CentralFillScriptDetails] (
    [Id] int IDENTITY NOT NULL,
    [ScriptNumber] int NOT NULL,
    [RefillNumber] int NOT NULL,
    [Status] int NOT NULL,
    [ServiceId] int NOT NULL,
    [OrderNumber] int NULL,
    [GlobalFillId] varchar(50) NULL,
    [Sent] datetime2(7) NULL,
    [DeliveryReady] datetime2(7) NULL,
    [Problem] varchar(50) NULL,
    [DeliveryNumber] int NULL,
    [ExceptionId] int NULL,
    [DeliveryChanged] bit NULL,
    [CentralFillCompletedOrdersId] uniqueidentifier NULL,
    [ManualCheckInReason] nvarchar(50) NULL,
    [ManualCheckInBy] varchar(100) NULL,
    [ManualCheckInDate] datetime NULL,
    [RemovedFromCF] bit NOT NULL,
    CONSTRAINT [PK_CentralFillScriptDetails] PRIMARY KEY ([Id])
);

-- Indexes
CREATE INDEX [IX_CentralFillScriptDetails] ON [dbo].[CentralFillScriptDetails] ([ScriptNumber], [RefillNumber]);
