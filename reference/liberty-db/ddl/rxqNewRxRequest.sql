-- rxqNewRxRequest   (0 rows, 13 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqNewRxRequest] (
    [MessageId] varchar(100) NOT NULL,
    [eScriptId] int NOT NULL,
    [StoreNumber] varchar(2) NOT NULL,
    [Status] int NOT NULL,
    [DateCreated] datetime NOT NULL,
    [LastModified] datetime NOT NULL,
    [PatientId] varchar(50) NOT NULL,
    [DoctorId] varchar(50) NOT NULL,
    [SPI] varchar(13) NOT NULL,
    [DrugId] varchar(50) NULL,
    [DrugName] varchar(75) NULL,
    [Diagnosis] varchar(255) NULL,
    [Note] varchar(max) NULL,
    CONSTRAINT [PK_rxqNewRxRequest] PRIMARY KEY ([MessageId])
);
