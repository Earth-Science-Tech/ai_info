-- RxqRestrictionsMaster   (27 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[RxqRestrictionsMaster] (
    [RestrictionId] numeric(18,0) IDENTITY NOT NULL,
    [RestrictionName] varchar(50) NOT NULL,
    [Result] varchar(50) NOT NULL,
    [Message] varchar(800) NULL,
    [RestrictionType] int NULL,
    CONSTRAINT [PK_RxqRestrictionsMaster] PRIMARY KEY ([RestrictionId])
);
