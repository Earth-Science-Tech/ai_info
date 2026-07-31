-- rxqMedicalInsurance   (0 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqMedicalInsurance] (
    [Id] int IDENTITY NOT NULL,
    [PlanName] varchar(100) NOT NULL,
    [HelpDeskNumber] varchar(100) NOT NULL,
    [Inactive] bit NOT NULL,
    CONSTRAINT [PK_rxqMedicalInsurance] PRIMARY KEY ([Id])
);
