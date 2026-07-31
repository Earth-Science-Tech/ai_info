-- ScriptTransactionPackageLink   (5 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[ScriptTransactionPackageLink] (
    [ScriptNumber] int NOT NULL,
    [RefillNumber] int NOT NULL,
    [PackageId] int NOT NULL,
    [DateLinked] datetime NULL,
    CONSTRAINT [PK_ScriptTransactionPackageLink] PRIMARY KEY ([ScriptNumber], [RefillNumber], [PackageId])
);

-- Indexes
CREATE INDEX [idx_ScriptTransactionPackageLink_DateLinked] ON [dbo].[ScriptTransactionPackageLink] ([DateLinked]);
