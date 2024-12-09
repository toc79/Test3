-- 14.09.2021 g_tomislav MID 47152 - created based on gfn_GL_Overview2_Current
-- 25.10.2021 g_andrija MID 47763 - added isnull(r.id_source, g.ID_SOURCE)
-- 04.11.2021 g_andrijap MID 47763 - popravljen pretraga po kontu
-- 10.11.2021 g_tomislav MID 47763 - added join for bookings from incoming invoices (g.SOURCE_TBL = 'gl_input_rk')
-- 01.06.2022 g_tomislav MID 47763 - manually entered delimiters are new connected through ddv_id, id_cont, raz_pkonto and znesek. All booking are now showed except OTV and ZPL. Fixed search by @konto

declare @from datetime = {1} --'20200101'
declare @to datetime = {2} --'20210909'
declare @enabled_id_vrst_dod_str bit = {3}
declare @id_vrst_dod_str varchar(200) = {4}
declare @enabled_konto bit = {5}
declare @konto varchar(max) = {6}
declare @from_archive bit = {7}

select ltrim(rtrim(id)) as konto 
into #konto_list
from dbo.gfn_split_ids(@konto, ',') 

SELECT g.id_gl,
	g.konto,
	g.id_kupca,
	c.naz_kr_kup,
	g.vrsta_dok,
	g.debit_dom,
	g.kredit_dom,
	g.protikonto,
	g.st_dok,
	g.datum_dok,
	str(month(g.datum_dok),2,0)+'.'+str(year(g.datum_dok),4,0) as obdobje,
	g.debit_val,
	g.kredit_val,
	g.id_val,
	g.veza,
	g.interna_veza,
	g.id_strm,
	isnull(p1.id_pog, p2.id_pog) as id_pog,
	g.opisdok,
	vds.id_vrst_dod_str,
	vds.naziv as vrst_dod_str_naziv,
	g.dur,
	g.njihova_st,
	a.naziv as konto_naziv
