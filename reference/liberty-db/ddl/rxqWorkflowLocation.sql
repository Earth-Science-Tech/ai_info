-- rxqWorkflowLocation   (26 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
-- NOTE: mirrored into liberty_link_stage by the eMed ETL.
CREATE TABLE [dbo].[rxqWorkflowLocation] (
    [cWorkflowLocationId] int IDENTITY NOT NULL,
    [Location] varchar(50) NULL,
    [ParentWorkflowLocationId] int NULL,
    [ShowInDropdown] bit NULL,
    [Intervention] bit NULL,
    CONSTRAINT [PK_rxqWorkflowLocation] PRIMARY KEY ([cWorkflowLocationId])
);
