-- rxqNHMedSheetReportDefaultOrdering   (0 rows, 3 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqNHMedSheetReportDefaultOrdering] (
    [DefaultStandingOrderId] varchar(50) NOT NULL,
    [PatientId] varchar(50) NOT NULL,
    [ReportOrderIndex] int NOT NULL,
    CONSTRAINT [PK_rxqNHMedSheetReportDefaultOrdering] PRIMARY KEY ([PatientId], [DefaultStandingOrderId])
);
