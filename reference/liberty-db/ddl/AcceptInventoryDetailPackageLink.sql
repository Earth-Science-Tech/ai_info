-- AcceptInventoryDetailPackageLink   (0 rows, 2 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[AcceptInventoryDetailPackageLink] (
    [AcceptInventoryDetailId] int NOT NULL,
    [PackageId] int NOT NULL,
    CONSTRAINT [PK_AcceptInventoryDetailPackageLink] PRIMARY KEY ([AcceptInventoryDetailId], [PackageId])
);

-- Indexes
CREATE INDEX [idx_AcceptInventoryDetailPackageLink_PackageId] ON [dbo].[AcceptInventoryDetailPackageLink] ([PackageId]);
