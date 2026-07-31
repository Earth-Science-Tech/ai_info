-- AutoPilotSchedule   (1 rows, 2 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[AutoPilotSchedule] (
    [StoreNumber] nvarchar(128) NOT NULL,
    [Value] varchar(max) NULL,
    CONSTRAINT [PK_AutoPilotSchedule] PRIMARY KEY ([StoreNumber])
);
