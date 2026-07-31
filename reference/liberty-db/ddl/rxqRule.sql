-- rxqRule   (0 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqRule] (
    [cRuleId] uniqueidentifier NOT NULL,
    [Name] varchar(100) NULL,
    [Significance] int NULL,
    [Category] varchar(100) NULL,
    [Description] varchar(max) NULL,
    [AlertOn] bit NULL,
    CONSTRAINT [PK_rxqRule] PRIMARY KEY ([cRuleId])
);
