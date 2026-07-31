-- Questionnaire   (0 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[Questionnaire] (
    [Id] uniqueidentifier NOT NULL,
    [Name] nvarchar(200) NULL,
    [PrintOption] int NULL,
    [RequiredReview] int NULL,
    [LastModified] datetime NULL,
    [DateAdded] datetime NULL,
    [Inactive] bit NULL,
    [SupportedLanguages] nvarchar(max) NULL,
    CONSTRAINT [PK_Questionnaire] PRIMARY KEY ([Id])
);
