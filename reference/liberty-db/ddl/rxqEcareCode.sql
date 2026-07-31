-- rxqEcareCode   (333 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqEcareCode] (
    [SystemId] char(1) NOT NULL,
    [Code] varchar(50) NOT NULL,
    [Type] int NOT NULL,
    [Category] varchar(50) NULL,
    [Description] varchar(100) NULL,
    [Order] int NOT NULL,
    CONSTRAINT [PK_rxqEcareCode] PRIMARY KEY ([SystemId], [Code], [Type])
);
