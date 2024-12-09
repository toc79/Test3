-- 14.09.2021 g_tomislav MID 47152 - created based on gfn_GL_Overview2_Current
-- 25.10.2021 g_andrija MID 47763 - added isnull(r.id_source, g.ID_SOURCE)
-- 04.11.2021 g_andrijap MID 47663 - popravljen pretraga po kontu

declare @from datetime = '20210101' --'20200101'
declare @to datetime = '20211105' --'20210909'
declare @enabled_id_vrst_dod_str bit = 0
declare @id_vrst_dod_str varchar(200) = ''
declare @enabled_konto bit = 0 --0 = 83343 zapisa
declare @konto varchar(5000) = '190002'
declare @from_archive bit = 0
	
	
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
	--coalesce(irk.id_vrst_dod_str, irk2.id_vrst_dod_str, irk3.id_vrst_dod_str) as id_vrst_dod_str,
	vds.id_vrst_dod_str,
	--coalesce(vds.naziv, vds2.naziv, vds3.naziv) as vrst_dod_str_naziv,
	vds.naziv as vrst_dod_str_naziv,
	g.dur,
	g.njihova_st,
	a.naziv as konto_naziv
, g.*
--, irk3.*
--into #temp471522 
from dbo.gl g
left join dbo.partner c on g.id_kupca = c.id_kupca 
left join dbo.akonplan a on g.konto = a.konto
left join dbo.pogodba p1 on g.id_cont = p1.id_cont
left join dbo.pogodba_deleted p2 on g.id_cont = p2.id_cont
left join dbo.gl_raz_plan rp on g.id_source = rp.id_gl_raz_plan and g.source_tbl = 'gl_raz_plan'
left join dbo.gl_razmej r on r.id_gl_razmej = rp.id_gl_razmej 
left join dbo.arh_gl_input_rk irk on r.id_source = irk.id_gl_input_rk and r.source_tbl = 'gl_input_rk' -- uknjižbe razgranièenja kreiranog automatski na temelju ulaznog raèuna
--left join dbo.vrst_dod_str vds on irk.id_vrst_dod_str = vds.id_vrst_dod_str
left join dbo.arh_gl_input_rk irk2 on g.id_source = irk2.id_gl_input_rk and g.source_tbl = 'gl_input_rk' -- uknjižbe na stavkama ulaznog raèuna
--left join dbo.vrst_dod_str vds2 on irk2.id_vrst_dod_str = vds2.id_vrst_dod_str
-- uknjižbe ruèno unesenih razgranièenja vezanih na ulazne raèune preko broja raèuna gdje se stavke i razgranièenje mogu prepoznati samo po broju ugovora i iznosu
--left join dbo.gl_raz_plan rp3 on g.id_source = rp3.id_gl_raz_plan and g.source_tbl = 'gl_raz_plan' -- ovo je isto kao iznad pa ne treba ponovno
left join dbo.gl_razmej r3 on r3.id_gl_razmej = rp.id_gl_razmej and isnull(r3.id_source, '') = ''
left join dbo.arh_gl_input_r ir3 on r3.ddv_id = ir3.ddv_id -- kako ne znamo koja razgranièenja su za koju stavku
left join dbo.arh_gl_input_rk irk3 on ir3.id_gl_input_r = irk3.id_gl_input_r and r3.id_cont = irk3.id_cont and r3.raz_pkonto = irk3.protikonto --and r3.znesek = irk3.znesek ISTI BROJ ZAPISA
left join dbo.vrst_dod_str vds on coalesce(irk.id_vrst_dod_str, irk2.id_vrst_dod_str, irk3.id_vrst_dod_str) = vds.id_vrst_dod_str
where g.vrsta_dok != 'OTV'
and (g.SOURCE_TBL = 'gl_input_rk' or r.SOURCE_TBL = 'gl_input_rk' or g.source_tbl = 'gl_raz_plan' )
--and coalesce(irk.id_vrst_dod_str, irk2.id_vrst_dod_str, '') != ''-- is not null
and datum_dok between @from and @to
and (0 = @enabled_id_vrst_dod_str OR charindex(irk.id_vrst_dod_str, @id_vrst_dod_str) > 0)
and (@enabled_konto = 0 OR CHARINDEX(ltrim(rtrim(g.konto)), @konto) > 0)
--and id_gl = 4241329 --4516001--4225698 --4260789
	--or r3.id_gl_razmej = 3352
	--or r.id_gl_razmej = 3090)

--select * from #temp471522
--select id_gl from #temp471522 group by id_gl having count(*) > 1 -- 0 zapisa
--drop table #temp471522