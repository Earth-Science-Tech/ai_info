-- ScriptOperations   (0 rows, 15 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[ScriptOperations] (
    [Id] int IDENTITY NOT NULL,
    [ScriptNumber] int NULL,
    [RefillNumber] int NULL,
    [DrugId] varchar(50) NULL,
    [StoreNumber] varchar(50) NULL,
    [Amount] decimal(12,3) NULL,
    [FillType] int NULL,
    [ParentId] int NULL,
    [PreviousId] int NULL,
    [Completed] bit NULL,
    [GPI] int NULL,
    [CreatedOn] datetime NULL,
    [EventChanges] varchar(max) NULL,
    [DispensedDate] datetime NULL,
    [PickupDate] datetime NULL,
    CONSTRAINT [PK_ScriptOperations] PRIMARY KEY ([Id])
);
