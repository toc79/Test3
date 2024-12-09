USE [NOVA_PROD]
GO
/****** Object:  UserDefinedFunction [dbo].[gfn_cf_pr_obvezn_posam]    Script Date: 10.2.2021. 9:10:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------------------------------------------------------------------------------------------------------------------------
-- Function for getting data in meni "Pregledi iz denarnega toka" for "Pričakovane obveznosti" item "Posamezno" (GL) 
--
-- History:
-- 01.08.2006 Jelena; created
-- 16.01.2007 Jasna; changed field length kreditodajalec(40 --> 80)
-- 13.12.2012 Ales; MR 36712 - changed all fields 'mesec' in declaring tables except in @result from char(20) to int
-- 29.10.2014 MatjazB; MID 47620 - refactoring; added parameter @par_dodgrup
-- 05.03.2018 Nejc; TID 12921 - GDPR
-- 16.12.2020 g_tomislav MID 46023 - rollback to version 6.14.10 from 6.16.5
------------------------------------------------------------------------------------------------------------------------------------------------------

ALTER FUNCTION [dbo].[gfn_cf_pr_obvezn_posam]
(
 @par_tecajnica_enabled int,
 @par_tecajnica_tecajnica char(3), -- Exchange rate ID
 @par_tecajnica_datumtec datetime,  -- today
 @par_tecajnica_valuta char(3), 
 @par_obdobje_enabled int,
 @par_obdobje_datumod datetime, -- beginning period date
 @par_obdobje_datumdo datetime, --end period date
 @par_aktiviranodatum_enabled int,
 @par_aktiviranodatum_aktiviranodatum datetime, -- consider contracts activate till 
 @par_grouping_enabled int,
 @par_grouping_grouping int, -- group by year, (day,week,month,kvart)
 @par_dodgrup_enabled int,
 @par_dodgrup_value int -- additional group by
)

RETURNS @result table
(
	datum datetime,
	teden int,
	mesec char(20),
	kvart int,
	id_tec int,
	leto int,
	znesek decimal(18,2),
	opis varchar(45),
	neto decimal(18,2),
	obresti decimal(18,2),
	marza decimal(18,2),
	davek decimal(18,2),
	sifra_kupca char(6),
	kreditodajalec varchar(80),
	njih_stevilka char(15),
	id_kredpog char(15),
	orig_tec char(3),
	orig_razd decimal(18,2),
	orig_obresti decimal(18,2),
	oznaka char(5),
	aneks char(1), 
    rtip_naziv varchar(35) 
)  
AS
BEGIN

-------------------------------------------------------
--Prepare temporary table @tabela_kred_planp0  
-------------------------------------------------------
DECLARE @tabela_kred_planp0 table
(
	datum datetime,
	teden int,
	mesec int,--mesec char(20),
	kvart int,
	id_tec int,
	leto int,
	znesek decimal(18,2),
	neto decimal(18,2),
	obresti decimal(18,2),
	marza decimal(18,2),
	davek decimal(18,2),
	id_kredpog char(15),
	orig_razd decimal(18,2),
	orig_obresti decimal(18,2), 
    id_rtip char(5)
)
-------------------------------------------------------
--Prepare temporary table @tabela_kred_planp  
-------------------------------------------------------
DECLARE @tabela_kred_planp table
(
	datum datetime,
	teden int,
	mesec int,--mesec char(20),
	kvart int,
	id_tec int,
	leto int,
	znesek decimal(18,2),
	opis varchar(45),
	neto decimal(18,2),
	obresti decimal(18,2),
	marza decimal(18,2),
	davek decimal(18,2),
	sifra_kupca char(6),
	kreditodajalec varchar(80),
	njih_stevilka char(15),
	id_kredpog char(15),
	orig_tec char(3),
	orig_razd decimal(18,2),
	orig_obresti decimal(18,2),
	oznaka char(5),
	aneks char(1), 
    id_rtip char(5)
)

INSERT INTO   @tabela_kred_planp0
SELECT 
    case when @par_grouping_grouping = 1 then p.dat_zap else null end as datum,
    case when @par_grouping_grouping = 2 then datepart(wk, p.dat_zap) else null end AS teden,
    case when @par_grouping_grouping = 3 then month(p.dat_zap) else null end AS mesec,
    case when @par_grouping_grouping = 4 then dbo.gfn_kvartal(p.dat_zap) else null end AS kvart,	
    @par_tecajnica_tecajnica as id_tec,
    year(p.dat_zap) AS leto,
    sum(dbo.gfn_xchange(@par_tecajnica_tecajnica,p.anuiteta,p.id_tec,@par_tecajnica_datumtec)) as znesek,
    sum(dbo.gfn_xchange(@par_tecajnica_tecajnica,p.znes_r,p.id_tec,@par_tecajnica_datumtec)) as neto,
    sum(dbo.gfn_xchange(@par_tecajnica_tecajnica,p.znes_o,p.id_tec,@par_tecajnica_datumtec)) as obresti,
    0 as marza,
    0 as davek,
    p.id_kredpog,
    sum(p.znes_r) as orig_razd,
    sum(p.znes_o) as orig_obresti, 
    case when @par_dodgrup_enabled = 1 and @par_dodgrup_value = 1 then pg.id_rtip else null end as id_rtip
FROM 
    dbo.kred_planp p
    INNER JOIN dbo.Kred_Pog pg ON pg.Id_KredPog = p.Id_KredPog
WHERE 
    (@par_aktiviranodatum_enabled = 0 or pg.dat_sklen <= @par_aktiviranodatum_aktiviranodatum) 
    AND (@par_obdobje_enabled = 0 or p.dat_zap BETWEEN @par_obdobje_datumod AND @par_obdobje_datumdo)  --Where za "stat_criteria_obdobje"
    AND p.crpanje = 0
group by  
    case when @par_grouping_grouping = 1 then p.dat_zap else null end, 
    case when @par_grouping_grouping = 2 then datepart(wk, p.dat_zap) else null end, 
    case when @par_grouping_grouping = 3 then month(p.dat_zap) else null end, 
    case when @par_grouping_grouping = 4 then dbo.gfn_kvartal(p.dat_zap) else null end, 
    year(p.dat_zap), p.id_kredpog, 
    case when @par_dodgrup_enabled = 1 and @par_dodgrup_value = 1 then pg.id_rtip else null end 
order by 
    year(p.dat_zap), 
    case when @par_grouping_grouping = 1 then p.dat_zap else null end, 
    case when @par_grouping_grouping = 2 then datepart(wk, p.dat_zap) else null end, 
    case when @par_grouping_grouping = 3 then month(p.dat_zap) else null end, 
    case when @par_grouping_grouping = 4 then dbo.gfn_kvartal(p.dat_zap) else null end
  


INSERT INTO @tabela_kred_planp
SELECT 	
    p.datum, 
    p.teden, 
    p.mesec, 
    p.kvart, 
    p.id_tec,
    p.leto, 
    p.znesek,
    'Anuiteta kredita'+' ('+ rtrim(p.id_kredpog) + ')' as opis,
    p.neto, 
    p.obresti, 
    p.marza, 
    p.davek,
    pg.id_kupca as sifra_kupca,
    par.naz_kr_kup as kreditodajalec,
    pg.njih_st as njih_stevilka,
    p.id_kredpog,
    p.id_tec as orig_tec,
    p.orig_razd, 
    p.orig_obresti,
    pg.oznaka, 
    pg.aneks, 
    p.id_rtip
FROM 
    @tabela_kred_planp0 p
    INNER JOIN dbo.Kred_Pog pg ON pg.Id_KredPog=p.Id_KredPog
    INNER JOIN dbo.gfn_Partner_Pseudo('gfn_cf_pr_obvezn_posam',null) par ON par.Id_kupca=pg.Id_kupca

-------------------------------------------------------
--Prepare temporary table @tabela_stroski0
-------------------------------------------------------
DECLARE @tabela_stroski0 table
(
	datum datetime,
	teden int,
	mesec int,--mesec char(20),
	kvart int,
	id_tec int,
	leto int,
	znesek decimal(18,2),
	neto decimal(18,2),
	obresti decimal(18,2),
	marza decimal(18,2),
	davek decimal(18,2),
	sifra_kupca char(6),
	kreditodajalec varchar(80),
	njih_stevilka char(15),
	id_kredpog char(15),
	orig_razd decimal(18,2),
	orig_obresti decimal(18,2),
	oznaka char(5),
	aneks char(1),
	id_str char(3), 
    id_rtip char(5)

)
-------------------------------------------------------
--Prepare temporary table @tabela_stroski
-------------------------------------------------------
DECLARE @tabela_stroski table
(
	datum datetime,
	teden int,
	mesec int,--mesec char(20),
	kvart int,
	id_tec int,
	leto int,
	znesek decimal(18,2),
	opis varchar(45),
	neto decimal(18,2),
	obresti decimal(18,2),
	marza decimal(18,2),
	davek decimal(18,2),
	sifra_kupca char(6),
	kreditodajalec varchar(80),
	njih_stevilka char(15),
	id_kredpog char(15),
	orig_tec char(3),
	orig_razd decimal(18,2),
	orig_obresti decimal(18,2),
	oznaka char(5),
	aneks char(1), 
    id_rtip char(5)
)

INSERT INTO	@tabela_stroski0

SELECT 	
    case when @par_grouping_grouping = 1 then s.datum else null end as datum, 
    case when @par_grouping_grouping = 2 then datepart(wk, s.datum) else null end AS teden, 
    case when @par_grouping_grouping = 3 then month(s.datum) else null end AS mesec, 
    case when @par_grouping_grouping = 4 then dbo.gfn_kvartal(s.datum) else null end AS kvart, 
    @par_tecajnica_tecajnica as id_tec,
    year(s.datum) AS leto,
    sum(dbo.gfn_xchange(@par_tecajnica_tecajnica,s.znes_o,s.id_tec,@par_tecajnica_datumtec)) as znesek,
    sum(dbo.gfn_xchange(@par_tecajnica_tecajnica,s.znes_o,s.id_tec,@par_tecajnica_datumtec)) as neto,
    0 as obresti,
    0 as marza,
    0 as davek,
    '' as sifra_kupca,
    '' as kreditodajalec,
    '' as njih_stevilka,
    '' as id_kredpog,
    0 as orig_razd,
    0 as orig_obresti,
    '' as oznaka,
    '' as aneks,
    s.id_str as id_str, 
    null as id_rtip
FROM dbo.stroski s
WHERE (@par_obdobje_enabled = 0 or s.datum BETWEEN @par_obdobje_datumod AND @par_obdobje_datumdo) --Where za "stat_criteria_obdobje"
GROUP BY 
    case when @par_grouping_grouping = 1 then s.datum else null end, 
    case when @par_grouping_grouping = 2 then datepart(wk, s.datum) else null end, 
    case when @par_grouping_grouping = 3 then month(s.datum) else null end, 
    case when @par_grouping_grouping = 4 then dbo.gfn_kvartal(s.datum) else null end, 
    year(s.datum), 
    s.id_str
ORDER BY 
    year(s.datum), 
    case when @par_grouping_grouping = 1 then s.datum else null end, 
    case when @par_grouping_grouping = 2 then datepart(wk, s.datum) else null end, 
    case when @par_grouping_grouping = 3 then month(s.datum) else null end, 
    case when @par_grouping_grouping = 4 then dbo.gfn_kvartal(s.datum) else null end

-- Insert v tabelo @tabela_stroski
INSERT INTO	@tabela_stroski
SELECT 	datum, 
	teden,
 	mesec, 
	kvart, 
	id_tec, 
	leto,
	znesek,
	ss.opis,
	neto,
	obresti, 
	marza,
 	davek,
	sifra_kupca,
	kreditodajalec,
	njih_stevilka,
	id_kredpog,
	s.id_tec as orig_tec,
	orig_razd, 
	orig_obresti,
	oznaka,
 	aneks,
    s.id_rtip
FROM 
    @tabela_stroski0 s
    INNER JOIN dbo.spl_str ss ON s.id_str=ss.id_str


------Declare temporary table @res_union for insert union @tabela_kred_planp and @tabela_stroski------
DECLARE @res_union table
(
	datum datetime,
	teden int,
	mesec int,--mesec char(20),
	kvart int,
	id_tec int,
	leto int,
	znesek decimal(18,2),
	opis varchar(45),
	neto decimal(18,2),
	obresti decimal(18,2),
	marza decimal(18,2),
	davek decimal(18,2),
	sifra_kupca char(6),
	kreditodajalec varchar(80),
	njih_stevilka char(15),
	id_kredpog char(15),
	orig_tec char(3),
	orig_razd decimal(18,2),
	orig_obresti decimal(18,2),
	oznaka char(5),
	aneks char(1),
    id_rtip char(5)
) 

INSERT INTO @res_union 
SELECT * FROM @tabela_kred_planp
UNION 
SELECT * FROM @tabela_stroski


------Insert into @result------------------------------------------------------------------

INSERT INTO @result
SELECT 
	a.datum, 
    a.teden, 
	a.mesec, 
	a.kvart, 
	a.id_tec, 
	a.leto, 
	sum(a.znesek) as znesek,
	a.opis, 
	sum(a.neto) as neto,
	sum(a.obresti) as obresti, 
	sum(a.marza) as marza, 
	sum(a.davek) as davek, 
 	a.sifra_kupca, 
	a.kreditodajalec, 
	a.njih_stevilka, 
	a.id_kredpog, 
	a.orig_tec,
 	sum(a.orig_razd), 
	sum(a.orig_obresti),
  	a.oznaka, 
	a.aneks, 
    b.naziv as rtip_naziv
FROM 
    @res_union a
    left join dbo.rtip b on a.id_rtip = b.id_rtip
GROUP BY a.datum, a.leto, a.kvart, a.mesec , a.teden, a.id_tec, a.id_kredpog, a.sifra_kupca, a.kreditodajalec, 
		a.njih_stevilka, a.Id_KredPog, a.orig_tec, a.oznaka, a.aneks,opis, b.naziv


UPDATE @result set mesec = dbo.gfn_monthname(mesec) 
RETURN 
END

