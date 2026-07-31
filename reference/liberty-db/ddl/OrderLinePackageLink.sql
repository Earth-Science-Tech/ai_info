-- OrderLinePackageLink   (0 rows, 2 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[OrderLinePackageLink] (
    [OrderLineId] int NOT NULL,
    [PackageId] int NOT NULL,
    CONSTRAINT [PK_OrderLinePackageLink] PRIMARY KEY ([OrderLineId], [PackageId])
);
