-- PrescriptionRequestEscripts   (26 rows, 3 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[PrescriptionRequestEscripts] (
    [MessageId] char(32) NOT NULL,
    [PrescriptionRequestId] int NOT NULL,
    [eScriptId] int NOT NULL,
    CONSTRAINT [PK_PrescriptionRequestEscripts] PRIMARY KEY ([MessageId])
);
