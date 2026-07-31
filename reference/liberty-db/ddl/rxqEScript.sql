-- rxqEScript   (103,753 rows, 19 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
-- NOTE: mirrored into liberty_link_stage by the eMed ETL.
CREATE TABLE [dbo].[rxqEScript] (
    [cEScriptId] int IDENTITY NOT NULL,
    [eScriptId] int NOT NULL,
    [ScriptNumber] int NULL,
    [CreatedYYYYMMDD] varchar(50) NULL,
    [CreatedHHMMSS] varchar(50) NULL,
    [XmlData] text NULL,
    [MINREC_LEN] int NULL,
    [MAXREC_LEN] int NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    [LibertyMessageNumber] int NOT NULL,
    [LibertySignature] text NULL,
    [AlertSent] varchar(1) NULL,
    [RxReferenceNumber] varchar(max) NULL,
    [MessageId] varchar(50) NULL,
    [PatientId] varchar(50) NULL,
    [eScriptCreated] datetime NULL,
    [Source] int NULL,
    [RefillRequestReferenceNumber] varchar(100) NULL,
    CONSTRAINT [PK_rxqEScript] PRIMARY KEY ([eScriptId])
);

-- Indexes
CREATE INDEX [IX_rxqEScript_LibertyMessageNumber] ON [dbo].[rxqEScript] ([LibertyMessageNumber]);
