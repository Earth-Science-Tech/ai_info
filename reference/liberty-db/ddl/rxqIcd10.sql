-- rxqIcd10   (74,720 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqIcd10] (
    [Icd10Code] nvarchar(50) NOT NULL,
    [Description] nvarchar(max) NOT NULL,
    [LastModified] datetime NOT NULL,
    [IsValid] bit NOT NULL,
    CONSTRAINT [PK_rxqIcd10] PRIMARY KEY ([Icd10Code])
);

-- Indexes
CREATE INDEX [_dta_index_rxqIcd10_195_587149137__K1_2] ON [dbo].[rxqIcd10] ([Icd10Code]) INCLUDE ([Description]);
