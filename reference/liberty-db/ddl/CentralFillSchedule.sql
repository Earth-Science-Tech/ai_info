-- CentralFillSchedule   (0 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[CentralFillSchedule] (
    [DeliveryNumber] int NOT NULL,
    [ServiceId] int NOT NULL,
    [CutoffDay] int NOT NULL,
    [CutoffTime] time(7) NOT NULL,
    [DeliveryDay] int NOT NULL,
    [DeliveryTime] time(7) NOT NULL,
    [LeadDays] int NOT NULL,
    CONSTRAINT [PK_CentralFillSchedule] PRIMARY KEY ([DeliveryNumber], [ServiceId])
);
