-- rxqDataViewLayout   (77 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDataViewLayout] (
    [cDataViewLayoutId] int IDENTITY NOT NULL,
    [ViewName] varchar(50) NULL,
    [Layout] varchar(max) NULL,
    [IsValid] bit NULL,
    [DataViewType] int NULL,
    [IconIndex] int NULL,
    CONSTRAINT [PK_rxqDataViewLayout] PRIMARY KEY ([cDataViewLayoutId])
);
