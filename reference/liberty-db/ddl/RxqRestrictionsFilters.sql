-- RxqRestrictionsFilters   (29 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[RxqRestrictionsFilters] (
    [RestrictionId] numeric(18,0) NOT NULL,
    [RestrictionClass] varchar(50) NOT NULL,
    [RestrictionProperty] varchar(50) NOT NULL,
    [RestrictionPropertyType] varchar(50) NULL,
    [RestrictionOperationFilter] varchar(50) NOT NULL,
    [RestrictionValue] varchar(600) NOT NULL,
    CONSTRAINT [PK_RxqRestrictionsFilters] PRIMARY KEY ([RestrictionId], [RestrictionClass], [RestrictionProperty], [RestrictionOperationFilter], [RestrictionValue])
);
