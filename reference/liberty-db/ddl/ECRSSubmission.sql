-- ECRSSubmission   (0 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[ECRSSubmission] (
    [TransactionCode] varchar(5) NOT NULL,
    [StoreNumber] varchar(50) NOT NULL,
    [ScriptNumber] int NOT NULL,
    [RefillNumber] int NOT NULL,
    [PartialNumber] int NOT NULL,
    [Status] int NOT NULL,
    [CreatedDate] datetime NOT NULL,
    [LastModifiedDate] datetime NOT NULL,
    CONSTRAINT [PK_ECRSSubmission] PRIMARY KEY ([TransactionCode], [ScriptNumber], [RefillNumber], [PartialNumber])
);
