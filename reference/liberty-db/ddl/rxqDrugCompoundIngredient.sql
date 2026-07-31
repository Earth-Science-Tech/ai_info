-- rxqDrugCompoundIngredient   (6,062 rows, 13 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDrugCompoundIngredient] (
    [cDrugCompoundIngredientId] int IDENTITY NOT NULL,
    [ParentDrugKey] varchar(50) NOT NULL,
    [MixtureSequence] int NOT NULL,
    [IngredientDrugKey] varchar(50) NULL,
    [BasisOfCost] varchar(50) NULL,
    [MetricDecimalQuantity] float NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    [ActiveIngredient] bit NOT NULL,
    [ActiveIngredientRatio] float NOT NULL,
    [BillIngredient] bit NULL,
    [QuantitySufficient] bit NOT NULL,
    [Wastage] bit NULL,
    CONSTRAINT [PK_rxqDrugCompoundIngredient] PRIMARY KEY ([ParentDrugKey], [MixtureSequence])
);

-- Indexes
CREATE INDEX [IX_DrugCompoundIngredient_IngredientDrugKey] ON [dbo].[rxqDrugCompoundIngredient] ([IngredientDrugKey]);
