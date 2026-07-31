-- rxqDrugCompoundInstructions   (853 rows, 5 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqDrugCompoundInstructions] (
    [drugCompoundInstructionsID] int IDENTITY NOT NULL,
    [instructions] text NOT NULL,
    [compoundDrugID] varchar(50) NOT NULL,
    [createdDate] datetime NOT NULL,
    [lastModifiedDate] datetime NOT NULL,
    CONSTRAINT [PK_rxqDrugCompoundInstructions] PRIMARY KEY ([drugCompoundInstructionsID])
);
