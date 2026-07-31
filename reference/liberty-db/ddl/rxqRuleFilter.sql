-- rxqRuleFilter   (0 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqRuleFilter] (
    [cFilterId] uniqueidentifier NOT NULL,
    [cRuleId] varchar(max) NOT NULL,
    [Condition] varchar(max) NULL,
    [Type] varchar(max) NULL,
    [Range] varchar(max) NULL,
    [Operation] varchar(10) NULL,
    [Result] int NULL,
    [SimpleResult] bit NULL,
    CONSTRAINT [PK_rxqRuleFilter] PRIMARY KEY ([cFilterId])
);
