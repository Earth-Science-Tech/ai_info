-- rxqCouponDrug   (0 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqCouponDrug] (
    [id] nvarchar(50) NOT NULL,
    [CouponEntryId] nvarchar(50) NULL,
    [NdcNumber] nvarchar(50) NULL,
    [DrugName] nvarchar(50) NULL,
    CONSTRAINT [PK_rxqCouponDrug] PRIMARY KEY ([id])
);

-- Indexes
CREATE INDEX [entryIdIndex] ON [dbo].[rxqCouponDrug] ([CouponEntryId]);
CREATE INDEX [ndcIndex] ON [dbo].[rxqCouponDrug] ([NdcNumber]);
