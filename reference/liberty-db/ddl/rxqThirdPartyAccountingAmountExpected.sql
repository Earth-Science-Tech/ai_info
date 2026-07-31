-- rxqThirdPartyAccountingAmountExpected   (0 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqThirdPartyAccountingAmountExpected] (
    [ScriptNumber] nvarchar(50) NOT NULL,
    [RefillNumber] nvarchar(50) NOT NULL,
    [ClaimType] varchar(50) NOT NULL,
    [IsMFP] bit NOT NULL,
    [EditValue] decimal(10,2) NULL,
    CONSTRAINT [PK_rxqThirdPartyAccountingAmountExpected] PRIMARY KEY ([ScriptNumber], [RefillNumber], [ClaimType], [IsMFP])
);
