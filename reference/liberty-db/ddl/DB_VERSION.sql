-- DB_VERSION   (1 rows, 12 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[DB_VERSION] (
    [MajorVersion] char(5) NULL,
    [MinorVersion] char(5) NULL,
    [Build] char(5) NULL,
    [Revision] char(5) NULL,
    [OneOff] char(5) NULL,
    [DateInstalled] datetime NULL,
    [InstalledBy] varchar(50) NULL,
    [Description] varchar(255) NULL,
    [KillSwitch] bit NULL,
    [LastRestoreDate] datetime NULL,
    [LastGoodBackupDate] datetime NULL,
    [LastGoodBackupStatus] varchar(max) NULL
);
