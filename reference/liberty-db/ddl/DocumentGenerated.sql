-- DocumentGenerated   (0 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[DocumentGenerated] (
    [ID] int IDENTITY NOT NULL,
    [Type] int NOT NULL,
    [Name] varchar(200) NOT NULL,
    [DateTimeGenerated] datetime NULL,
    [UserId] varchar(50) NOT NULL,
    [Method] int NOT NULL,
    [KeyType] int NOT NULL,
    [KeyValue] varchar(200) NOT NULL,
    CONSTRAINT [PK_DocumentGenerated] PRIMARY KEY ([ID])
);
