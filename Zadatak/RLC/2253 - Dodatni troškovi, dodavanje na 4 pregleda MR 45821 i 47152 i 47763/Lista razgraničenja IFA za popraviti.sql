select r.*, irk.id_vrst_dod_str, irk.ZNESEK as irk_znesek
into #gl_razmej_IFA
from dbo.gl_razmej r
inner join dbo.ARH_GL_INPUT_R ir on r.ddv_id = ir.ddv_id
inner join dbo.arh_gl_input_rk irk on ir.id_gl_input_r = irk.id_gl_input_r and r.id_cont = irk.id_cont and r.raz_pkonto = irk.protikonto
where (isnull(r.source_tbl, '') = '' or r.vrsta_dok = 'IFA')
--and irk.id_vrst_dod_str is not null
and (CASE WHEN r.dat_aktiv is null THEN 'N'  
				WHEN r.dat_aktiv is not null and r.znesek_se = 0 THEN 'Z'  
				ELSE 'A'  
				END) in ('A') -- aktivna razgranièenja 56 s troškovima, 89 bez troškova
select * from #gl_razmej_IFA

select * 
from dbo.gl g
inner join dbo.gl_raz_plan rp on g.id_source = rp.id_gl_raz_plan and g.source_tbl = 'gl_raz_plan'
where exists (select * from #gl_razmej_IFA where id_gl_razmej = rp.id_gl_razmej) --1132 uknjižbe za promjieniti, 1800 zapisa sa i bez troškova

drop table #gl_razmej_IFA