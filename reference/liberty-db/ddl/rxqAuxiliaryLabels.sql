-- rxqAuxiliaryLabels   (3,741 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAuxiliaryLabels] (
    [AuxiliaryLabelId] int IDENTITY NOT NULL,
    [LabelType] int NULL,
    [DrugId] varchar(50) NULL,
    [MedispanId] varchar(256) NULL,
    [ScriptNumber] int NULL,
    [RefillNumber] int NULL,
    [LabelPosition] int NULL,
    [Text] nvarchar(max) NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqAuxiliaryLabels] PRIMARY KEY ([AuxiliaryLabelId])
);
