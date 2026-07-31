-- StockReturnHistory   (137 rows, 19 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[StockReturnHistory] (
    [ID] int IDENTITY NOT NULL,
    [ScriptNumber] int NULL,
    [RefillNumber] int NULL,
    [cScriptBaseId] numeric(18,0) NOT NULL,
    [TransactionNumber] int NOT NULL,
    [PatientID] varchar(50) NOT NULL,
    [DrugID] varchar(50) NOT NULL,
    [StoreNumber] varchar(50) NULL,
    [RtsDate] datetime NOT NULL,
    [User] varchar(50) NOT NULL,
    [Display] bit NULL,
    [Type] int NOT NULL,
    [Agency] varchar(50) NULL,
    [PatientPaid] decimal(12,2) NULL,
    [InsurancePaid] decimal(12,2) NULL,
    [Copay] decimal(12,2) NULL,
    [Total] decimal(12,2) NULL,
    [QuantityReturned] varchar(50) NULL,
    [Reason] varchar(50) NULL,
    CONSTRAINT [PK_StockReturnHistory] PRIMARY KEY ([ID])
);
