-- UserPermissions   (0 rows, 3 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[UserPermissions] (
    [Id] int IDENTITY NOT NULL,
    [GlobalUserId] uniqueidentifier NOT NULL,
    [PrivilegeId] int NOT NULL,
    CONSTRAINT [PK_UserPermissions] PRIMARY KEY ([Id])
);
