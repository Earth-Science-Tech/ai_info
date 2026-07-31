-- Anchor   (351 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[Anchor] (
    [anc_table] nvarchar(128) NOT NULL,
    [anc_sent] bigint NULL,
    [anc_received] bigint NULL,
    [anc_server_applied] bigint NULL,
    [INITIAL_MAX_VALUE_REACHED] int NULL,
    [UPDATE_MAX_VALUE_REACHED] bigint NULL,
    [INSERT_MAX_VALUE_REACHED] bigint NULL,
    [InitialAnchor] bigint NULL,
    CONSTRAINT [PK_Anchor] PRIMARY KEY ([anc_table])
);
