-- rxqMedicareEligibility   (3 rows, 18 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqMedicareEligibility] (
    [cMedicareEligibilityId] int IDENTITY NOT NULL,
    [PatientId] varchar(50) NOT NULL,
    [BIN] varchar(50) NULL,
    [PCN] varchar(50) NULL,
    [NABP] varchar(50) NULL,
    [DateOfBirthYYYYMMDD] varchar(50) NULL,
    [Gender] varchar(50) NULL,
    [FirstName] varchar(50) NULL,
    [LastName] varchar(50) NULL,
    [ZipCode] varchar(50) NULL,
    [CardholderId] varchar(50) NULL,
    [ResponseYYYYMMDD] varchar(50) NULL,
    [ResponseHHMMSS] varchar(50) NULL,
    [F4_504_Message] varchar(200) NULL,
    [FQ_526_AddMessage] varchar(200) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    [PayerCount] int NULL,
    CONSTRAINT [PK_rxqMedicareEligibility] PRIMARY KEY ([PatientId])
);
