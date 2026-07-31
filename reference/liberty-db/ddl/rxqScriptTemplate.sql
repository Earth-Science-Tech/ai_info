-- rxqScriptTemplate   (14 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqScriptTemplate] (
    [cScriptTemplateId] int IDENTITY NOT NULL,
    [Template] varchar(8000) NULL,
    [TemplateName] varchar(200) NULL,
    [StoreNumber] nvarchar(50) NULL,
    [UserId] nvarchar(50) NULL,
    [LastModified] datetime NULL,
    [SortOrder] int NULL,
    CONSTRAINT [PK_rxqScriptTemplate] PRIMARY KEY ([cScriptTemplateId])
);
