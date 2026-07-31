-- rxqScheduleDrugReportHistory   (22,303 rows, 10 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqScheduleDrugReportHistory] (
    [Id] int IDENTITY NOT NULL,
    [State] varchar(50) NULL,
    [DateProcessed] datetime NULL,
    [DateStart] datetime NULL,
    [DateEnd] datetime NULL,
    [Submitted] bit NULL,
    [IsActive] bit NULL,
    [EntireFile] nvarchar(max) NULL,
    [StoreNumber] varchar(50) NULL,
    [IsZeroReport] bit NULL,
    CONSTRAINT [PK_rxqScheduleDrugReportHistory] PRIMARY KEY ([Id])
);

-- Indexes
CREATE INDEX [NonClusteredIndex-20180404-160424] ON [dbo].[rxqScheduleDrugReportHistory] ([State], [DateStart], [DateEnd]);
