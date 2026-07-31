-- rxqAppointmentsResources   (172 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqAppointmentsResources] (
    [UniqueID] int IDENTITY NOT NULL,
    [ResourceID] int NOT NULL,
    [ResourceName] nvarchar(50) NULL,
    [Color] int NULL,
    [Image] image NULL,
    [CustomField1] nvarchar(max) NULL,
    CONSTRAINT [PK_rxqAppointmentsResources] PRIMARY KEY ([UniqueID])
);
