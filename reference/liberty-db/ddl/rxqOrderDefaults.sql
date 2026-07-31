-- rxqOrderDefaults   (1 rows, 11 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqOrderDefaults] (
    [IncludeRXQ] bit NULL,
    [IncludeBZQ] bit NULL,
    [CreateType] int NULL,
    [DrugScheduleOptions] int NULL,
    [SortOptions] int NULL,
    [VendorOptions] int NULL,
    [NextOrderNumber] int NULL,
    [OldPOQ] bit NULL,
    [id] int IDENTITY NOT NULL,
    [UsageDays] int NULL,
    [QuantityOnActiveOrders] bit NULL,
    CONSTRAINT [PK_rxqOrderDefaults] PRIMARY KEY ([id])
);
