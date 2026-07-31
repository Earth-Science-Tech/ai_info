-- rxqALAAC   (0 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqALAAC] (
    [Id] int IDENTITY NOT NULL,
    [NDC] varchar(50) NULL,
    [DrugName] varchar(100) NULL,
    [BG] varchar(50) NULL,
    [EffectiveDate] date NULL,
    [AAC] decimal(10,5) NULL,
    CONSTRAINT [PK_rxqALAAC] PRIMARY KEY ([Id])
);
