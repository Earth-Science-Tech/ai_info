-- DrugUnitMultiplier   (6,410 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[DrugUnitMultiplier] (
    [Id] int IDENTITY NOT NULL,
    [DrugId] varchar(50) NOT NULL,
    [Value] decimal(18,5) NOT NULL,
    [Modified] datetime NOT NULL,
    CONSTRAINT [PK_DrugUnitMultiplier] PRIMARY KEY ([Id])
);
