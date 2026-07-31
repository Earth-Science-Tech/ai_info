-- rxqScheduleDrugReportNDC   (7 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqScheduleDrugReportNDC] (
    [Id] int IDENTITY NOT NULL,
    [NDC] nvarchar(11) NOT NULL,
    [LookupType] int NULL,
    [State] varchar(20) NULL,
    [TemplateType] int NULL,
    [ParticipationType] int NULL,
    CONSTRAINT [PK_rxqScheduleDrugReportNDC] PRIMARY KEY ([Id])
);
