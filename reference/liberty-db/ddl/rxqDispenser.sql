-- rxqDispenser   (0 rows, 16 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDispenser] (
    [cDispenserId] int IDENTITY NOT NULL,
    [DispenserType] int NULL,
    [Enabled] bit NULL,
    [NursingHome] bit NULL,
    [IPAddress] varchar(max) NULL,
    [PortNumber] int NULL,
    [AutomationStage] int NULL,
    [SendOnChange] bit NULL,
    [DispenseFor] int NULL,
    [StoreNumber] varchar(max) NULL,
    [LastModified] datetime NULL,
    [AcceptCounted] bit NULL,
    [UnitDose] bit NULL,
    [SendOnHold] bit NOT NULL,
    [SendOnVoid] bit NOT NULL,
    [Sequence] int NULL,
    CONSTRAINT [PK_rxqDispenser] PRIMARY KEY ([cDispenserId])
);
