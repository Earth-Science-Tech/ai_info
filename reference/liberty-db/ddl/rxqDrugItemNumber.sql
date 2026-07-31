-- rxqDrugItemNumber   (4,987 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDrugItemNumber] (
    [VendorId] int NOT NULL,
    [DrugKey] varchar(50) NOT NULL,
    [ItemNumber] varchar(50) NULL,
    [VendorContainerACQ] float NULL,
    [VendorGeneric] bit NULL,
    CONSTRAINT [PK_rxqDrugItemNumber] PRIMARY KEY ([DrugKey], [VendorId])
);

-- Indexes
CREATE INDEX [_dta_index_rxqDrugItemNumber_195_1557580587__K2_K1_3_4] ON [dbo].[rxqDrugItemNumber] ([DrugKey], [VendorId]) INCLUDE ([ItemNumber], [VendorContainerACQ]);
