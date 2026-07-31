-- CentralFillService   (0 rows, 19 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[CentralFillService] (
    [Id] int IDENTITY NOT NULL,
    [Role] int NOT NULL,
    [TransmissionStage] int NOT NULL,
    [Name] varchar(50) NOT NULL,
    [WorkflowReentry] int NOT NULL,
    [ServiceFeeType] int NOT NULL,
    [ServiceFee] decimal(18,2) NULL,
    [VendorId] int NOT NULL,
    [Active] bit NOT NULL,
    [ConnectionDetails] varchar(max) NOT NULL,
    [StoreNumber] varchar(50) NULL,
    [LastOrderNumber] int NOT NULL,
    [CutoffMinorWarningMessage] varchar(50) NULL,
    [CutoffMajorWarningMessage] varchar(50) NULL,
    [CutoffMissedMessage] varchar(50) NULL,
    [DisplayServiceFee] bit NOT NULL,
    [PromiseTimeSchedulingBuffer] bigint NULL,
    [CutoffMinorWarningLeadTime] bigint NULL,
    [CutoffMajorWarningLeadTime] bigint NULL,
    CONSTRAINT [PK_CentralFillService] PRIMARY KEY ([Id])
);
