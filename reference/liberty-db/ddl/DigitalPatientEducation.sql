-- DigitalPatientEducation   (96 rows, 3 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[DigitalPatientEducation] (
    [NDC] varchar(50) NOT NULL,
    [LanguageCode] varchar(3) NOT NULL,
    [URL] varchar(max) NOT NULL,
    CONSTRAINT [PK_DigitalPatientEducation] PRIMARY KEY ([NDC], [LanguageCode])
);
