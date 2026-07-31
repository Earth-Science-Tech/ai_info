-- rxqVideoConference   (0 rows, 10 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqVideoConference] (
    [id] nvarchar(50) NOT NULL,
    [RoomSid] nvarchar(max) NULL,
    [RoomName] nvarchar(max) NULL,
    [StoreNumber] nvarchar(50) NULL,
    [RequestedBy] nvarchar(50) NULL,
    [CreatedOn] datetime NULL,
    [Answered] bit NULL,
    [PatientId] nvarchar(50) NULL,
    [Invoice] nvarchar(7) NULL,
    [ItemList] nvarchar(max) NULL,
    CONSTRAINT [PK_rxqVideoConference] PRIMARY KEY ([id])
);
