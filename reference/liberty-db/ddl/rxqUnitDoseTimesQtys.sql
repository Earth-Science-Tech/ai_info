-- rxqUnitDoseTimesQtys   (0 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqUnitDoseTimesQtys] (
    [id] int IDENTITY NOT NULL,
    [NHCode] nvarchar(50) NULL,
    [DoseScheduleName] nvarchar(50) NULL,
    [DoseTimesQtys] nvarchar(max) NULL,
    CONSTRAINT [PK_rxqUnitDoseTimesQtys] PRIMARY KEY ([id])
);
