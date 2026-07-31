-- rxqSecurityBadge   (0 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqSecurityBadge] (
    [UserId] int NOT NULL,
    [BadgeNumber] int NULL,
    [UpdatedAt] datetime NULL,
    [ExpiresAfter] datetime NULL,
    CONSTRAINT [PK_rxqSecurityBadge] PRIMARY KEY ([UserId])
);

-- Indexes
CREATE UNIQUE INDEX [BadgeNumberUnique] ON [dbo].[rxqSecurityBadge] ([BadgeNumber]);
