-- rxqUserDrugClass   (4 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqUserDrugClass] (
    [cUserDrugClassId] int IDENTITY NOT NULL,
    [DrugKey] varchar(50) NOT NULL,
    [ClassIdCode] varchar(50) NOT NULL,
    [DateAddedYYYYMMDD] varchar(50) NULL,
    [TimeAddedHHMMSS] varchar(50) NULL,
    [AddedByUser] varchar(50) NULL,
    [FreeTextFld] varchar(50) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    CONSTRAINT [PK_rxqUserDrugClass] PRIMARY KEY ([DrugKey], [ClassIdCode])
);
