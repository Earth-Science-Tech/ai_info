-- rxqEcareTemplate   (1 rows, 14 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqEcareTemplate] (
    [ceCareTemplateId] int IDENTITY NOT NULL,
    [eCareType] int NULL,
    [TemplateEncounter] varchar(max) NULL,
    [TemplateProcedures] varchar(max) NULL,
    [TemplateConditions] varchar(max) NULL,
    [TemplateObservation] varchar(max) NULL,
    [TemplateGoals] varchar(max) NULL,
    [TemplateCommunication] varchar(max) NULL,
    [TemplateImmunization] varchar(max) NULL,
    [TemplateName] varchar(200) NULL,
    [StoreNumber] nvarchar(50) NULL,
    [SelctedTemplate] bit NULL,
    [SaveOption] int NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqEcareTemplate] PRIMARY KEY ([ceCareTemplateId])
);
