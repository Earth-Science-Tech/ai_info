-- rxqWorkCompPlan   (0 rows, 19 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqWorkCompPlan] (
    [cWorkCompPlanId] numeric(18,0) IDENTITY NOT NULL,
    [PatientId] varchar(50) NOT NULL,
    [InjuryDate] date NULL,
    [CustomerLastName] varchar(50) NULL,
    [CustomerFirstName] varchar(50) NULL,
    [WrkCmpAgencyId] varchar(50) NULL,
    [EmployerId] varchar(50) NULL,
    [LawyerId] varchar(50) NULL,
    [ClaimNumber] varchar(50) NULL,
    [OtherClaimNumber] varchar(50) NULL,
    [BillToFlag] varchar(50) NULL,
    [ValidThruDate] date NULL,
    [InjuryType] varchar(50) NULL,
    [Form] varchar(50) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    [CarrierId] varchar(50) NULL,
    [UsePatientPriceFormula] bit NULL,
    [Inactive] int NULL,
    CONSTRAINT [PK_rxqWorkCompPlan] PRIMARY KEY ([cWorkCompPlanId])
);

-- Indexes
CREATE INDEX [IX_WorkCompPlan_AgencyId] ON [dbo].[rxqWorkCompPlan] ([WrkCmpAgencyId]);
CREATE INDEX [IX_WorkCompPlan_EmployerId] ON [dbo].[rxqWorkCompPlan] ([EmployerId]);
CREATE INDEX [IX_WorkCompPlan_FamilyIdent] ON [dbo].[rxqWorkCompPlan] ([PatientId]);
