-- rxqOrder   (0 rows, 21 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqOrder] (
    [cOrderId] int IDENTITY NOT NULL,
    [DateCreated] datetime NULL,
    [DateSent] datetime NULL,
    [DateConfirmed] datetime NULL,
    [DateUpdated] datetime NULL,
    [DateLastChanged] datetime NULL,
    [Status] nvarchar(50) NULL,
    [VendorId] int NULL,
    [Name] nvarchar(50) NULL,
    [FileName] nvarchar(max) NULL,
    [IncludeRXQ] bit NULL,
    [IncludeBZQ] bit NULL,
    [ConfirmationFile] nvarchar(max) NULL,
    [StoreNumber] nvarchar(50) NULL,
    [Active] bit NULL,
    [DateReceived] datetime NULL,
    [OrderType] int NULL,
    [OrderInventoryUpdate] int NULL,
    [OrderOrigin] int NULL,
    [ExistingOrderReferenceId] int NULL,
    [LinkOrderId] int NULL,
    CONSTRAINT [PK_rxqOrder] PRIMARY KEY ([cOrderId])
);

-- Indexes
CREATE INDEX [DateCreated] ON [dbo].[rxqOrder] ([DateCreated]);
