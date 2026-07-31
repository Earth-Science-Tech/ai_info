-- dsmUser   (0 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[dsmUser] (
    [UserId] int IDENTITY NOT NULL,
    [UpDoxUserId] varchar(255) NULL,
    [UpDoxAccountId] varchar(255) NULL,
    [UpDoxLoginId] varchar(255) NULL,
    [UpDoxFirstName] varchar(255) NULL,
    [UpDoxLastName] varchar(255) NULL,
    [UpDoxDirectAddress] varchar(255) NULL,
    CONSTRAINT [PK_dsmUser] PRIMARY KEY ([UserId])
);
