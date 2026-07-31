-- rxqTreatmentSchedule   (9 rows, 26 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqTreatmentSchedule] (
    [cTreatmentScheduleId] int IDENTITY NOT NULL,
    [TreatmentScheduleName] varchar(50) NOT NULL,
    [PatientId] varchar(50) NOT NULL,
    [Time1] varchar(50) NULL,
    [Time2] varchar(50) NULL,
    [Time3] varchar(50) NULL,
    [Time4] varchar(50) NULL,
    [Time5] varchar(50) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    [SortOrder] int NULL,
    [SortWeight] int NULL,
    [DoseQuantity] decimal(9,3) NULL,
    [RepeatPattern] varchar(200) NULL,
    [Time6] varchar(50) NULL,
    [Time7] varchar(50) NULL,
    [Time8] varchar(50) NULL,
    [EmarPrintCode] varchar(3) NULL,
    [CustomSortOrder] int NULL,
    [PRN] bit NULL,
    [ParentId] int NOT NULL,
    [Index] int NOT NULL,
    [StartDate] date NULL,
    [EndDate] date NULL,
    [Sigs] nvarchar(500) NULL,
    [DecodedSigs] nvarchar(500) NULL,
    CONSTRAINT [PK_rxqTreatmentSchedule] PRIMARY KEY ([cTreatmentScheduleId])
);

-- Indexes
CREATE INDEX [IX_TreatmentSchedule] ON [dbo].[rxqTreatmentSchedule] ([PatientId]) INCLUDE ([cTreatmentScheduleId], [Time1], [Time2], [Time3], [Time4], [Time5], [LastModified], [IsValid], [SortOrder], [SortWeight], [DoseQuantity], [RepeatPattern], [Time6], [Time7], [Time8], [EmarPrintCode], [CustomSortOrder], [PRN]);
