-- rxqDirection   (3,575 rows, 14 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDirection] (
    [cDirectionId] int IDENTITY NOT NULL,
    [KeyType] varchar(50) NOT NULL,
    [Language] varchar(50) NOT NULL,
    [KeyCode] varchar(50) NOT NULL,
    [Text] nvarchar(500) NULL,
    [City] varchar(50) NULL,
    [Zip] varchar(50) NULL,
    [LinkKeyType] varchar(50) NULL,
    [LinkLanguage] varchar(50) NULL,
    [LinkKeyCode] varchar(50) NULL,
    [LinkCount] int NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    [IconIndex] int NULL,
    CONSTRAINT [PK_rxqDirection] PRIMARY KEY ([KeyType], [Language], [KeyCode])
);

-- Indexes
CREATE INDEX [_dta_index_rxqDirection_195_789577851__K3_K2_K4_5] ON [dbo].[rxqDirection] ([Language], [KeyType], [KeyCode]) INCLUDE ([Text]);
