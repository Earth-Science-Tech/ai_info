-- rxqWorkCompEmployer   (0 rows, 23 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqWorkCompEmployer] (
    [cWorkCompEmployerId] numeric(18,0) IDENTITY NOT NULL,
    [Id] varchar(50) NULL,
    [Name] varchar(50) NULL,
    [Address] varchar(50) NULL,
    [Suite] varchar(50) NULL,
    [County] varchar(50) NULL,
    [City] varchar(50) NULL,
    [State] varchar(50) NULL,
    [Zip] varchar(50) NULL,
    [ZipPlus] varchar(50) NULL,
    [Phone] varchar(50) NULL,
    [PhoneExtension] varchar(50) NULL,
    [Fax] varchar(50) NULL,
    [Contact] varchar(50) NULL,
    [Comment] varchar(50) NULL,
    [BrandPriceFormulaCode] varchar(50) NULL,
    [GenericPriceFormulaCode] varchar(50) NULL,
    [AgencyId] varchar(50) NULL,
    [ClaimCount] int NULL,
    [ScriptCount] int NULL,
    [UnpaidClaimDollars] float NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    CONSTRAINT [PK_rxqWorkCompEmployer] PRIMARY KEY ([cWorkCompEmployerId])
);

-- Indexes
CREATE UNIQUE INDEX [IX_rxqWorkCompEmployer_Id] ON [dbo].[rxqWorkCompEmployer] ([Id]);
CREATE INDEX [IX_rxqWorkCompEmployer_Name] ON [dbo].[rxqWorkCompEmployer] ([Name]);
CREATE INDEX [IX_WorkCompEmployer_Agency] ON [dbo].[rxqWorkCompEmployer] ([AgencyId]);
