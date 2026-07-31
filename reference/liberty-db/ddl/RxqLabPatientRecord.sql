-- RxqLabPatientRecord   (1,737 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[RxqLabPatientRecord] (
    [LabId] int IDENTITY NOT NULL,
    [TypeId] int NOT NULL,
    [PatientId] varchar(50) NOT NULL,
    [LabValue] decimal(18,3) NOT NULL,
    [LabDate] date NOT NULL,
    [AddedBy] varchar(200) NULL,
    CONSTRAINT [PK_RxqLabPatientRecord] PRIMARY KEY ([LabId])
);
