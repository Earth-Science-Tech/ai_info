-- rxqEscriptResponse   (738 rows, 2 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqEscriptResponse] (
    [ResponseEscriptId] int NOT NULL,
    [RequestEscriptId] int NOT NULL,
    CONSTRAINT [PK_rxqEscriptResponse] PRIMARY KEY ([ResponseEscriptId])
);
