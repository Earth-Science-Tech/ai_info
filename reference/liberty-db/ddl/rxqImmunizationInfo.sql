-- rxqImmunizationInfo   (602,552 rows, 17 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqImmunizationInfo] (
    [ScriptNumber] int NOT NULL,
    [RefillNumber] int NOT NULL,
    [DoseNumber] int NOT NULL,
    [AdminRoute] varchar(50) NULL,
    [ConsentToReport] bit NULL,
    [ConsentToShare] bit NULL,
    [Comorbidity] bit NULL,
    [PositiveSerology] bit NULL,
    [AdministeredBy] varchar(50) NOT NULL,
    [Administered] bit NULL,
    [GuardianFirstName] varchar(50) NULL,
    [GuardianLastName] varchar(50) NULL,
    [GuardianType] varchar(3) NULL,
    [PriorityGroup] varchar(50) NULL,
    [PrimaryPhysicianId] varchar(50) NULL,
    [AdministeredAt] datetime NULL,
    [AdminDate] datetime NULL,
    CONSTRAINT [PK_rxqImmunizationInfo] PRIMARY KEY ([ScriptNumber], [RefillNumber])
);
