-- rxqImageControl   (754,142 rows, 11 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqImageControl] (
    [cImageControlId] int IDENTITY NOT NULL,
    [ImageKeyType] char(1) NOT NULL,
    [ImageKey] varchar(200) NOT NULL,
    [Description] varchar(200) NULL,
    [ScanDate] datetime NULL,
    [FileName] varchar(200) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    [Directory] varchar(200) NULL,
    [Annotations] varchar(max) NULL,
    [DocumentCategory] nvarchar(30) NULL,
    CONSTRAINT [PK_rxqImageControl] PRIMARY KEY ([ImageKeyType], [ImageKey])
);

-- Indexes
CREATE INDEX [IX_cImageControl] ON [dbo].[rxqImageControl] ([ImageKeyType]);
CREATE INDEX [IX_cImageControl_1] ON [dbo].[rxqImageControl] ([ImageKey]);
