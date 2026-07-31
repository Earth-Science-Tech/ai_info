-- rxqDrugInventoryLogMaster   (675,756 rows, 12 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDrugInventoryLogMaster] (
    [id] int IDENTITY NOT NULL,
    [DrugInventoryId] varchar(50) NOT NULL,
    [UserId] varchar(50) NULL,
    [User] varchar(50) NULL,
    [Operation] int NOT NULL,
    [ScriptId] varchar(50) NULL,
    [PurchaseOrderId] varchar(50) NULL,
    [Note] varchar(512) NULL,
    [ModifiedDate] datetime NOT NULL,
    [StoreNumber] varchar(50) NOT NULL,
    [cCategoryId] int NULL,
    [AcceptInventoryId] int NULL,
    CONSTRAINT [PK_rxqDrugInventoryLogMaster] PRIMARY KEY ([id])
);
