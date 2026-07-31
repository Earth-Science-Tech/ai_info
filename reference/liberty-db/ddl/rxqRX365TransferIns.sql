-- rxqRX365TransferIns   (0 rows, 15 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqRX365TransferIns] (
    [cRX365TransferInsId] int IDENTITY NOT NULL,
    [TransferInsId] int NULL,
    [PharmacyName] nvarchar(max) NULL,
    [PharmacyPhone] nvarchar(max) NULL,
    [PharmacyCity] nvarchar(max) NULL,
    [PharmacyState] nvarchar(max) NULL,
    [Rx365ID] uniqueidentifier NULL,
    [UserId] int NULL,
    [WorkflowStatus] int NULL,
    [ImportDate] datetime NULL,
    [LastModified] datetime NULL,
    [StoreNumber] varchar(50) NULL,
    [RXQPatientId] varchar(50) NULL,
    [DateCompleted] datetime NULL,
    [LastPrintedDate] datetime NULL,
    CONSTRAINT [PK_rxqRX365TransferIns] PRIMARY KEY ([cRX365TransferInsId])
);
