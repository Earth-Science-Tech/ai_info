-- rxqMFP   (141 rows, 7 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqMFP] (
    [MfpId] int IDENTITY NOT NULL,
    [NDC] varchar(50) NULL,
    [MfpEffectiveDate] date NULL,
    [MfpEndDate] date NULL,
    [ContainerMfpPrice] decimal(10,2) NULL,
    [MfpLastUpdated] date NULL,
    [UnitMfpPrice] decimal(10,2) NULL,
    CONSTRAINT [PK_rxqMFP] PRIMARY KEY ([MfpId])
);
