-- rxqStoreHolidays   (0 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqStoreHolidays] (
    [cStoreHolidaysId] int IDENTITY NOT NULL,
    [StoreNumber] varchar(50) NULL,
    [HolidayDescription] varchar(200) NULL,
    [HolidayDate] date NULL,
    [IsOpen] bit NULL,
    [StartHours] bigint NULL,
    [EndHours] bigint NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqStoreHolidays] PRIMARY KEY ([cStoreHolidaysId])
);
