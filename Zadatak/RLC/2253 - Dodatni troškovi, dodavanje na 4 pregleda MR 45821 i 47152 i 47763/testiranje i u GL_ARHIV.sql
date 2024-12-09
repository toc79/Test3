select top 100 * 
from dbo.gl_razmej gr 
join dbo.ARH_GL_INPUT_RK rk on gr.ID_SOURCE = rk.ID_GL_INPUT_RK
where gr.source_tbl = 'GL_INPUT_RK'
order by gr.ID_GL_RAZMEJ desc


--uknjižbe razgraničenja ulaznih račna
select gl.id_source, gl.SOURCE_TBL,  * 
from dbo.gl gl
where st_dok = '20210000151'

--uknjižbe razgraničenja ulaznih račna
select gl.id_source, gl.SOURCE_TBL, rp.ID_GL_RAZ_PLAN, * 
from dbo.gl gl
full join dbo.GL_RAZ_PLAN rp on gl.ID_SOURCE = rp.ID_GL_RAZ_PLAN
inner join dbo.gl_razmej r on r.ID_GL_RAZMEJ = rp.ID_GL_RAZMEJ
inner join dbo.ARH_GL_INPUT_RK irk on r.id_source = irk.ID_GL_INPUT_RK 
where 1=1 
--and gl.SOURCE_TBL = 'GL_RAZ_PLAN'
and irk.id_vrst_dod_str is not null
and irk.id_vrst_dod_str = '01'
order by r.ID_GL_RAZMEJ

--uknjižbe razgraničenja ulaznih račna
select gl.id_source, gl.SOURCE_TBL, * 
from dbo.gl_arhiv gl
where ID_SOURCE=37089 and SOURCE_TBL= 'GL_RAZ_PLAN'

