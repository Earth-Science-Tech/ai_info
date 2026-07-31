-- rxqPatientPickupDisplayImages   (0 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPatientPickupDisplayImages] (
    [id] nvarchar(50) NOT NULL,
    [Image] varbinary(max) NULL,
    [ImageDescription] nvarchar(max) NULL,
    [Active] bit NULL,
    CONSTRAINT [PK_rxqPatientPickupDisplayImages] PRIMARY KEY ([id])
);
