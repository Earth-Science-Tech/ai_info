-- rxqMedicareEligibilityPayers   (4 rows, 13 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqMedicareEligibilityPayers] (
    [PatientId] varchar(50) NULL,
    [CoverageType] char(2) NOT NULL,
    [IdQualifier] varchar(50) NULL,
    [Id] varchar(50) NULL,
    [PCN] varchar(50) NULL,
    [CardholderId] varchar(50) NULL,
    [GroupId] varchar(50) NULL,
    [PersonCode] varchar(50) NULL,
    [HelpDeskNumber] varchar(50) NULL,
    [PatientRelationshipCode] varchar(50) NULL,
    [BenefitEffectiveYYYYMMDD] varchar(50) NULL,
    [BenefitTerminationYYYYMMDD] varchar(50) NULL,
    [cID] int IDENTITY NOT NULL,
    CONSTRAINT [PK_rxqMedicareEligibilityPayers] PRIMARY KEY ([cID])
);
