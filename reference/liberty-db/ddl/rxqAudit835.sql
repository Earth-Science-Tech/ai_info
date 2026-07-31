-- rxqAudit835   (0 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAudit835] (
    [cAudit835Id] nvarchar(50) NOT NULL,
    [Action] int NULL,
    [FileName] varchar(900) NULL,
    [FileUpload] datetime NULL,
    [LoggedUser] varchar(50) NULL,
    [StoreNumber] varchar(50) NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqAudit835] PRIMARY KEY ([cAudit835Id])
);
