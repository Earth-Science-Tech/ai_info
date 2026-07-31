-- rxqCentralInterface   (20 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqCentralInterface] (
    [id] nvarchar(50) NOT NULL,
    [StoreNumber] nvarchar(50) NOT NULL,
    [Name] nvarchar(max) NULL,
    [Logo] nvarchar(max) NULL,
    [Enabled] bit NULL,
    [LastRan] datetime NULL,
    [Description] nvarchar(max) NULL,
    [Version] int NULL,
    CONSTRAINT [PK_rxqCentralInterface] PRIMARY KEY ([id], [StoreNumber])
);
