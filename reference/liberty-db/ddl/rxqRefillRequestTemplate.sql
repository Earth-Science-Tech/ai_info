-- rxqRefillRequestTemplate   (0 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqRefillRequestTemplate] (
    [cRefillRequestTemplateId] int IDENTITY NOT NULL,
    [Template] varchar(max) NULL,
    [TemplateName] varchar(200) NULL,
    [StoreNumber] varchar(50) NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqRefillRequestTemplate] PRIMARY KEY ([cRefillRequestTemplateId])
);
