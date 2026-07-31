-- rxqRxAlertReadyWorkflowLocationSettings   (0 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqRxAlertReadyWorkflowLocationSettings] (
    [SettingId] int IDENTITY NOT NULL,
    [StoreNumber] varchar(6) NULL,
    [IncludeChildren] bit NULL,
    [WorkflowLocationId] int NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqRxAlertReadyWorkflowLocationSettings] PRIMARY KEY ([SettingId])
);
