-- ReportFilterTemplates   (0 rows, 3 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[ReportFilterTemplates] (
    [TemplateName] varchar(255) NOT NULL,
    [ReportCategory] varchar(50) NOT NULL,
    [FilterOptions] varchar(max) NOT NULL,
    CONSTRAINT [PK_ReportFilterTemplates] PRIMARY KEY ([TemplateName], [ReportCategory])
);
