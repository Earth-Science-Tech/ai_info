-- CentralFillDeliveryAudit   (0 rows, 10 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[CentralFillDeliveryAudit] (
    [Id] int IDENTITY NOT NULL,
    [ScriptNumber] int NOT NULL,
    [RefillNumber] int NOT NULL,
    [Ndc] varchar(20) NOT NULL,
    [DrugName] varchar(50) NULL,
    [Delivered] bit NOT NULL,
    [CentralFillCompletedOrdersId] uniqueidentifier NULL,
    [ManualCheckInReason] varchar(50) NULL,
    [ManualCheckInBy] varchar(50) NULL,
    [ManualCheckInDate] datetime2(7) NULL,
    CONSTRAINT [PK_CentralFillDeliveryAudit] PRIMARY KEY ([Id])
);
