-- GerGroup   (0 rows, 3 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[GerGroup] (
    [Id] int IDENTITY NOT NULL,
    [Name] varchar(50) NOT NULL,
    [Percentage] decimal(9,2) NOT NULL,
    CONSTRAINT [PK_GerGroup] PRIMARY KEY ([Id])
);
