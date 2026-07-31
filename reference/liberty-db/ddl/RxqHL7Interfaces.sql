-- RxqHL7Interfaces   (0 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[RxqHL7Interfaces] (
    [InterfaceId] int IDENTITY NOT NULL,
    [InterfaceName] varchar(200) NOT NULL,
    [IPAddress] varchar(50) NULL,
    [IPPort] int NULL,
    [Enabled] bit NULL,
    [LastModified] datetime NULL,
    [IsValid] bit NULL,
    [SendNewAtVerify] bit NULL,
    [ShowMultipleTQs] bit NULL,
    CONSTRAINT [PK_RxqHL7Interfaces] PRIMARY KEY ([InterfaceId])
);
