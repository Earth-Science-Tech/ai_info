-- rxqAuditThirdPartyAccounting   (0 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAuditThirdPartyAccounting] (
    [Id] int IDENTITY NOT NULL,
    [AccountingRecord] varchar(max) NULL,
    [OriginalValue] decimal(10,2) NULL,
    [NewValue] decimal(10,2) NULL,
    [UserId] varchar(max) NULL,
    [AuditDate] datetime NULL,
    CONSTRAINT [PK_rxqAuditThirdPartyAccounting] PRIMARY KEY ([Id])
);
