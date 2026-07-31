-- rxqEScriptResponseTime   (2 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqEScriptResponseTime] (
    [cEScriptResponseTimeId] int IDENTITY NOT NULL,
    [LookUpId] varchar(50) NULL,
    [LookUpType] int NULL,
    [Responses] int NULL,
    [AverageMinutes] int NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqEScriptResponseTime] PRIMARY KEY ([cEScriptResponseTimeId])
);
