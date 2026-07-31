-- rxqAuditTracking   (227,864 rows, 10 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAuditTracking] (
    [id] int IDENTITY NOT NULL,
    [itemId] nvarchar(15) NULL,
    [originalValue] nvarchar(max) NULL,
    [newValue] nvarchar(max) NULL,
    [origin] nvarchar(max) NULL,
    [dateChanged] datetime NULL,
    [trackingType] int NULL,
    [userInfo] nvarchar(max) NULL,
    [description] nvarchar(max) NULL,
    [originId] int NULL,
    CONSTRAINT [PK_rxqAuditTracking] PRIMARY KEY ([id])
);

-- Indexes
CREATE INDEX [dateChanged] ON [dbo].[rxqAuditTracking] ([dateChanged]);
CREATE INDEX [itemId] ON [dbo].[rxqAuditTracking] ([itemId]);
CREATE INDEX [NonClusteredIndex-originId] ON [dbo].[rxqAuditTracking] ([originId]);
CREATE INDEX [trackingType] ON [dbo].[rxqAuditTracking] ([trackingType]);
