-- rxqIcd9CrossReference   (0 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqIcd9CrossReference] (
    [cIcd9CrossReferenceId] int IDENTITY NOT NULL,
    [Icd9Prefix] varchar(50) NULL,
    [Icd9Code] varchar(50) NULL,
    [DiseaseCode] int NULL,
    [ActivityCode] varchar(50) NULL,
    [LastChangeDateYYYYMMDD] varchar(50) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    CONSTRAINT [PK_rxqIcd9CrossReference] PRIMARY KEY ([cIcd9CrossReferenceId])
);
