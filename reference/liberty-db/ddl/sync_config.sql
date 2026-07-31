-- sync_config   (2 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[sync_config] (
    [RecordId] numeric(18,0) IDENTITY NOT NULL,
    [DatabaseName] varchar(130) NULL,
    [ConnectionString] varchar(500) NULL,
    [ServiceURL] varchar(300) NULL,
    [IsValid] bit NULL,
    [IgnoreMAC] bit NULL
);
