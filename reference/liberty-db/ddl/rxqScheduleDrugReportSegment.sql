-- rxqScheduleDrugReportSegment   (68 rows, 12 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqScheduleDrugReportSegment] (
    [id] int IDENTITY NOT NULL,
    [ScheduleDrugReportSetupId] int NULL,
    [Name] varchar(50) NULL,
    [Segment] int NULL,
    [Position] int NULL,
    [Parent] int NULL,
    [Enabled] bit NULL,
    [Terminator] varchar(50) NULL,
    [FieldSeperator] varchar(50) NULL,
    [FieldCount] int NULL,
    [Description] varchar(50) NULL,
    [VisibilityFormula] varchar(max) NULL,
    CONSTRAINT [PK_rxqScheduleDrugReportSegment] PRIMARY KEY ([id])
);
