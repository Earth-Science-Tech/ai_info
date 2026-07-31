-- rxqPhoneNumber   (358,479 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPhoneNumber] (
    [cPhoneNumberId] int IDENTITY NOT NULL,
    [LookUpId] varchar(200) NULL,
    [PhoneNumberType] int NULL,
    [PhoneNumber] varchar(50) NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqPhoneNumber] PRIMARY KEY ([cPhoneNumberId])
);

-- Indexes
CREATE INDEX [LibertyAuto_15_14_rxqPhoneNumber] ON [dbo].[rxqPhoneNumber] ([LookUpId]);
