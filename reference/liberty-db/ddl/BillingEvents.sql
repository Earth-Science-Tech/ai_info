-- BillingEvents   (0 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[BillingEvents] (
    [Id] int IDENTITY NOT NULL,
    [ScriptNumber] int NOT NULL,
    [RefillNumber] int NOT NULL,
    [Sequence] int NOT NULL,
    [PayerOrder] int NOT NULL,
    [PayerType] int NOT NULL,
    [LookUpId] int NULL,
    CONSTRAINT [PK_BillingEvents] PRIMARY KEY ([ScriptNumber], [RefillNumber], [Sequence], [PayerOrder])
);
