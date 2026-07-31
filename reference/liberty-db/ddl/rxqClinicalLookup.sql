-- rxqClinicalLookup   (150,445 rows, 2 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqClinicalLookup] (
    [NdcNumber] varchar(50) NOT NULL,
    [Hazardous] bit NULL,
    CONSTRAINT [PK_rxqClinicalLookup] PRIMARY KEY ([NdcNumber])
);
