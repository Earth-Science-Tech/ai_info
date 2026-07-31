-- rxqAuditLogMaster   (6,249,384 rows, 33 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAuditLogMaster] (
    [id] int IDENTITY NOT NULL,
    [user_id] varchar(50) NOT NULL,
    [operation] smallint NOT NULL,
    [PatientId] varchar(50) NULL,
    [doctor_id] varchar(50) NULL,
    [drug_id] varchar(50) NULL,
    [summary] nvarchar(500) NULL,
    [modified_date] datetime NOT NULL,
    [WorkflowItemId] varchar(50) NULL,
    [StoreNumber] varchar(50) NULL,
    [PriceFormulaId] varchar(50) NULL,
    [OrderId] varchar(50) NULL,
    [SettingsId] varchar(200) NULL,
    [PendingScriptId] varchar(50) NULL,
    [cAddressId] varchar(50) NULL,
    [ShipmentId] varchar(50) NULL,
    [ShipmentScriptNumberId] varchar(50) NULL,
    [NotesId] varchar(255) NULL,
    [AgencyId] nvarchar(max) NULL,
    [BatchId] varchar(50) NULL,
    [CompoundIngredientId] varchar(50) NULL,
    [DrugCompoundPendingId] int NULL,
    [PatientAliasId] int NULL,
    [cPhoneNumberId] int NULL,
    [cPatientHipaaAcknowledgeId] int NULL,
    [cPatientThirdPartyId] int NULL,
    [cPatientPreferencesId] int NULL,
    [drugCompoundInstructionsID] int NULL,
    [cRX365PatientLinkId] int NULL,
    [PackageId] int NULL,
    [LtcMessageId] int NULL,
    [cVendorId] int NULL,
    [cNHPatId] int NULL,
    CONSTRAINT [PK_rxqAuditLogMaster] PRIMARY KEY ([id])
);

-- Indexes
CREATE INDEX [IX_AuditLogMaster_doctor_id_modified_date_storenumber] ON [dbo].[rxqAuditLogMaster] ([doctor_id], [modified_date], [StoreNumber]);
CREATE INDEX [IX_AuditLogMaster_drug_id_modified_date_storenumber] ON [dbo].[rxqAuditLogMaster] ([drug_id], [modified_date], [StoreNumber]);
CREATE INDEX [IX_AuditLogMaster_PatientId_modifieddate_StoreNumber] ON [dbo].[rxqAuditLogMaster] ([PatientId], [modified_date], [StoreNumber]);
CREATE INDEX [workflowIdIndexAuditLog] ON [dbo].[rxqAuditLogMaster] ([WorkflowItemId]);
