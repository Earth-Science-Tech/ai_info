-- rxqPatientRanking   (9 rows, 8 columns)
-- Source: RXQRXCOMPOUNDSTORE (Liberty). Read-only reference DDL, synthesized from catalog metadata.
CREATE TABLE [dbo].[rxqPatientRanking] (
    [cPatientRankingId] int IDENTITY NOT NULL,
    [RankType] int NULL,
    [Rank] int NULL,
    [Name] varchar(50) NULL,
    [Image] int NULL,
    [High] int NULL,
    [Low] int NULL,
    [LastModified] datetime NULL,
    CONSTRAINT [PK_rxqPatientRanking] PRIMARY KEY ([cPatientRankingId])
);

-- Indexes
CREATE UNIQUE INDEX [IX_rxqPatientRanking] ON [dbo].[rxqPatientRanking] ([RankType], [Rank]);
