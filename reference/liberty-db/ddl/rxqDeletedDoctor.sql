-- rxqDeletedDoctor   (0 rows, 3 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDeletedDoctor] (
    [deletedDoctorID] int IDENTITY NOT NULL,
    [doctorXML] xml NOT NULL,
    [datetimeCreated] datetime NOT NULL,
    CONSTRAINT [PK_rxqDeletedDoctor] PRIMARY KEY ([deletedDoctorID])
);
