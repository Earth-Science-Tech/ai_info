-- rxqSettings   (955 rows, 3 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqSettings] (
    [SettingKey] varchar(200) NOT NULL,
    [UserId] varchar(50) NOT NULL,
    [Setting] varchar(max) NULL,
    CONSTRAINT [PK_rxqSettings] PRIMARY KEY ([SettingKey], [UserId])
);
