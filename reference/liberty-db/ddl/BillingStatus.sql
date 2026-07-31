-- BillingStatus   (0 rows, 11 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[BillingStatus] (
    [Id] int IDENTITY NOT NULL,
    [ScriptNumber] int NOT NULL,
    [RefillNumber] int NOT NULL,
    [EventId] int NULL,
    [PayerOrder] int NOT NULL,
    [IsActive] bit NOT NULL,
    [LastModified] datetime NULL,
    [AdjustedTotal] decimal(9,2) NULL,
    [PatientPay] decimal(9,2) NULL,
    [EvoucherTotal] decimal(9,2) NULL,
    [LastPaidClaimBy] varchar(50) NULL,
    CONSTRAINT [PK_BillingStatus] PRIMARY KEY ([ScriptNumber], [RefillNumber], [PayerOrder])
);
