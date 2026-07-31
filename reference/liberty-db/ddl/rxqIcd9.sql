-- rxqIcd9   (15,338 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqIcd9] (
    [cIcd9Id] int IDENTITY NOT NULL,
    [Icd9Prefix] varchar(50) NOT NULL,
    [Icd9Code] varchar(50) NOT NULL,
    [DiseaseDescription] varchar(50) NULL,
    [ActivityCode] varchar(50) NULL,
    [LastChangeDateYYYYMMDD] varchar(50) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    CONSTRAINT [PK_rxqIcd9] PRIMARY KEY ([Icd9Prefix], [Icd9Code])
);
