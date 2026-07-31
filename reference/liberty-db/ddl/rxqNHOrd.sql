-- rxqNHOrd   (0 rows, 18 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqNHOrd] (
    [cNHOrdId] int IDENTITY NOT NULL,
    [RawData] varchar(50) NULL,
    [m_keyvalue] varchar(50) NOT NULL,
    [Prefix] varchar(50) NOT NULL,
    [Suffix] varchar(50) NOT NULL,
    [OrderLine1] varchar(100) NULL,
    [OrderLine2] varchar(100) NULL,
    [OrderLine3] varchar(100) NULL,
    [OrderLine4] varchar(100) NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    [OrderLine5] varchar(100) NULL,
    [OrderLine6] varchar(100) NULL,
    [OrderLine7] varchar(100) NULL,
    [OrderLine8] varchar(100) NULL,
    [DefaultOrder] bit NULL,
    [TreatmentSchedule] varchar(50) NULL,
    [DefaultOrderStation] varchar(50) NULL,
    CONSTRAINT [PK_rxqNHOrd] PRIMARY KEY ([m_keyvalue], [Prefix], [Suffix])
);
