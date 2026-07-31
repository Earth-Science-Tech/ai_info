-- rxqQueue   (16 rows, 9 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
-- NOTE: mirrored into liberty_link_stage by the eMed ETL.
CREATE TABLE [dbo].[rxqQueue] (
    [cQueueId] int IDENTITY NOT NULL,
    [QueueName] varchar(50) NULL,
    [DisplayOrder] int NULL,
    [PriorityOrder] int NULL,
    [Color] int NULL,
    [Delivery] bit NOT NULL,
    [DeliveryCharge] decimal(9,2) NULL,
    [CustomerDefault] bit NOT NULL,
    [IsValid] bit NOT NULL,
    CONSTRAINT [PK_rxqQueue] PRIMARY KEY ([cQueueId])
);
