-- rxqSavedAuxiliaryLabels   (50 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqSavedAuxiliaryLabels] (
    [SavedAuxiliaryLabelId] int IDENTITY NOT NULL,
    [Text] nvarchar(max) NULL,
    [QuickCode] nvarchar(8) NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqSavedAuxiliaryLabels] PRIMARY KEY ([SavedAuxiliaryLabelId])
);
