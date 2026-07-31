-- Rx365PatientAppendix   (0 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[Rx365PatientAppendix] (
    [PatientId] varchar(50) NOT NULL,
    [Rx365ID] uniqueidentifier NULL,
    [LastLogin] datetime NULL,
    [StoreNumber] varchar(50) NULL,
    [Email] varchar(500) NULL,
    CONSTRAINT [PK_Rx365PatientAppendix] PRIMARY KEY ([PatientId])
);
