-- rxqScriptReconcile   (1 rows, 16 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqScriptReconcile] (
    [Id] nvarchar(50) NOT NULL,
    [ScriptNumber] int NOT NULL,
    [RefillNumber] int NOT NULL,
    [PaymentNumber] int NOT NULL,
    [Agency] nvarchar(50) NULL,
    [DatePmtApplied] datetime NULL,
    [Amount] decimal(9,2) NULL,
    [Description] nvarchar(50) NULL,
    [CheckNumber] nvarchar(50) NULL,
    [IsPrimary] bit NULL,
    [IsValid] bit NULL,
    [Fee] decimal(9,2) NULL,
    [GeneralItem] bit NULL,
    [AuthorizationNumber] nvarchar(50) NULL,
    [MFPPayment] int NULL,
    [PatientThirdPartyId] int NULL,
    CONSTRAINT [PK_rxqScriptReconcile] PRIMARY KEY ([Id])
);

-- Indexes
CREATE INDEX [Agency] ON [dbo].[rxqScriptReconcile] ([Agency]);
CREATE INDEX [Script] ON [dbo].[rxqScriptReconcile] ([ScriptNumber]);
