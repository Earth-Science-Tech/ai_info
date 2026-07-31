-- rxqAgencyGroup   (0 rows, 2 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAgencyGroup] (
    [GroupId] varchar(50) NOT NULL,
    [AgencyId] varchar(50) NOT NULL,
    CONSTRAINT [PK_rxqAgencyGroup] PRIMARY KEY ([GroupId], [AgencyId])
);
