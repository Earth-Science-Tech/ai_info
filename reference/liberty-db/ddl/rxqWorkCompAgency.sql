-- rxqWorkCompAgency   (0 rows, 20 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqWorkCompAgency] (
    [cWorkCompAgencyId] numeric(18,0) IDENTITY NOT NULL,
    [AgencyId] varchar(50) NOT NULL,
    [Name] varchar(50) NULL,
    [Address] varchar(50) NULL,
    [Suite] varchar(50) NULL,
    [City] varchar(50) NULL,
    [State] varchar(50) NULL,
    [Zip] varchar(50) NULL,
    [ZipPlus] varchar(50) NULL,
    [Phone] varchar(50) NULL,
    [PhoneExt] varchar(50) NULL,
    [Fax] varchar(50) NULL,
    [Contact] varchar(50) NULL,
    [Comment] varchar(50) NULL,
    [ClaimCount] int NULL,
    [ScriptCount] int NULL,
    [UnpaidAmount] float NULL,
    [PIN] varchar(50) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    CONSTRAINT [PK_rxqWorkCompAgency] PRIMARY KEY ([AgencyId])
);
