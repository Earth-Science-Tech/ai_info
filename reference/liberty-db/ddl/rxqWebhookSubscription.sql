-- rxqWebhookSubscription   (12 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqWebhookSubscription] (
    [StoreNumber] varchar(50) NOT NULL,
    [ApiUser] varchar(50) NOT NULL,
    [Event] varchar(50) NOT NULL,
    [IsActive] bit NOT NULL,
    [PostUri] varchar(255) NOT NULL,
    [PostApiKey] varchar(255) NOT NULL,
    [DateCreated] datetime NOT NULL,
    [DateLastModified] datetime NOT NULL,
    CONSTRAINT [PK_rxqWebhookSubscription] PRIMARY KEY ([StoreNumber], [ApiUser], [Event])
);
