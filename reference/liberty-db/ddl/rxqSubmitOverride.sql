-- rxqSubmitOverride   (0 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqSubmitOverride] (
    [TableId] int IDENTITY NOT NULL,
    [OnlineHistoryId] int NOT NULL,
    [Type] varchar(50) NOT NULL,
    [OldValue] varchar(50) NOT NULL,
    [NewValue] varchar(50) NOT NULL,
    CONSTRAINT [PK_rxqSubmitOverride] PRIMARY KEY ([TableId])
);
