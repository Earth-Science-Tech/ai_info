-- rxqNHMedsheetReport   (0 rows, 24 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqNHMedsheetReport] (
    [id] int IDENTITY NOT NULL,
    [IncludeScriptsOnHold] bit NULL,
    [ScriptSequence] nvarchar(50) NULL,
    [PatientSequence] nvarchar(50) NULL,
    [Stations] bit NULL,
    [Room] bit NULL,
    [Bed] bit NULL,
    [StationsBeginning] nvarchar(50) NULL,
    [StationsEnd] nvarchar(50) NULL,
    [RoomBeginning] nvarchar(50) NULL,
    [RoomEnd] nvarchar(50) NULL,
    [BedBeginning] nvarchar(50) NULL,
    [BedEnd] nvarchar(50) NULL,
    [IncludeStatus0] bit NULL,
    [IncludeStatus1] bit NULL,
    [IncludeStatus2] bit NULL,
    [IncludeStatus3] bit NULL,
    [IncludeStatus4] bit NULL,
    [AddTreatmentSchedules] bit NULL,
    [ShowSetupWindow] bit NULL,
    [AddOrders] bit NULL,
    [MoveOrdersToTop] bit NULL,
    [GenerateMedsheetsFor] bit NULL,
    [SelectScriptDateRange] bit NULL,
    CONSTRAINT [PK_rxqNHMedsheetReport] PRIMARY KEY ([id])
);
