-- rxqNADACAverageAcq   (37,934 rows, 12 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqNADACAverageAcq] (
    [NDC] varchar(50) NOT NULL,
    [NDCDescription] varchar(500) NULL,
    [NADACPerUnit] decimal(12,6) NULL,
    [EffectiveDate] date NULL,
    [PricingUnit] varchar(50) NULL,
    [PharmacyTypeIndicator] varchar(50) NULL,
    [OTC] bit NULL,
    [ExplanationCode] varchar(50) NULL,
    [ClassificationforRateSetting] varchar(50) NULL,
    [CorrespondingGenericDrugNADACPerUnit] decimal(12,6) NULL,
    [CorrespondingGenericDrugEffectiveDate] date NULL,
    [AsOfDate] date NULL,
    CONSTRAINT [PK_rxqNADACAverageAcq] PRIMARY KEY ([NDC])
);
