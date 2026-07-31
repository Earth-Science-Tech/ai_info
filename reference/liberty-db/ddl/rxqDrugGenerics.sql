-- rxqDrugGenerics   (2 rows, 12 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDrugGenerics] (
    [cDrugGenericsId] int IDENTITY NOT NULL,
    [DrugKey] varchar(50) NOT NULL,
    [GenericDrugKey1] varchar(50) NULL,
    [GenericDrugKey2] varchar(50) NULL,
    [GenericDrugKey3] varchar(50) NULL,
    [GenericDrugKey4] varchar(50) NULL,
    [GenericDrugNdc1] varchar(50) NULL,
    [GenericDrugNdc2] varchar(50) NULL,
    [GenericDrugNdc3] varchar(50) NULL,
    [GenericDrugNdc4] varchar(50) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    CONSTRAINT [PK_rxqDrugGenerics] PRIMARY KEY ([DrugKey])
);

-- Indexes
CREATE INDEX [IX_DrugGenerics_GenericDrugKey1] ON [dbo].[rxqDrugGenerics] ([GenericDrugKey1]);
CREATE INDEX [IX_DrugGenerics_GenericDrugKey2] ON [dbo].[rxqDrugGenerics] ([GenericDrugKey2]);
CREATE INDEX [IX_DrugGenerics_GenericDrugKey3] ON [dbo].[rxqDrugGenerics] ([GenericDrugKey3]);
CREATE INDEX [IX_DrugGenerics_GenericDrugKey4] ON [dbo].[rxqDrugGenerics] ([GenericDrugKey4]);
