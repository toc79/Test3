USE [Nova_hls]
GO
/****** Object:  StoredProcedure [dbo].[grp_CloseContractTermView]    Script Date: 8.6.2016. 12:13:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
------------------------------------------------------------
-- Procedure: prepares all bookings for given list of contracts by contract closing
--
-- History:
-- 13.02.2007 Darko; created
-- 04.08.2013 Jost; Task ID 7502 - left join on 'dbo.projects'
-- 28.10.2013 Jelena; MID 42804 - added calculation for advance
-- 25.11.2013 Jelena; MID 42804 - modified calculation for advance
------------------------------------------------------------
ALTER                      PROCEDURE [dbo].[grp_CloseContractTermView] 
@session_id_enabled int,
@session_id varchar(38),
@id_conts_enabled int,
@id_conts varchar(8000)
AS
BEGIN

DECLARE @strm_tbl table (id_cont int)
DECLARE @strm_tmp varchar(8000)
DECLARE @strm_v varchar(8000)
DECLARE @delimiter char(1)
SET @delimiter = ','
SET @strm_tmp = @id_conts + @delimiter

WHILE charindex(@delimiter, @strm_tmp) > 0
BEGIN
	SET @strm_v = substring(@strm_tmp, 1, charindex(@delimiter, @strm_tmp) -1 )
	INSERT INTO @strm_tbl (id_cont) VALUES (cast (@strm_v as int))
	SET @strm_tmp = SUBSTRING(@strm_tmp,CHARINDEX(@Delimiter,@strm_tmp)+1,8000) 
END

SELECT top 100 percent  a.*,
			b.id_pog, b.nacin_leas, b.pred_naj, b.varscina, b.id_tec as id_tec_vars, b.id_val as id_val_vars,
			c.naz_kr_kup, cast(0 as numeric(18,2)) as avans 
INTO #result
FROM 
(

(
    SELECT 
        konto, id_kupca, datum_dok, vrsta_dok, debit_dom, kredit_dom, st_dok, debit_val, 
        kredit_val, id_val, id_tec, tecaj, opisdok, dur, valuta, obdobje, veza, id_strm, id_plac,  
        3 as kdo, ts, id_dogodka, storno, a.id_cont , p.ProjectNumber as ProjectNumber, p.ProjectName as ProjectName
    FROM dbo.lsk a
	 inner join @strm_tbl b on a.id_cont = b.id_cont
	 left join dbo.projects p on p.id_project = a.id_project
)
UNION 
(
    SELECT 
        konto, id_kupca, datum_dok, vrsta_dok, debit_dom, kredit_dom, st_dok, debit_val,
        kredit_val, id_val, id_tec, tecaj, opisdok, dur, valuta, obdobje, veza, id_strm, id_plac, 
		(case when ts in ( 
			select ts from dbo.ku_dnev_tmp 
			where 
                session_id = @session_id and 
                konto in (
                    dbo.gfn_vrnikontoNL('#KIZRODH', nacin_leas),
                    dbo.gfn_vrnikontoNL('#KIZRPRI', nacin_leas),
                    dbo.gfn_vrnikontoNL('#IZRPRIH', nacin_leas)
                ) 
		) then 1 else 2 end) as kdo, 
        ts, id_dogodka, storno, id_cont ,p.ProjectNumber as P1, p.ProjectName as P2
    FROM dbo.ku_dnev_tmp kt
    left join dbo.projects p on p.id_project = kt.id_project
    where kt.session_id = @session_id)
) a 
inner join dbo.pogodba b on a.id_cont = b.id_cont
inner join dbo.partner c on b.id_kupca = c.id_kupca
order by a.id_cont, a.kdo

--- Calculate varscina and advance (avans)

DECLARE @id_cont int
DECLARE @id_tec_new char(3)
DECLARE @id_tec char(3)
DECLARE @id_kupca char(6)
DECLARE @advance decimal(18,2)


DECLARE temp_crs CURSOR FORWARD_ONLY FOR SELECT DISTINCT id_cont, id_kupca FROM #result
OPEN temp_crs

FETCH NEXT FROM temp_crs INTO @id_cont, @id_kupca
WHILE @@fetch_status = 0
BEGIN

	--Calculate varscina
	SET @id_tec = (SELECT id_tec FROM dbo.pogodba WHERE id_cont = @id_cont)
	SET @id_tec_new = (SELECT id_tec_new FROM dbo.tecajnic WHERE id_tec = @id_tec)
	IF @id_tec_new is not null
		SET @id_tec = @id_tec_new
	IF @id_tec != @id_tec_new
		BEGIN
			update #result set id_val_vars = 'EUR' where id_cont = @id_cont
			update #result set varscina = dbo.gfn_xchange(@id_tec,
				(select varscina from #result where id_cont = @id_cont),
				@id_tec,getdate()) where id_cont = @id_cont
		END
	
	--Calculate advanse (avans)	
	SET @advance = (select dbo.gfn_Advance_OnlyByContract(@id_cont))
	IF @advance != 0
		BEGIN
			update #result set avans = @advance where id_cont = @id_cont
		END
		
	FETCH NEXT FROM temp_crs INTO @id_cont, @id_kupca
END

CLOSE temp_crs
DEALLOCATE temp_crs

select * from #result order by id_pog

drop table #result

END
