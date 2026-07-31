-- rxqClinicalOppAnswerHistory   (0 rows, 4 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqClinicalOppAnswerHistory] (
    [Id] nvarchar(200) NOT NULL,
    [cClinicalOppAnswerId] nvarchar(200) NOT NULL,
    [DateAsked] datetime NOT NULL,
    [AnswerType] int NOT NULL,
    CONSTRAINT [PK_rxqClinicalOppAnswerHistory] PRIMARY KEY ([Id])
);
