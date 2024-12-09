-- 14.09.2021 g_tomislav MID 47152 - created based on gfn_GL_Overview2_Current
-- 25.10.2021 g_andrija MID 47763 - added isnull(r.id_source, g.ID_SOURCE)
-- 04.11.2021 g_andrijap MID 47663 - popravljen pretraga po kontu

declare @from datetime = '20210101' --'20200101'
declare @to datetime = '20211105' --'20210909'
declare @enabled_id_vrst_dod_str bit = 0
declare @id_vrst_dod_str varchar(200) = ''
declare @enabled_konto bit = 1
declare @konto varchar(5000) = '190002'
declare @from_archive bit = 0
	
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
--left join dbo.ARH_GL_INPUT_RK irk on r.id_source = irk.ID_GL_INPUT_RK
 join dbo.ARH_GL_INPUT_R ir on r.ddv_id = ir.ddv_id
left join dbo.ARH_GL_INPUT_RK irk on ir.ID_GL_INPUT_R = irk.ID_GL_INPUT_R and r.id_cont = irk.id_cont
--left join dbo.ARH_GL_INPUT_R ir on ir.ID_GL_INPUT_R = irk.ID_GL_INPUT_R
left join dbo.vrst_dod_str vds on irk.id_vrst_dod_str = vds.id_vrst_dod_str
--left join dbo.GL_RAZ_PLAN rp2 on g.ID_SOURCE = rp.ID_GL_RAZ_PLAN
--left join dbo.gl_razmej r2 on r.ID_GL_RAZMEJ = rp.ID_GL_RAZMEJ 
--outer apply (select * from dbo.gl_razmej where vrsta_dok = 'IFA' and ddv_id = g.veza ) r2
where g.vrsta_dok != 'OTV'
and (g.SOURCE_TBL != 'gl_input_rk' and r.SOURCE_TBL != 'gl_input_rk')  
--and (g.SOURCE_TBL = 'GL_RAZ_PLAN') -- and r.ddv_id = ir.ddv_id))
and irk.id_vrst_dod_str is not null
and datum_dok between @from and @to
and (0 = @enabled_id_vrst_dod_str OR charindex(irk.id_vrst_dod_str, @id_vrst_dod_str) > 0)
AND (@enabled_konto = 0 OR CHARINDEX(ltrim(rtrim(g.konto)), @konto) > 0)
--and id_gl = 4225698
--and g.VRSTA_DOK = 'IFA'

select * from #temp471522 --order by datum_dok
select id_gl, veza, st_dok,  count(*) from #temp471522 group by id_gl, veza,st_dok having count(*) > 1 --5321
drop table #temp471522