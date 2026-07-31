-- QuestionnaireReview   (0 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[QuestionnaireReview] (
    [Id] uniqueidentifier NOT NULL,
    [ScriptNumber] int NOT NULL,
    [RefillNumber] int NOT NULL,
    [ReviewedDate] datetime NULL,
    [ReviewedBy] varchar(50) NULL,
    [QuestionnaireId] uniqueidentifier NULL,
    [QuestionnaireName] nvarchar(200) NULL,
    [AppointmentBookingId] uniqueidentifier NULL,
    CONSTRAINT [PK_QuestionnaireReview] PRIMARY KEY ([Id])
);
