-- RxqLabCategories   (10 rows, 2 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[RxqLabCategories] (
    [CatId] int IDENTITY NOT NULL,
    [Category] varchar(50) NULL,
    CONSTRAINT [PK_RxqLabCategories] PRIMARY KEY ([CatId])
);
