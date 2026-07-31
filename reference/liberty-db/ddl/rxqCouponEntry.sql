-- rxqCouponEntry   (0 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqCouponEntry] (
    [id] nvarchar(50) NOT NULL,
    [Name] nvarchar(50) NULL,
    [Description] nvarchar(50) NULL,
    [PCNOverride] nvarchar(50) NULL,
    [GroupOverride] nvarchar(50) NULL,
    [MemberIdOverride] nvarchar(50) NULL,
    [AgencyCode] nvarchar(50) NULL,
    [AvailableMemberIds] nvarchar(max) NULL,
    CONSTRAINT [PK_rxqCouponEntry] PRIMARY KEY ([id])
);
