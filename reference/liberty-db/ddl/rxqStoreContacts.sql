-- rxqStoreContacts   (0 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqStoreContacts] (
    [cStoreContactsId] int IDENTITY NOT NULL,
    [StoreNumber] varchar(50) NULL,
    [ContactName] varchar(400) NULL,
    [ContactRoles] varchar(max) NULL,
    [LastModified] datetime NULL,
    [Phone] varchar(50) NULL,
    [Email] varchar(max) NULL,
    [Notes] varchar(max) NULL,
    [LinkedUserRecordId] varchar(50) NULL,
    CONSTRAINT [PK_rxqStoreContacts] PRIMARY KEY ([cStoreContactsId])
);
