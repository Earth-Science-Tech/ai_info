-- rxqUserRoles   (149 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqUserRoles] (
    [cUserRolesId] int IDENTITY NOT NULL,
    [RecordId] varchar(50) NOT NULL,
    [UserRoleType] int NOT NULL,
    [Initials] varchar(50) NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqUserRoles] PRIMARY KEY ([RecordId], [UserRoleType])
);
