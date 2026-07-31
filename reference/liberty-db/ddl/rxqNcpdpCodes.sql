-- rxqNcpdpCodes   (334 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqNcpdpCodes] (
    [CodeType] varchar(100) NOT NULL,
    [CodeKey] varchar(50) NOT NULL,
    [CodeName] varchar(500) NULL,
    [CodeFieldValueType] varchar(50) NULL,
    CONSTRAINT [PK_rxqNcpdpCodes] PRIMARY KEY ([CodeType], [CodeKey])
);
