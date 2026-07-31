-- rxqClinicalOppSetting   (0 rows, 15 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqClinicalOppSetting] (
    [cClinicalOppSettingId] varchar(50) NOT NULL,
    [Title] nvarchar(200) NULL,
    [Header] nvarchar(100) NULL,
    [CampaignType] int NULL,
    [ConversationGuide] nvarchar(max) NULL,
    [PharmacistRequired] nvarchar(15) NULL,
    [Filter] nvarchar(max) NULL,
    [CampaignData] nvarchar(max) NULL,
    [StoreNumber] nvarchar(50) NULL,
    [StartDate] date NULL,
    [EndDate] date NULL,
    [CampaignImageId] varchar(200) NULL,
    [FilterType] int NULL,
    [PopLocation] int NULL,
    [Status] int NULL,
    CONSTRAINT [PK_rxqClinicalOppSetting] PRIMARY KEY ([cClinicalOppSettingId])
);
