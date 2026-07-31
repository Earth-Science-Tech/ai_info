-- rxqCustomFields   (14 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqCustomFields] (
    [cCustomFieldsId] int IDENTITY NOT NULL,
    [Type] char(1) NOT NULL,
    [TypeKey] int NOT NULL,
    [FieldName] varchar(50) NULL,
    [FieldChoices] varchar(max) NULL,
    CONSTRAINT [PK_rxqCustomFields] PRIMARY KEY ([Type], [TypeKey])
);
