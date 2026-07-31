-- rxqScaleSetup   (7 rows, 14 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqScaleSetup] (
    [cScaleSetupId] int IDENTITY NOT NULL,
    [Comport] varchar(max) NULL,
    [BaudRate] int NULL,
    [DataBits] int NULL,
    [Parity] int NULL,
    [StopBits] int NULL,
    [Handshake] int NULL,
    [PrintCode] varchar(max) NULL,
    [TareCode] varchar(max) NULL,
    [TerminateKey] varchar(max) NULL,
    [SplitIndicator] varchar(max) NULL,
    [WeightPosition] int NULL,
    [UOMPosition] int NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqScaleSetup] PRIMARY KEY ([cScaleSetupId])
);
