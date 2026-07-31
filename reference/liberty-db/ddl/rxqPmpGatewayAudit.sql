-- rxqPmpGatewayAudit   (3,148 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPmpGatewayAudit] (
    [Id] bigint IDENTITY NOT NULL,
    [StoreNumber] varchar(2) NOT NULL,
    [Datestamp] datetime NOT NULL,
    [UserId] varchar(50) NOT NULL,
    [Mode] varchar(50) NOT NULL,
    [PatientId] varchar(50) NOT NULL,
    [ScriptNumber] int NULL,
    [RefillNumber] int NULL,
    [Pharmacist] varchar(50) NULL,
    CONSTRAINT [PK_rxqPmpGatewayAudit] PRIMARY KEY ([Id])
);

-- Indexes
CREATE INDEX [_dta_index_rxqPmpGatewayAudit_195_791673868__K7_K8_K3D] ON [dbo].[rxqPmpGatewayAudit] ([ScriptNumber], [RefillNumber], [Datestamp]);
CREATE INDEX [IX_rxqPmpGateway_ScriptFillDate] ON [dbo].[rxqPmpGatewayAudit] ([Datestamp], [ScriptNumber], [RefillNumber]);
