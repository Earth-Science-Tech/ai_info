-- rxqScriptPartial   (0 rows, 20 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqScriptPartial] (
    [cScriptPartialId] numeric(18,0) IDENTITY NOT NULL,
    [ScriptNumber] int NOT NULL,
    [RefillNumber] int NOT NULL,
    [PartialFillNumber] int NOT NULL,
    [QuantityDispensed] decimal(9,3) NULL,
    [QuantityDispenseGoal] decimal(9,3) NULL,
    [DateDispensed] datetime NULL,
    [PosScanFlag] varchar(50) NULL,
    [PosPickupDateTime] datetime NULL,
    [PickupPatientId] varchar(50) NULL,
    [PromiseDateTime] datetime NULL,
    [WorkflowStatus] varchar(50) NULL,
    [RphInitials] varchar(50) NULL,
    [LoggedInUser] varchar(50) NULL,
    [CountedByUser] varchar(50) NULL,
    [LastModified] datetime NULL,
    [Invalid] bit NULL,
    [TimeStampComputerDateTime] datetime NULL,
    [BinId] int NULL,
    [LastAssignedBin] int NULL,
    CONSTRAINT [PK_rxqScriptPartial] PRIMARY KEY ([cScriptPartialId])
);

-- Indexes
CREATE INDEX [IX_ScriptPartial_WaitingBin] ON [dbo].[rxqScriptPartial] ([ScriptNumber], [RefillNumber], [PosPickupDateTime], [PosScanFlag]) INCLUDE ([cScriptPartialId], [PartialFillNumber], [QuantityDispensed], [BinId]);
