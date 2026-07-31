-- DiscountCard   (0 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[DiscountCard] (
    [Id] int IDENTITY NOT NULL,
    [DiscountType] int NOT NULL,
    [FieldType] int NOT NULL,
    [Value] varchar(50) NOT NULL,
    CONSTRAINT [PK_DiscountCard] PRIMARY KEY ([DiscountType], [FieldType], [Value])
);
