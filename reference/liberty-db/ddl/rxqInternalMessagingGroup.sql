-- rxqInternalMessagingGroup   (2 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqInternalMessagingGroup] (
    [cInternalMessagingGroupId] int IDENTITY NOT NULL,
    [GroupUser] varchar(400) NULL,
    [AllUsers] varchar(max) NULL,
    [Pinned] bit NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqInternalMessagingGroup] PRIMARY KEY ([cInternalMessagingGroupId])
);
