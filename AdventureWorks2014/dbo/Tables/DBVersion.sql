CREATE TABLE [dbo].[DBVersion](
	[DBV_ref] [int] IDENTITY(1,1) NOT NULL,
	[DBV_previousversion] [varchar](50) CONSTRAINT [D_DBVersion$DBV_previousversion] DEFAULT ('') NULL,
	[DBV_currentversion] [varchar](50)  NOT NULL,
	[DBV_date] [datetime] CONSTRAINT [D_DBVersion$DBV_date]  DEFAULT (getdate()) NOT NULL,
	[DBV_octopusreleaseno] [varchar](10) CONSTRAINT [D_DBVersion$DBV_octopusreleaseno] DEFAULT ('') NOT NULL, 
    CONSTRAINT [PK_DBVersion$DBV_ref] PRIMARY KEY NONCLUSTERED ([DBV_ref] ASC) 
);