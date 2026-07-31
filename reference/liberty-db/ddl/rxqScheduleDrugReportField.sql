-- rxqScheduleDrugReportField   (986 rows, 10 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqScheduleDrugReportField] (
    [id] int IDENTITY NOT NULL,
    [SegmentId] int NULL,
    [Position] int NULL,
    [Description] varchar(50) NULL,
    [Enabled] bit NULL,
    [Formula] varchar(max) NULL,
    [DefaultValue] varchar(50) NULL,
    [FormulaOptions] varchar(max) NULL,
    [UserEditable] bit NULL,
    [SelectedFormulaOption] int NULL,
    CONSTRAINT [PK_rxqScheduleDrugReportField] PRIMARY KEY ([id])
);
