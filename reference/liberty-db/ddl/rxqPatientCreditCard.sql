-- rxqPatientCreditCard   (0 rows, 10 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPatientCreditCard] (
    [cPatientCreditCardId] int IDENTITY NOT NULL,
    [PatientId] varchar(50) NULL,
    [CardNumber] varbinary(max) NULL,
    [ExpireDateYYMM] varchar(50) NULL,
    [LastName] varchar(50) NULL,
    [FirstName] varchar(50) NULL,
    [ZipCode] varchar(50) NULL,
    [Code3Digit] varchar(50) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    CONSTRAINT [PK_rxqPatientCreditCard] PRIMARY KEY ([cPatientCreditCardId])
);
