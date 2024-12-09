--USE [Nova_hls]
--GO
/****** Object:  StoredProcedure [dbo].[grp_stat_01_DistributionOfClaims]    Script Date: 3.1.2017. 12:14:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------------------------------------------------------------------------------
-- Function for getting data for statistic report : Distribution of claims
-- group by: date, week, month, kvart
--
-- History:
-- 03.08.2006 Vilko; added parameters @par_kategorija_enabled and @par_kategorija_kategorija
-- 27.12.2006 Jasna; Maintenance ID 5601 - added @par_akt_enabled,@par_akt_akttype and @par_akt_akt
-- 28.04.2010 Jasna; Maintenance ID 24941 - added parameters  @par_vr_osebe_value and @par_opremavrsta_opremavrsta 
-- 28.04.2010 Jasna; delete previous changes 
-- 27.11.2013 Uros; Mid 41935 - added parameter @par_obdobje_polje, added field datum_dok
-- 31.07.2014 Uros; Task 8165 - created from gfn_stat_01_DistributionOfClaims
-- 18.09.2014 Ales; Task id 8165 - fixed some bugs
-- 03.06.2015 Jure; TASK 8680 - Added support for OOBR claims
-- 17.05.2016 Domen; TaskID 8250 - Rewriting back to static code
-- 03.01.2017 g_tomislav; GMC Mid 37133 - fixed on site; fixing ORDER BY a.mesec
------------------------------------------------------------------------------------------------------------

ALTER PROCEDURE [dbo].[grp_stat_01_DistributionOfClaims]
(
@par_tecajnica_enabled int,
@par_tecajnica_tecajnica char(3), -- Exchange rate ID
@par_tecajnica_datumtec char(8),  -- today -- ales from datetime to char(8)
@par_tecajnica_valuta char(3), 
@par_nacinleas_enabled int, 
@par_nacinleas_nacinleas varchar(8000), 
@par_obdobje_enabled int,
@par_obdobje_datumod char(8), -- beginning period date -- today -- ales from datetime to char(8)
@par_obdobje_datumdo char(8), --end period date -- today -- ales from datetime to char(8)
@par_obdobje_polje int, --=1 - date of document, =2 - date of overdue
@par_aktiviranodatum_enabled int,
@par_aktiviranodatum_aktiviranodatum char(8), -- consider contracts activate till -- ales from datetime to char(8)
@par_aneks_enabled int,
@par_aneks_anekstype int,
@par_aneks_anekses varchar(8000), 
@par_tipterjatev_enabled int,
@par_tipterjatev_tipterjatve int, -- =1 - all debts, =2 - only leasing installment, =3 - only leasing installment without option
@par_grouping_enabled int,
@par_grouping_grouping int, -- group by year, (day,week,month,kvart)
@par_strm_enabled int,
@par_strm_strm varchar(8000), --@niz_strm
@par_kategorija_enabled int,
@par_kategorija_kategorija varchar(8000),
@par_akt_enabled int,
@par_akt_akttype int,
@par_akt_akt varchar(8000)
)
WITH RECOMPILE AS

---------- declare variable @niz_ter depending on @par_tipterjatev_tipterjatve , @niz_ter1 --------------------------------------------
DECLARE  @niz_ter varchar(1000), @niz_ter1 varchar(1000)
IF @par_tipterjatev_tipterjatve = 2 
	SET @niz_Ter = (SELECT id_terj FROM dbo.vrst_ter WHERE sif_terj in ('POLO')) + ','+  (SELECT id_terj FROM dbo.vrst_ter WHERE sif_terj in ('LOBR')) + ',' +   (SELECT id_terj FROM dbo.vrst_ter WHERE sif_terj in ('DDV')) + ',' +  (SELECT id_terj FROM dbo.vrst_ter WHERE sif_terj in ('OPC')) + ',' +  (SELECT id_terj FROM dbo.vrst_ter WHERE sif_terj in ('OOBR')) 
ELSE IF @par_tipterjatev_tipterjatve  = 3
	SET @niz_Ter = (SELECT id_terj FROM dbo.vrst_ter WHERE sif_terj in ('POLO')) + ','+  (SELECT id_terj FROM dbo.vrst_ter WHERE sif_terj in ('LOBR')) + ','  +  (SELECT id_terj FROM dbo.vrst_ter WHERE sif_terj in ('DDV'))
	
SET @niz_Ter1 = (SELECT id_terj FROM dbo.vrst_ter WHERE sif_terj in ('POLO')) + ','+  (SELECT id_terj FROM dbo.vrst_ter WHERE sif_terj in ('LOBR')) + ',' +  (SELECT id_terj FROM dbo.vrst_ter WHERE sif_terj in ('OPC')) + ',' +  (SELECT id_terj FROM dbo.vrst_ter WHERE sif_terj in ('DDV')) + ',' +  (SELECT id_terj FROM dbo.vrst_ter WHERE sif_terj in ('OOBR')) 


SELECT
	a.*
INTO #table1
FROM (

SELECT		CASE when @par_grouping_grouping = 1 then a.dat END as datum,
			CASE when @par_grouping_grouping = 2 then datepart(wk,a.dat) END as teden,
			CASE when @par_grouping_grouping = 3 then month(a.dat) END as mesec,
			CASE when @par_grouping_grouping = 4 then dbo.gfn_kvartal(a.dat) END as kvart,
			year(a.dat) as leto,
			count(*) AS st_terj,
			sum(xa.znesek) AS debit,
			sum(xb.znesek) AS neto,
			sum(xc.znesek) AS obresti,
			sum(xd.znesek) AS robresti,
			sum(xe.znesek) AS marza,
			sum(xf.znesek) AS regist,
			sum(CASE WHEN (c.fakt_zac <> '' and b.pred_ddv = 0 and charindex(a.id_terj,@niz_ter1) > 0 and b.dobrocno = 1)
				    THEN 0 
				    ELSE (xg.znesek) END) AS davek,
			sum(CASE WHEN (c.fakt_zac <> '' and b.pred_ddv = 0 and charindex(a.id_terj,@niz_ter1) > 0 and b.dobrocno = 1) 
				    THEN (xg.znesek)
				    ELSE 0 END) AS fin_davek,
			null AS ostanekkg		
	FROM	(SELECT *, CASE when @par_obdobje_enabled = 1 AND @par_obdobje_polje = 2 then dat_zap else datum_dok END as dat FROM dbo.planp) a INNER JOIN 
			dbo.pogodba b ON a.id_cont = b.id_cont INNER JOIN 
			dbo.nacini_l c ON a.nacin_leas = c.nacin_leas 
			OUTER APPLY dbo.gfn_xchange_table(@par_tecajnica_tecajnica,a.debit,a.id_tec,@par_tecajnica_datumtec) xa
			OUTER APPLY dbo.gfn_xchange_table(@par_tecajnica_tecajnica,a.neto,a.id_tec, @par_tecajnica_datumtec) xb
			OUTER APPLY dbo.gfn_xchange_table(@par_tecajnica_tecajnica,a.obresti,a.id_tec, @par_tecajnica_datumtec) xc
			OUTER APPLY dbo.gfn_xchange_table(@par_tecajnica_tecajnica,a.robresti,a.id_tec, @par_tecajnica_datumtec) xd
			OUTER APPLY dbo.gfn_xchange_table(@par_tecajnica_tecajnica,a.marza,a.id_tec, @par_tecajnica_datumtec) xe
			OUTER APPLY dbo.gfn_xchange_table(@par_tecajnica_tecajnica,a.regist,a.id_tec, @par_tecajnica_datumtec) xf
			OUTER APPLY dbo.gfn_xchange_table(@par_tecajnica_tecajnica,a.davek,a.id_tec, @par_tecajnica_datumtec) xg
	WHERE	b.status_akt <> 'N' AND
			1 = (CASE WHEN @par_obdobje_enabled = 1 THEN (CASE WHEN (a.dat between @par_obdobje_datumod and @par_obdobje_datumdo) THEN 1 ELSE 0 END) ELSE 1 END) AND
			1 = (CASE WHEN @par_nacinleas_enabled = 1 THEN (CASE WHEN CHARINDEX(b.nacin_leas,@par_nacinleas_nacinleas) > 0 THEN 1 ELSE 0 END) ELSE 1 END) AND
			1 = (CASE WHEN @par_aktiviranodatum_enabled = 1 THEN (CASE WHEN b.dat_aktiv <= @par_aktiviranodatum_aktiviranodatum THEN 1 ELSE 0 END) ELSE 1 END) AND
			1 = (CASE WHEN @par_aneks_enabled = 1 THEN (CASE
				WHEN @par_aneks_anekstype = 1 AND (CHARINDEX(B.aneks, @par_aneks_anekses) = 0 OR B.aneks = '') THEN 1
				WHEN @par_aneks_anekstype = 2 AND NOT (CHARINDEX(B.aneks, @par_aneks_anekses) = 0 OR B.aneks = '') THEN 1
				ELSE 0 END) ELSE 1 END) AND
			1 = (CASE WHEN @par_tipterjatev_enabled = 1 AND @par_tipterjatev_tipterjatve > 1 THEN (CASE WHEN CHARINDEX(a.id_terj, @niz_ter) > 0 THEN 1 ELSE 0 END) ELSE 1 END) AND
			1 = (CASE WHEN @par_strm_enabled = 1 THEN (CASE WHEN CHARINDEX(b.id_strm, @par_strm_strm) > 0 THEN 1 ELSE 0 END) ELSE 1 END) AND
			1 = (CASE WHEN @par_kategorija_enabled = 1 THEN (CASE WHEN CHARINDEX(b.kategorija, @par_kategorija_kategorija) > 0 THEN 1 ELSE 0 END) ELSE 1 END) AND
			1 = (CASE WHEN @par_akt_enabled = 1 THEN (CASE
				WHEN @par_akt_akttype = 1 AND (CHARINDEX(B.status_akt, @par_akt_akt) = 0 OR B.status_akt = '') THEN 1
				WHEN @par_akt_akttype = 2 AND NOT (CHARINDEX(B.status_akt, @par_akt_akt) = 0 OR B.status_akt = '') THEN 1
				ELSE 0 END) ELSE 1 END)
GROUP BY	CASE when @par_grouping_grouping = 1 then a.dat END,
			CASE when @par_grouping_grouping = 2 then datepart(wk,a.dat) END,
			CASE when @par_grouping_grouping = 3 then month(a.dat) END,
			CASE when @par_grouping_grouping = 4 then dbo.gfn_kvartal(a.dat) END,
			year(a.dat)

) a
OPTION (RECOMPILE)


SELECT
	sum(neto) as sum_neto
INTO #table2
FROM #table1


SELECT		datum,
			teden,
			--mesec AS mesec_broj, -- g_tomislav dorada
			dbo.gfn_monthname(a.mesec) AS mesec,
			kvart,				
			leto,
			st_terj,
			debit,
			neto = cast(neto as decimal(18,4)),
			obresti,
			robresti,
			marza,
			regist,
			davek,
			fin_davek,
			cast(
			(sum_neto) - 
			(CASE	@par_grouping_grouping
				WHEN 1 THEN (SELECT SUM(neto) FROM #table1 b WHERE b.datum <= a.datum)
				WHEN 2 THEN (SELECT SUM(neto) FROM #table1 b WHERE 1 = (case when (b.leto > a.leto) then (0) else (case when (b.leto < a.leto) then (1) else (case when (b.teden <= a.teden) then (1) else (0) end) end) end))
				WHEN 3 THEN (SELECT SUM(neto) FROM #table1 b WHERE  1 = (case when (b.leto > a.leto) then (0) else (case when (b.leto < a.leto) then (1) else (case when (b.mesec <= a.mesec) then (1) else (0) end) end) end))
				WHEN 4 THEN (SELECT SUM(neto) FROM #table1 b WHERE 1 = (case when (b.leto > a.leto) then (0) else (case when (b.leto < a.leto) then (1) else (case when (b.kvart <= a.kvart) then (1) else (0) end) end) end))
				WHEN 5 THEN (SELECT SUM(neto) FROM #table1 b WHERE b.leto<= a.leto)
			END)						
			as decimal(18,4)) AS ostanekkg		
FROM
	#table1 a
	cross join #table2 b
ORDER BY leto, kvart, a.mesec, teden, datum -- g_tomislav dorada
