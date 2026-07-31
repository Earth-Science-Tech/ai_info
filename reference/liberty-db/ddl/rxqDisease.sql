-- rxqDisease   (0 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDisease] (
    [cDiseaseId] int IDENTITY NOT NULL,
    [DiseaseCode] int NOT NULL,
    [DiseaseDescription] varchar(50) NULL,
    [DiseaseMnewmonic] varchar(50) NULL,
    [AcuteChronicCode] varchar(50) NULL,
    [ActivityCode] varchar(50) NULL,
    [LastChangeDateYYYYMMDD] varchar(50) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    CONSTRAINT [PK_rxqDisease] PRIMARY KEY ([DiseaseCode])
);
