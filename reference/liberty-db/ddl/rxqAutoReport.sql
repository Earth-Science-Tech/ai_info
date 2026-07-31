-- rxqAutoReport   (3 rows, 10 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAutoReport] (
    [cAutoReport] int IDENTITY NOT NULL,
    [StoreNumber] varchar(50) NULL,
    [Type] int NULL,
    [Template] varchar(max) NULL,
    [Filter] varchar(max) NULL,
    [Schedule] varchar(max) NULL,
    [Options] varchar(max) NULL,
    [LastDateRun] datetime NULL,
    [LastModified] datetime NULL,
    [Active] bit NULL,
    CONSTRAINT [PK_rxqAutoReport] PRIMARY KEY ([cAutoReport])
);
