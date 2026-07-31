-- rxqMTMOutcomesUsers   (0 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqMTMOutcomesUsers] (
    [id] nvarchar(50) NOT NULL,
    [Description] nvarchar(max) NULL,
    [UserId] nvarchar(50) NULL,
    [RxqUserRecordId] nvarchar(50) NULL,
    [Type] int NULL,
    [MTMType] int NULL,
    [FirstName] nvarchar(max) NULL,
    [MiddleName] nvarchar(max) NULL,
    [LastName] nvarchar(max) NULL,
    CONSTRAINT [PK_rxqMTMOutcomesUsers] PRIMARY KEY ([id])
);
