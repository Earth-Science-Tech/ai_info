-- rxqInsuranceCardsImages   (0 rows, 14 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqInsuranceCardsImages] (
    [cInsuranceCardsImagesId] int IDENTITY NOT NULL,
    [PatientRx365Id] uniqueidentifier NULL,
    [ImageType] int NULL,
    [ImageName] nvarchar(200) NULL,
    [ImageData] varbinary(max) NULL,
    [ImageHash] nvarchar(400) NULL,
    [LastModified] datetime NULL,
    [CardFaceType] int NULL,
    [ImportStatusType] int NULL,
    [ImportDate] datetime NULL,
    [PatientId] varchar(50) NULL,
    [AgencyCode] varchar(50) NULL,
    [AgencySequence] int NULL,
    [PatientThirdPartyId] int NULL,
    CONSTRAINT [PK_rxqInsuranceCardsImages] PRIMARY KEY ([cInsuranceCardsImagesId])
);
