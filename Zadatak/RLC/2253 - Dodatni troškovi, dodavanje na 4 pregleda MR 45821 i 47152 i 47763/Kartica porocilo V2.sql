-- 14.09.2021 g_tomislav MID 47152 - created based on gfn_GL_Overview2_Current

declare @from datetime = {1} --'20200101'
declare @to datetime = {2} --'20210909'
declare @enabled_konto bit = {3}
declare @konto char(8) = {4}
declare @enabled_id_vrst_dod_str bit = {5}
declare @id_vrst_dod_str varchar(200) = {6}
declare @from_archive bit = {7}
	
SELECT g.konto,
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
	irk.id_vrst_dod_str,
	vds.naziv as vrst_dod_str_naziv,
	g.dur,
	g.njihova_st,
	a.naziv as konto_naziv
into #temp471522
from dbo.gl g
LEFT JOIN dbo.partner C ON G.id_kupca = C.id_kupca 
LEFT JOIN dbo.akonplan A ON G.konto = A.konto
LEFT JOIN dbo.pogodba p1 ON G.id_cont = P1.id_cont
LEFT JOIN dbo.pogodba_deleted p2 ON G.id_cont = P2.id_cont
left join dbo.GL_RAZ_PLAN rp on g.ID_SOURCE = rp.ID_GL_RAZ_PLAN
left join dbo.gl_razmej r on r.ID_GL_RAZMEJ = rp.ID_GL_RAZMEJ
inner join dbo.ARH_GL_INPUT_RK irk on r.id_source = irk.ID_GL_INPUT_RK
inner join dbo.vrst_dod_str vds on irk.id_vrst_dod_str = vds.id_vrst_dod_str
where g.vrsta_dok != 'OTV'
and (g.SOURCE_TBL = 'gl_input_rk' or r.SOURCE_TBL = 'gl_input_rk')
and irk.id_vrst_dod_str is not null
and datum_dok between @from and @to
and (0 = @enabled_konto OR g.konto = @konto)
and (0 = @enabled_id_vrst_dod_str OR charindex(irk.id_vrst_dod_str, @id_vrst_dod_str) > 0)

union all 

SELECT g.konto,
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
	irk.id_vrst_dod_str,
	vds.naziv as vrst_dod_str_naziv,
	g.dur,
	g.njihova_st,
	a.naziv as konto_naziv
from dbo.gl_arhiv g
LEFT JOIN dbo.partner C ON G.id_kupca = C.id_kupca 
LEFT JOIN dbo.akonplan A ON G.konto = A.konto
LEFT JOIN dbo.pogodba p1 ON G.id_cont = P1.id_cont
LEFT JOIN dbo.pogodba_deleted p2 ON G.id_cont = P2.id_cont
left join dbo.GL_RAZ_PLAN rp on g.ID_SOURCE = rp.ID_GL_RAZ_PLAN
left join dbo.gl_razmej r on r.ID_GL_RAZMEJ = rp.ID_GL_RAZMEJ
inner join dbo.ARH_GL_INPUT_RK irk on r.id_source = irk.ID_GL_INPUT_RK
inner join dbo.vrst_dod_str vds on irk.id_vrst_dod_str = vds.id_vrst_dod_str
where 1 = @from_archive
and g.vrsta_dok != 'OTV'
and (g.SOURCE_TBL = 'gl_input_rk' or r.SOURCE_TBL = 'gl_input_rk')
and irk.id_vrst_dod_str is not null
and datum_dok between @from and @to
and (0 = @enabled_konto OR g.konto = @konto)
and (0 = @enabled_id_vrst_dod_str OR charindex(irk.id_vrst_dod_str, @id_vrst_dod_str) > 0)

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