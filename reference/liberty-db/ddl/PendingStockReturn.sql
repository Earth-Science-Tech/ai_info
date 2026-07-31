-- PendingStockReturn   (3,617 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[PendingStockReturn] (
    [ID] int IDENTITY NOT NULL,
    [ScriptNumber] int NOT NULL,
    [RefillNumber] int NOT NULL,
    [DateAdded] datetime NOT NULL,
    [Source] varchar(50) NOT NULL,
    [Status] int NOT NULL,
    [AddedBy] varchar(50) NULL,
    [Reason] varchar(50) NULL,
    [RtsSellWarning] bit NULL,
    CONSTRAINT [PK_PendingStockReturn] PRIMARY KEY ([ID])
);
