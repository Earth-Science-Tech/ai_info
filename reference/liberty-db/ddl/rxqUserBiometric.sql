-- rxqUserBiometric   (0 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqUserBiometric] (
    [cUserId] int IDENTITY NOT NULL,
    [RecordId] varchar(50) NULL,
    [BiometricType] int NULL,
    [Data] varchar(8000) NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqUserBiometric] PRIMARY KEY ([cUserId])
);
