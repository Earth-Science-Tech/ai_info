-- dsmPractice   (0 rows, 3 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[dsmPractice] (
    [PracticeId] int IDENTITY NOT NULL,
    [AccountId] varchar(225) NULL,
    [Name] varchar(100) NULL,
    CONSTRAINT [PK_dsmPractice] PRIMARY KEY ([PracticeId])
);