into #temp471522
from dbo.gl g
left join dbo.partner c on g.id_kupca = c.id_kupca 
left join dbo.akonplan a on g.konto = a.konto
left join dbo.pogodba p1 on g.id_cont = p1.id_cont
left join dbo.pogodba_deleted p2 on g.id_cont = p2.id_cont
left join dbo.gl_raz_plan rp on g.id_source = rp.id_gl_raz_plan and g.source_tbl = 'gl_raz_plan'
left join (
	-- lista razgraničenja i šifre troška
	-- razgraničenja automatski generiranja iz ulaznih računa
	select a.id_gl_razmej
		, irk.id_vrst_dod_str			
	from dbo.gl_razmej as a  
	left join dbo.ARH_GL_INPUT_RK irk on a.id_source = irk.ID_GL_INPUT_RK
	where a.source_tbl = 'gl_input_rk'

	union all

	-- razgraničenja unesena ručno
	select a.id_gl_razmej
		, irk.id_vrst_dod_str
	from dbo.gl_razmej as a   
	left join dbo.arh_gl_input_r ir on a.ddv_id = ir.ddv_id -- veza broj računa
	left join dbo.arh_gl_input_rk irk on ir.id_gl_input_r = irk.id_gl_input_r and a.id_cont = irk.id_cont and a.raz_pkonto = irk.protikonto and a.znesek = irk.znesek -- veza broj ugovora i konto razgraničenja i iznos
	where a.source_tbl != 'gl_input_rk'
	and a.vrsta_dok = 'PFA' 
) r on r.id_gl_razmej = rp.id_gl_razmej
left join dbo.arh_gl_input_rk irk2 on g.id_source = irk2.id_gl_input_rk and g.source_tbl = 'gl_input_rk' -- uknjižbe na stavkama ulaznog računa
left join dbo.vrst_dod_str vds on  coalesce(r.id_vrst_dod_str, irk2.id_vrst_dod_str) = vds.id_vrst_dod_str
where g.vrsta_dok not in ('OTV', 'ZPL')
--and (g.SOURCE_TBL = 'gl_input_rk' or r.id_gl_razmej is not null) -- imaju MANUAL uknjižbe za koje se ne zna koja opcija ih je kreirala
and g.datum_dok between @from and @to
and (0 = @enabled_id_vrst_dod_str OR charindex(r.id_vrst_dod_str, @id_vrst_dod_str) > 0)
AND (@enabled_konto = 0 OR exists (select * from #konto_list where konto = g.konto)) --CHARINDEX(ltrim(rtrim(g.konto)), @konto) > 0)

union all 

SELECT g.id_gl,
	g.konto,
	g.id_kupca, 
	c.naz_kr_kup,
	g.vrsta_dok,
	g.debit_dom,
	g.kredit_dom,
	g.protikonto,
	g.st_dok,
	g.datum_dok,
	str(month(g.datum_dok),2,0)+'.'+str(year(g.datum_dok),4,0) as obdobje,
	g.debit_val,
	g.kredit_val,
	g.id_val,
	g.veza,
	g.interna_veza,
	g.id_strm,
	isnull(p1.id_pog, p2.id_pog) as id_pog,
	g.opisdok,
	vds.id_vrst_dod_str,
	vds.naziv as vrst_dod_str_naziv,
	g.dur,
	g.njihova_st,
	a.naziv as konto_naziv
from dbo.gl_arhiv g
left join dbo.partner c on g.id_kupca = c.id_kupca 
left join dbo.akonplan a on g.konto = a.konto
left join dbo.pogodba p1 on g.id_cont = p1.id_cont
left join dbo.pogodba_deleted p2 on g.id_cont = p2.id_cont
left join dbo.gl_raz_plan rp on g.id_source = rp.id_gl_raz_plan and g.source_tbl = 'gl_raz_plan'
left join (
	-- lista razgraničenja i šifre troška
	-- razgraničenja automatski generiranja iz ulaznih računa
	select a.id_gl_razmej
		, irk.id_vrst_dod_str			
	from dbo.gl_razmej as a  
	left join dbo.arh_gl_input_rk irk on a.id_source = irk.ID_GL_INPUT_RK
	where a.source_tbl = 'gl_input_rk'

	union all

	-- razgraničenja unesena ručno
	select a.id_gl_razmej
		, irk.id_vrst_dod_str
	from dbo.gl_razmej as a   
	left join dbo.arh_gl_input_r ir on a.ddv_id = ir.ddv_id -- veza broj računa
	left join dbo.arh_gl_input_rk irk on ir.id_gl_input_r = irk.id_gl_input_r and a.id_cont = irk.id_cont and a.raz_pkonto = irk.protikonto and a.znesek = irk.znesek -- veza broj ugovora i konto razgraničenja i iznos
	where a.source_tbl != 'gl_input_rk'
	and a.vrsta_dok = 'PFA' 
) r on r.id_gl_razmej = rp.id_gl_razmej
left join dbo.arh_gl_input_rk irk2 on g.id_source = irk2.id_gl_input_rk and g.source_tbl = 'gl_input_rk' -- uknjižbe na stavkama ulaznog računa
left join dbo.vrst_dod_str vds on  coalesce(r.id_vrst_dod_str, irk2.id_vrst_dod_str) = vds.id_vrst_dod_str
where 1 = @from_archive
and g.vrsta_dok not in ('OTV', 'ZPL')
--and (g.SOURCE_TBL = 'gl_input_rk' or r.id_gl_razmej is not null) -- imaju MANUAL uknjižbe za koje se ne zna koja opcija ih je kreirala
and g.datum_dok between @from and @to
and (0 = @enabled_id_vrst_dod_str OR charindex(r.id_vrst_dod_str, @id_vrst_dod_str) > 0)
AND (@enabled_konto = 0 OR exists (select * from #konto_list where konto = g.konto)) --CHARINDEX(ltrim(rtrim(g.konto)), @konto) > 0)

drop table #konto_list


-- GDPR LOGIRANJE
SELECT cs.id as id
INTO #tempVrste
FROM dbo.gfn_split_ids( (Select [val] FROM dbo.CUSTOM_SETTINGS WHERE code='Nova.GDPR.ListOfCustomerTypesForAccessLog'),',') cs

declare @xml as xml
set @xml = 
(
	SELECT * 
	FROM 
	(
		SELECT
			t.id_kupca as '@ID_KUPCA', 
			p.vr_osebe as '@vrsta_osebe',
			'' as  '@Additional_desc'
		FROM #temp471522 t
		INNER JOIN dbo.PARTNER p on p.id_kupca=t.id_kupca
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		GROUP BY t.ID_KUPCA, p.vr_osebe 
	) as s
	FOR XML PATH ('Customers'), ROOT('ROOT')
)

DECLARE @time datetime;
SET @time=GETDATE();
exec dbo.gsp_GDPR_LogCustomerDataAccessInternal @time, {@username}, null, 'Kraći naziv', 'INTERNAL', 'CUSTOM_REPORT', 'Kartica s dodatnim troškovima ', '471522', @xml
drop table #tempVrste
-- KONEC GDPR

select * from #temp471522 order by datum_dok
drop table #temp471522