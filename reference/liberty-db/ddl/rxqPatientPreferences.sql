-- rxqPatientPreferences   (171,540 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPatientPreferences] (
    [cPatientPreferencesId] int IDENTITY NOT NULL,
    [LookUpId] varchar(50) NOT NULL,
    [PreferenceType] int NOT NULL,
    [Preference] varchar(50) NOT NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqPatientPreferences] PRIMARY KEY ([LookUpId], [PreferenceType], [Preference])
);
