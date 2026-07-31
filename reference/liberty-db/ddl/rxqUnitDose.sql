-- rxqUnitDose   (0 rows, 14 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqUnitDose] (
    [ScriptNumber] int NOT NULL,
    [MorningQty] nvarchar(50) NULL,
    [NoonQty] nvarchar(50) NULL,
    [EveningQty] nvarchar(50) NULL,
    [NightQty] nvarchar(50) NULL,
    [MorningOverride] nvarchar(50) NULL,
    [NoonOverride] nvarchar(50) NULL,
    [EveningOverride] nvarchar(50) NULL,
    [NightOverride] nvarchar(50) NULL,
    [DispenseType] int NULL,
    [TimesQtysName] nvarchar(50) NULL,
    [DaysInCycle] int NULL,
    [StartDate] datetime NULL,
    [MOTOverride] nvarchar(max) NULL,
    CONSTRAINT [PK_rxqUnitDose] PRIMARY KEY ([ScriptNumber])
);
