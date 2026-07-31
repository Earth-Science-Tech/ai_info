-- rxqInterfaceSubmission   (0 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqInterfaceSubmission] (
    [id] int IDENTITY NOT NULL,
    [ScriptNumber] int NOT NULL,
    [RefillNumber] int NOT NULL,
    [InterfaceName] varchar(100) NOT NULL,
    [SubmitDatetime] datetime NOT NULL,
    CONSTRAINT [PK_rxqInterfaceSubmission] PRIMARY KEY ([id])
);
