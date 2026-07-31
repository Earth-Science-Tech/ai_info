-- rxqAutoReportAudit   (4,576 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAutoReportAudit] (
    [cAutoReportAudit] int IDENTITY NOT NULL,
    [cAutoReport] int NULL,
    [DateRun] datetime NULL,
    [RunStatus] int NULL,
    [Error] varchar(max) NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqAutoReportAudit] PRIMARY KEY ([cAutoReportAudit])
);
