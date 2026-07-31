-- rxqFaxModems   (0 rows, 3 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqFaxModems] (
    [ShortName] varchar(50) NOT NULL,
    [LongName] varchar(50) NOT NULL,
    [id] int IDENTITY NOT NULL,
    CONSTRAINT [PK_rxqFaxModems] PRIMARY KEY ([id])
);
