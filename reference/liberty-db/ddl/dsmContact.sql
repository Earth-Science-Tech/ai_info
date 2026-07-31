-- dsmContact   (0 rows, 12 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[dsmContact] (
    [ContactId] int IDENTITY NOT NULL,
    [eMail] varchar(200) NULL,
    [Gender] varchar(200) NULL,
    [Note] varchar(200) NULL,
    [Phone] varchar(200) NULL,
    [DOB] date NULL,
    [FirstName] varchar(200) NULL,
    [LastName] varchar(200) NULL,
    [Address] varchar(200) NULL,
    [City] varchar(200) NULL,
    [State] varchar(200) NULL,
    [Zip] varchar(200) NULL,
    CONSTRAINT [PK_dsmContact] PRIMARY KEY ([ContactId])
);
