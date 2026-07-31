-- QuestionnaireCondition   (0 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[QuestionnaireCondition] (
    [Id] uniqueidentifier NOT NULL,
    [QuestionnaireId] uniqueidentifier NOT NULL,
    [Type] int NOT NULL,
    [Value] varchar(max) NULL,
    [Description] nvarchar(200) NULL,
    CONSTRAINT [PK_QuestionnaireCondition] PRIMARY KEY ([Id])
);
