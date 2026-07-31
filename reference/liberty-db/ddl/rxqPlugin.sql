-- rxqPlugin   (0 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPlugin] (
    [PluginId] varchar(50) NOT NULL,
    [Location] varchar(200) NOT NULL,
    [DllName] varchar(200) NOT NULL,
    [AssemblyName] varchar(200) NOT NULL,
    [ClassName] varchar(200) NOT NULL,
    [Enabled] bit NOT NULL,
    [DateInstalled] datetime NOT NULL,
    [InterfaceVersion] varchar(50) NOT NULL,
    [IsUninstalled] bit NOT NULL,
    CONSTRAINT [PK_rxqPlugin] PRIMARY KEY ([PluginId])
);
