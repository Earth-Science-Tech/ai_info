-- rxqDUR   (0 rows, 11 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDUR] (
    [cDurID] int IDENTITY NOT NULL,
    [ScriptNumber] int NOT NULL,
    [RefillNumber] int NOT NULL,
    [Ins_Type] int NOT NULL,
    [SequenceNumber] int NOT NULL,
    [ReasonForService] varchar(500) NOT NULL,
    [ProfessionalServiceCode] varchar(500) NULL,
    [ResultCode] varchar(500) NULL,
    [LevelOfEffort] varchar(500) NULL,
    [CoAgentQualifier] varchar(500) NULL,
    [CoAgencyId] varchar(50) NULL,
    CONSTRAINT [PK_rxqDUR] PRIMARY KEY ([ScriptNumber], [RefillNumber], [Ins_Type], [SequenceNumber])
);
