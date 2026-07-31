-- rxqPatientAccountReceivable   (14,220 rows, 31 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPatientAccountReceivable] (
    [cPatientAccountReceivableId] int IDENTITY NOT NULL,
    [AccountId] varchar(50) NOT NULL,
    [Lastname] varchar(50) NULL,
    [FirstName] varchar(50) NULL,
    [MiddleInitial] varchar(50) NULL,
    [AccountNumber] int NULL,
    [CreditLimit] int NULL,
    [FinanceChargeSwitch] int NULL,
    [FinanceChargePeriod] varchar(50) NULL,
    [PrintCode] varchar(50) NULL,
    [LastPaymentAmount] float NULL,
    [LastPaymentDate] date NULL,
    [ResponsibleIdentifier] varchar(50) NULL,
    [YearToDateInterest] float NULL,
    [PreviousBalance] float NULL,
    [AmountDue] float NULL,
    [Over30Days] float NULL,
    [Over60Days] float NULL,
    [Over90Days] float NULL,
    [Over120Days] float NULL,
    [CurrentDebits] float NULL,
    [CurrentCredits] float NULL,
    [TotalBalance] float NULL,
    [YearToDateMedical] float NULL,
    [FinanceChargeFlag] varchar(50) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    [ServiceChargeFlag] varchar(50) NULL,
    [ServiceChargeAmount] float NULL,
    [OwnerPatientId] varchar(50) NOT NULL,
    [cAccountReceivablePrintCodeId] int NULL,
    CONSTRAINT [PK_rxqPatientAccountReceivable] PRIMARY KEY ([AccountId])
);

-- Indexes
CREATE UNIQUE INDEX [IDX_PatAccRev_OPId] ON [dbo].[rxqPatientAccountReceivable] ([OwnerPatientId]);
CREATE INDEX [IX_cAccountNumber] ON [dbo].[rxqPatientAccountReceivable] ([AccountNumber]);
