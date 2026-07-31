-- rxqSecurityGroup   (4 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqSecurityGroup] (
    [cSecurityGroupId] int IDENTITY NOT NULL,
    [Id] int NOT NULL,
    [Name] varchar(50) NULL,
    [Description] varchar(50) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    CONSTRAINT [PK_rxqSecurityGroup] PRIMARY KEY ([Id])
);
