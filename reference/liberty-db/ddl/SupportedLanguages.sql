-- SupportedLanguages   (0 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[SupportedLanguages] (
    [ID] int IDENTITY NOT NULL,
    [Code] varchar(3) NULL,
    [Inactive] bit NULL,
    [Color] varchar(20) NULL,
    [YesTranslation] nvarchar(10) NULL,
    [NoTranslation] nvarchar(10) NULL,
    CONSTRAINT [PK_SupportedLanguages] PRIMARY KEY ([ID])
);
