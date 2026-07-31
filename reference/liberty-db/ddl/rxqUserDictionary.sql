-- rxqUserDictionary   (0 rows, 2 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqUserDictionary] (
    [cUserDictionaryId] int IDENTITY NOT NULL,
    [Word] varchar(200) NULL,
    CONSTRAINT [PK_rxqUserDictionary] PRIMARY KEY ([cUserDictionaryId])
);
