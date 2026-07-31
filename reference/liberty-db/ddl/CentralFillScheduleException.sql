-- CentralFillScheduleException   (0 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[CentralFillScheduleException] (
    [Id] int IDENTITY NOT NULL,
    [DeliveryNumber] int NOT NULL,
    [ServiceId] int NOT NULL,
    [ExceptionDate] datetime2(7) NOT NULL,
    [Type] int NOT NULL,
    [CutoffDate] datetime2(7) NULL,
    [DeliveryDate] datetime2(7) NULL,
    CONSTRAINT [PK_CentralFillScheduleException] PRIMARY KEY ([Id], [DeliveryNumber], [ServiceId])
);
