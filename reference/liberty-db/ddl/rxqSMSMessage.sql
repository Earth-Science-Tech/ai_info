-- rxqSMSMessage   (50 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqSMSMessage] (
    [Id] int IDENTITY NOT NULL,
    [PatientId] varchar(50) NULL,
    [IncomingOutgoing] char(10) NULL,
    [ViewedFlag] bit NULL,
    [DateTimeCreated] datetime NULL,
    [MessageText] varchar(500) NULL,
    [Number] varchar(50) NULL,
    [SentBy] varchar(50) NULL,
    [MessageID] int NULL,
    CONSTRAINT [PK_rxqSMSMessage] PRIMARY KEY ([Id])
);

-- Indexes
CREATE INDEX [IX_DateTimeCreated] ON [dbo].[rxqSMSMessage] ([DateTimeCreated]);
CREATE INDEX [IX_FamilyId] ON [dbo].[rxqSMSMessage] ([PatientId]);
CREATE INDEX [IX_MessageID] ON [dbo].[rxqSMSMessage] ([MessageID]);
