-- rxqInsuranceCard   (0 rows, 12 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqInsuranceCard] (
    [cInsuranceCardId] int IDENTITY NOT NULL,
    [Rx365Id] int NULL,
    [CardType] int NULL,
    [FrontImage] varbinary(max) NULL,
    [BackImage] varbinary(max) NULL,
    [ImportStatusType] int NULL,
    [ImportDate] datetime NULL,
    [LastModified] datetime NULL,
    [PatientId] varchar(50) NULL,
    [AgencyCode] varchar(50) NULL,
    [AgencySequence] int NULL,
    [PatientThirdPartyId] int NULL,
    CONSTRAINT [PK_rxqInsuranceCard] PRIMARY KEY ([cInsuranceCardId])
);
