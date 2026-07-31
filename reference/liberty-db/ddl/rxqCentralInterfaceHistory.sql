-- rxqCentralInterfaceHistory   (0 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqCentralInterfaceHistory] (
    [Id] int IDENTITY NOT NULL,
    [StoreNumber] varchar(2) NOT NULL,
    [TaskTypeId] varchar(2) NOT NULL,
    [Datestamp] datetime NOT NULL,
    [Event] varchar(50) NOT NULL,
    [User] varchar(50) NOT NULL,
    CONSTRAINT [PK_rxqCentralInterfaceHistory] PRIMARY KEY ([Id])
);
