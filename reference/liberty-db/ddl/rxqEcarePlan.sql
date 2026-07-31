-- rxqEcarePlan   (3 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqEcarePlan] (
    [PlanId] uniqueidentifier NOT NULL,
    [LastModified] datetime NOT NULL,
    [Status] varchar(50) NULL,
    [SentDate] datetime NULL,
    [SubmissionId] varchar(50) NULL,
    [PatientId] varchar(50) NOT NULL,
    [RphId] varchar(50) NOT NULL,
    [StoreNumber] varchar(50) NOT NULL,
    [Object] varchar(max) NOT NULL,
    CONSTRAINT [PK_rxqEcarePlan] PRIMARY KEY ([PlanId])
);
