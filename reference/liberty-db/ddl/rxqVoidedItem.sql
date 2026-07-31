-- rxqVoidedItem   (1,105 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqVoidedItem] (
    [voidedItemID] int IDENTITY NOT NULL,
    [itemXML] xml NOT NULL,
    [datetimeCreated] datetime NOT NULL,
    [deletedByUser] varchar(50) NULL,
    [itemType] varchar(100) NOT NULL,
    CONSTRAINT [PK_rxqVoidedItem] PRIMARY KEY ([voidedItemID])
);
