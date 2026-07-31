-- rxqDrugImmunizationDose   (1 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDrugImmunizationDose] (
    [DrugImmunizationDoseId] int IDENTITY NOT NULL,
    [DrugId] varchar(50) NULL,
    [DoseNumber] int NULL,
    [DaysUntilNextDose] int NULL,
    [ImmunizationFeeOverride] decimal(9,2) NULL,
    [TemplateId] int NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqDrugImmunizationDose] PRIMARY KEY ([DrugImmunizationDoseId])
);
