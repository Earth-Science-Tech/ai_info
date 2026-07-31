-- rxqWorkCompPayment   (0 rows, 10 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqWorkCompPayment] (
    [cWorkCompPaymentId] numeric(18,0) IDENTITY NOT NULL,
    [ScriptNumber] int NOT NULL,
    [RefillNumber] int NOT NULL,
    [SequenceNumber] int NOT NULL,
    [PaymentDate] date NULL,
    [CheckNumber] varchar(50) NULL,
    [Amount] decimal(9,2) NULL,
    [StoreNumber] int NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    CONSTRAINT [PK_rxqWorkCompPayment] PRIMARY KEY ([ScriptNumber], [RefillNumber], [SequenceNumber])
);
