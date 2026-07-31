-- rxqCycleFillAuthorization   (0 rows, 6 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqCycleFillAuthorization] (
    [CycleFillAuthorizationId] int IDENTITY NOT NULL,
    [ScriptNumber] int NOT NULL,
    [CycleType] int NOT NULL,
    [Response] int NOT NULL,
    [User] varchar(25) NOT NULL,
    [ResponseDate] datetime NOT NULL,
    CONSTRAINT [PK_rxqCycleFillAuthorization] PRIMARY KEY ([CycleFillAuthorizationId])
);
