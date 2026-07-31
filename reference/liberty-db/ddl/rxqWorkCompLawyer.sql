-- rxqWorkCompLawyer   (0 rows, 16 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqWorkCompLawyer] (
    [cWorkCompLawyerId] numeric(18,0) IDENTITY NOT NULL,
    [LawKey] varchar(50) NOT NULL,
    [Name] varchar(50) NULL,
    [Address] varchar(50) NULL,
    [Suite] varchar(50) NULL,
    [City] varchar(50) NULL,
    [State] varchar(50) NULL,
    [ZipCode] varchar(50) NULL,
    [ZipPlus] varchar(50) NULL,
    [Phone] varchar(50) NULL,
    [PhoneExtension] varchar(50) NULL,
    [Fax] varchar(50) NULL,
    [ContactName] varchar(50) NULL,
    [Comment] varchar(50) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    CONSTRAINT [PK_rxqWorkCompLawyer] PRIMARY KEY ([LawKey])
);
