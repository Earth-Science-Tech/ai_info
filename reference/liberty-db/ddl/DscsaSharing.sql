-- DscsaSharing   (0 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[DscsaSharing] (
    [ID] int IDENTITY NOT NULL,
    [Type] int NOT NULL,
    [Key] int NOT NULL,
    [DscsaProvider] varchar(50) NULL,
    [LastSent] datetime NULL,
    [Success] bit NULL,
    CONSTRAINT [PK_DscsaSharing] PRIMARY KEY ([ID])
);
