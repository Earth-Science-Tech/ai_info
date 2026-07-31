-- rxqRX365PendingPatient   (0 rows, 20 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqRX365PendingPatient] (
    [Id] int NOT NULL,
    [FirstName] nvarchar(200) NOT NULL,
    [LastName] nvarchar(200) NOT NULL,
    [DateOfBirth] date NOT NULL,
    [Gender] varchar(1) NULL,
    [Email] nvarchar(500) NOT NULL,
    [NotificationPreference] int NOT NULL,
    [MobilePhone] varchar(50) NOT NULL,
    [StreetAddress] varchar(50) NOT NULL,
    [City] varchar(50) NOT NULL,
    [State] varchar(50) NOT NULL,
    [Zip] varchar(50) NOT NULL,
    [InsuranceCardBackImage] varbinary(max) NULL,
    [InsuranceCardFrontImage] varbinary(max) NULL,
    [ApprovalStatus] int NOT NULL,
    [LastModified] datetime NOT NULL,
    [StoreNumber] varchar(50) NOT NULL,
    [RequestDate] datetime NOT NULL,
    [DateCompleted] datetime NULL,
    [Rx365ID] uniqueidentifier NOT NULL,
    CONSTRAINT [PK_rxqRX365PendingPatient] PRIMARY KEY ([Id])
);
