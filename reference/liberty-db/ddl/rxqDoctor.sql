-- rxqDoctor   (3,191 rows, 44 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
-- NOTE: mirrored into liberty_link_stage by the eMed ETL.
CREATE TABLE [dbo].[rxqDoctor] (
    [cDoctorId] int IDENTITY NOT NULL,
    [DoctorId] varchar(50) NOT NULL,
    [LastName] varchar(50) NULL,
    [FirstName] varchar(50) NULL,
    [MiddleInit] varchar(50) NULL,
    [DeaNumber] varchar(50) NULL,
    [StateNumber] varchar(50) NULL,
    [HIN] varchar(50) NULL,
    [UPIN] varchar(50) NULL,
    [Other] varchar(50) NULL,
    [Street] varchar(50) NULL,
    [City] varchar(50) NULL,
    [State] varchar(50) NULL,
    [Zip] varchar(50) NULL,
    [ZipPlus] varchar(50) NULL,
    [Phone] varchar(50) NULL,
    [AlternatePhone] varchar(50) NULL,
    [NPI] varchar(50) NULL,
    [LocationCode] varchar(50) NULL,
    [DeaSuffix] varchar(50) NULL,
    [Fax] varchar(50) NULL,
    [Contact] varchar(50) NULL,
    [Specialty] varchar(50) NULL,
    [SubDrug] varchar(50) NULL,
    [NewRx] int NULL,
    [RxCount] int NULL,
    [LastDate] date NULL,
    [Title] varchar(50) NULL,
    [SPI] varchar(50) NULL,
    [SureScriptServiceLevelCode] int NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    [PhoneType] char(2) NULL,
    [AlternatePhoneType] char(2) NULL,
    [ClinicName] varchar(50) NULL,
    [CustomField1] varchar(50) NULL,
    [CustomField2] varchar(50) NULL,
    [CustomField3] varchar(50) NULL,
    [CustomField4] varchar(50) NULL,
    [SupervisingPhysicianID] varchar(50) NULL,
    [InActive] bit NULL,
    [Suite] varchar(50) NULL,
    [Is340B] bit NULL,
    [XDeaNumber] varchar(50) NULL,
    CONSTRAINT [PK_rxqDoctor] PRIMARY KEY ([DoctorId])
);

-- Indexes
CREATE INDEX [IX_cDoctor] ON [dbo].[rxqDoctor] ([FirstName]);
CREATE INDEX [IX_cDoctor_1] ON [dbo].[rxqDoctor] ([LastName]);
CREATE INDEX [IX_GPI] ON [dbo].[rxqDoctor] ([NPI]);
