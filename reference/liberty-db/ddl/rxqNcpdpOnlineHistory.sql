-- rxqNcpdpOnlineHistory   (4 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqNcpdpOnlineHistory] (
    [TransactionID] int IDENTITY NOT NULL,
    [TransactionDateTime] datetime NULL,
    [TransactionRequest] varchar(max) NULL,
    [TransactionResponse] varchar(max) NULL,
    CONSTRAINT [PK_rxqNcpdpOnlineHistory] PRIMARY KEY ([TransactionID])
);
