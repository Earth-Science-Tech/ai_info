-- rxqRxAlertCustomSettings   (10 rows, 10 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqRxAlertCustomSettings] (
    [CustomAlertTemplateId] nvarchar(50) NOT NULL,
    [CustomAlertDescription] nvarchar(max) NULL,
    [CustomAlertActivated] bit NULL,
    [CustomAlertEmailMessage] nvarchar(max) NULL,
    [CustomAlertEmailSubject] nvarchar(max) NULL,
    [CustomAlertTextMessage] nvarchar(max) NULL,
    [CustomAlertVoiceMessage] nvarchar(max) NULL,
    [CustomAlertTimeSpanValue] bigint NULL,
    [CustomAlertWorkflowAction] nvarchar(50) NULL,
    [StoreNumber] varchar(3) NULL,
    CONSTRAINT [PK_rxqRxAlertCustomSettings] PRIMARY KEY ([CustomAlertTemplateId])
);
