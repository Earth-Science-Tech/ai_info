-- DrugPreferredVendor   (1,059 rows, 3 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[DrugPreferredVendor] (
    [DrugId] varchar(50) NOT NULL,
    [StoreNumber] varchar(50) NOT NULL,
    [VendorId] int NOT NULL,
    CONSTRAINT [PK_DrugPreferredVendor] PRIMARY KEY ([DrugId], [StoreNumber], [VendorId])
);
