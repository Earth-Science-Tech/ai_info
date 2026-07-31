-- PriorAuthorizationRequests   (0 rows, 11 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[PriorAuthorizationRequests] (
    [ID] int IDENTITY NOT NULL,
    [ScriptNumber] int NOT NULL,
    [Method] int NULL,
    [Status] int NULL,
    [FirstRequest] datetime NULL,
    [History] varchar(max) NULL,
    [StoreNumber] varchar(2) NULL,
    [Completed] bit NOT NULL,
    [AgencyCode] varchar(50) NULL,
    [LastRequest] datetime NULL,
    [OnlineHistoryId] int NULL,
    CONSTRAINT [PK_PriorAuthorizationRequests] PRIMARY KEY ([ID])
);

-- Indexes
CREATE INDEX [IX_PriorAuthorizationRequests_FirstRequest] ON [dbo].[PriorAuthorizationRequests] ([FirstRequest]);
