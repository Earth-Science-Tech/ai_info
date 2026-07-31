-- rxqUnitDoseTemplate   (0 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqUnitDoseTemplate] (
    [cUnitDoseTemplateId] int IDENTITY NOT NULL,
    [Template] varchar(8000) NULL,
    [TemplateName] varchar(200) NULL,
    [StoreNumber] nvarchar(50) NULL,
    [UserId] nvarchar(50) NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqUnitDoseTemplate] PRIMARY KEY ([cUnitDoseTemplateId])
);
