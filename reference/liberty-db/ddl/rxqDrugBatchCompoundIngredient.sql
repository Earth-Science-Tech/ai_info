-- rxqDrugBatchCompoundIngredient   (54,314 rows, 18 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDrugBatchCompoundIngredient] (
    [id] nvarchar(50) NOT NULL,
    [BatchId] nvarchar(50) NULL,
    [MixtureSequence] int NULL,
    [IngredientDrugKey] nvarchar(50) NULL,
    [MetricDecimalQuantity] decimal(15,8) NULL,
    [BasisOfCost] nvarchar(50) NULL,
    [IngredientLotNumber] nvarchar(50) NULL,
    [IngredientExpirationDate] datetime NULL,
    [ActiveIngredient] bit NULL,
    [ActiveIngredientRatio] decimal(12,5) NULL,
    [Cost] decimal(9,2) NULL,
    [DrugName] varchar(100) NULL,
    [NDCNumber] nvarchar(50) NULL,
    [MetricDecimalQuantityActual] decimal(15,8) NULL,
    [InputType] int NULL,
    [WeightType] int NULL,
    [Wastage] bit NULL,
    [BillIngredient] bit NULL,
    CONSTRAINT [PK_rxqDrugBatchCompoundIngredient] PRIMARY KEY ([id])
);

-- Indexes
CREATE INDEX [Batch-DrugCompoundIdIndex] ON [dbo].[rxqDrugBatchCompoundIngredient] ([BatchId]);
