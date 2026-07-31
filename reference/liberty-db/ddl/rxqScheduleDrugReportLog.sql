-- rxqScheduleDrugReportLog   (12,094 rows, 10 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqScheduleDrugReportLog] (
    [id] nvarchar(50) NOT NULL,
    [ScriptNumber] int NULL,
    [RefillNumber] int NULL,
    [SendDate] datetime NULL,
    [SendType] int NULL,
    [State] nvarchar(50) NULL,
    [DateDispensed] datetime NULL,
    [HistoryId] int NULL,
    [ReportRecord] nvarchar(max) NULL,
    [PartialFillNumber] int NULL,
    CONSTRAINT [PK_rxqScheduleDrugReportLog] PRIMARY KEY ([id])
);

-- Indexes
CREATE INDEX [NonClusteredIndex-20180404-153810] ON [dbo].[rxqScheduleDrugReportLog] ([ScriptNumber], [RefillNumber], [State]);
