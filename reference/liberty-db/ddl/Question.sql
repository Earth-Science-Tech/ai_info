-- Question   (0 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[Question] (
    [Id] uniqueidentifier NOT NULL,
    [QuestionnaireId] uniqueidentifier NULL,
    [Type] int NULL,
    [Data] nvarchar(max) NULL,
    [Ordering] int NULL,
    [AppointmentItemId] uniqueidentifier NULL,
    CONSTRAINT [PK_Question] PRIMARY KEY ([Id])
);
