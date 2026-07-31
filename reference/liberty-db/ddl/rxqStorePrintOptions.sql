-- rxqStorePrintOptions   (2 rows, 15 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqStorePrintOptions] (
    [cStorePrintId] int IDENTITY NOT NULL,
    [StoreNumber] varchar(50) NOT NULL,
    [WorkflowStage] varchar(50) NOT NULL,
    [PrntLabel] bit NULL,
    [PrntIPMReports] bit NULL,
    [CreatedDate] datetime NULL,
    [CreatedBy] varchar(50) NULL,
    [LastModifiedDate] datetime NULL,
    [LastModifiedBy] varchar(50) NULL,
    [IsValid] bit NULL,
    [Prompt] bit NULL,
    [PrntLabelRefill] bit NULL,
    [PrntIPMReportsRefill] bit NULL,
    [ChangeMode] int NULL,
    [CompoundFormulaWorksheetsWithLabel] bit NULL,
    CONSTRAINT [PK_rxqStorePrintOptions] PRIMARY KEY ([StoreNumber], [WorkflowStage])
);
