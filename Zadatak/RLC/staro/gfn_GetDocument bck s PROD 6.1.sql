USE [NOVA_PROD]
GO
/****** Object:  UserDefinedFunction [dbo].[gfn_GetDocument]    Script Date: 14.2.2019. 11:42:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------------------------------------------------------------------------------
-- Function return current record from dbo.dokument or latest record from dbo.arh_dokument.
--
-- History:
-- 05.06.2017 Jure; BUG 33182 - Created
------------------------------------------------------------------------------------------------------------

ALTER FUNCTION [dbo].[gfn_GetDocument]
(
	@id_dokum int
)  
RETURNS @result table
(
	ID_CONT int null,
	ID_OBL_ZAV char(2),
	ID_ZAPO char(7),
	OPIS1 varchar(4000),
	OPIS char(50),
	VREDNOST decimal(18,2),
	OPOMBE varchar(2000),
	POTREBNO bit,
	IMA bit,
	DAT_1OP datetime null,
	DAT_2OP datetime null,
	DAT_3OP datetime null,
	STEVILKA char(30),
	ID_TEC char(3) null,
	KOLICINA decimal(18,2),
	ST_NALEPKE char(10),
	DAT_OBV datetime null,
	DATUM_DOK datetime,
	ID_KUPCA char(6) null,
	REG_STEV char(50)
)
AS
BEGIN 
	
	insert into @result
	select 
		ID_CONT,
		ID_OBL_ZAV,
		ID_ZAPO,
		OPIS1,
		OPIS,
		VREDNOST,
		OPOMBE,
		POTREBNO,
		IMA,
		DAT_1OP,
		DAT_2OP,
		DAT_3OP,
		STEVILKA,
		ID_TEC,
		KOLICINA,
		ST_NALEPKE,
		DAT_OBV,
		DATUM_DOK,
		ID_KUPCA,
		REG_STEV
	from
		dbo.DOKUMENT
	where
		ID_DOKUM = @id_dokum

	if @@ROWCOUNT = 1
		return

	insert into @result
	select 
		top 1
		ID_CONT,
		ID_OBL_ZAV,
		ID_ZAPO,
		OPIS1,
		OPIS,
		VREDNOST,
		OPOMBE,
		POTREBNO,
		IMA,
		DAT_1OP,
		DAT_2OP,
		DAT_3OP,
		STEVILKA,
		ID_TEC,
		KOLICINA,
		ST_NALEPKE,
		DAT_OBV,
		DATUM_DOK,
		ID_KUPCA,
		REG_STEV
	from
		dbo.ARH_dokument
	where
		ID_DOKUM = @id_dokum and
		ACTION = 'D' -- vzamemo zadnji veljaven dokument v primeru, da smo dokument brisali
	
RETURN 
END

