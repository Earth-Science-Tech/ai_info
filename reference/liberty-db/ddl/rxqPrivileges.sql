-- rxqPrivileges   (1,148 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPrivileges] (
    [cPrivilegesId] int IDENTITY NOT NULL,
    [Type] varchar(50) NOT NULL,
    [Entity] varchar(50) NOT NULL,
    [PrivilegeId] int NOT NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    CONSTRAINT [PK_rxqPrivileges] PRIMARY KEY ([Type], [Entity], [PrivilegeId])
);
