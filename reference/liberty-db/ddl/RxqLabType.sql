-- RxqLabType   (123 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[RxqLabType] (
    [TypeId] int IDENTITY NOT NULL,
    [CatId] int NOT NULL,
    [LabName] varchar(100) NULL,
    [UnitType] varchar(50) NULL,
    [HighNormal] decimal(18,3) NULL,
    [LowNormal] decimal(18,3) NULL,
    [LoincCode] varchar(50) NULL,
    CONSTRAINT [PK_RxqLabType] PRIMARY KEY ([TypeId])
);
