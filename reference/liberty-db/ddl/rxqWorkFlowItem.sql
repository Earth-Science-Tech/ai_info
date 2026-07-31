-- rxqWorkFlowItem   (755 rows, 46 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqWorkFlowItem] (
    [cWorkFlowItemId] int IDENTITY NOT NULL,
    [SequenceNumber] int NOT NULL,
    [TaskCode] varchar(50) NULL,
    [StatusCode] varchar(50) NULL,
    [ScriptNumber] int NULL,
    [RefillNumber] int NULL,
    [PatientId] varchar(50) NULL,
    [Comments] varchar(max) NULL,
    [DeliveryMethod] varchar(50) NULL,
    [AddedByName] varchar(50) NULL,
    [AssignedToName] varchar(50) NULL,
    [CompletedByName] varchar(50) NULL,
    [Added] datetime NULL,
    [Due] datetime NULL,
    [Completed] datetime NULL,
    [Agency] varchar(50) NULL,
    [NursingHome] varchar(50) NULL,
    [OtcCost] float NULL,
    [PickupType] varchar(50) NULL,
    [CallDate] varchar(50) NULL,
    [CallTime] varchar(50) NULL,
    [PickupDate] datetime NULL,
    [PickupTimeType] varchar(50) NULL,
    [PayMethod] varchar(50) NULL,
    [CallbackNumber] varchar(50) NULL,
    [Notes] varchar(50) NULL,
    [eScriptTransactionId] int NULL,
    [FaxDoctorId] varchar(50) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    [cQueueId] int NULL,
    [ActivityStarted] bit NULL,
    [DeleteNotes] varchar(200) NULL,
    [DueTimeType] varchar(50) NULL,
    [ReferenceId] varchar(50) NULL,
    [RequestType] int NULL,
    [Confirmed] int NULL,
    [StoreNumber] varchar(2) NULL,
    [CycleType] int NOT NULL,
    [AppointmentId] uniqueidentifier NULL,
    [GuestPatientFirstName] nvarchar(max) NULL,
    [GuestPatientLastName] nvarchar(max) NULL,
    [GuestPatientDOB] datetime NULL,
    [PatientWaiting] bit NULL,
    [AppointmentDoctorId] varchar(50) NULL,
    [AppointmentDrugId] varchar(50) NULL,
    CONSTRAINT [PK_rxqWorkFlowItem] PRIMARY KEY ([SequenceNumber])
);

-- Indexes
CREATE INDEX [IDX_rxqWorkflowItem_TaskCode_Due] ON [dbo].[rxqWorkFlowItem] ([TaskCode], [Due]) INCLUDE ([StatusCode], [ScriptNumber]);
CREATE INDEX [IX_WF_Completed_IsValid_Due_TaskCode] ON [dbo].[rxqWorkFlowItem] ([Completed], [IsValid], [Due], [TaskCode]);
CREATE INDEX [IX_WF_DueDate] ON [dbo].[rxqWorkFlowItem] ([Due]);
CREATE INDEX [IX_WF_ScriptNumber] ON [dbo].[rxqWorkFlowItem] ([ScriptNumber]);
CREATE INDEX [IX_WF_status] ON [dbo].[rxqWorkFlowItem] ([StatusCode]);
CREATE INDEX [IX_WF_task] ON [dbo].[rxqWorkFlowItem] ([TaskCode]);
CREATE INDEX [NonClusteredIndex-20171227-130600] ON [dbo].[rxqWorkFlowItem] ([Added], [ActivityStarted]);
CREATE INDEX [WorkFlowItem_FamilyId] ON [dbo].[rxqWorkFlowItem] ([PatientId]);
