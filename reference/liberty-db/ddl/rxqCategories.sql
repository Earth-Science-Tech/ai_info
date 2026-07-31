-- rxqCategories   (19 rows, 10 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqCategories] (
    [cCategoryId] int IDENTITY NOT NULL,
    [CategoryName] varchar(50) NULL,
    [Type] varchar(50) NULL,
    [Color] int NULL,
    [Active] bit NOT NULL,
    [Source] int NULL,
    [Sequence] int NULL,
    [System] bit NULL,
    [RtsSellWarning] bit NULL,
    [RtsDefaultType] int NULL,
    CONSTRAINT [PK_rxqCategories] PRIMARY KEY ([cCategoryId])
);
