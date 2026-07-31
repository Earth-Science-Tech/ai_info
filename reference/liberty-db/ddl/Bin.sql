-- Bin   (6 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[Bin] (
    [Id] int IDENTITY NOT NULL,
    [DisplayValue] varchar(50) NOT NULL,
    [ShortCode] varchar(3) NULL,
    [MaxRxs] int NULL,
    [Type] int NOT NULL,
    [StoreNumber] varchar(50) NOT NULL,
    CONSTRAINT [PK_Bin] PRIMARY KEY ([Id])
);
