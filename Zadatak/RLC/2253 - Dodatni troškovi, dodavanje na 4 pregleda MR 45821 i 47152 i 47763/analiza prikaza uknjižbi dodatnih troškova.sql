select * from dbo.arh_GL_INPUT_R where VRSTA_RAC= 'ful' and DATUM_KNJ >'20200101' 
order by DDV_ID desc

SELECT DISTINCT a.konto, b.cnt
	FROM dbo.VRST_DOD_STR a
	INNER JOIN (SELECT konto, COUNT(id_vrst_dod_str) as cnt FROM dbo.VRST_DOD_STR GROUP BY konto) b ON a.konto = b.konto
	UNION
	Select LTRIM(RTRIM(id)) as konto, CAST(1 as INT) as cnt From dbo.gfn_GetTableFromList ((Select val_char From dbo.general_register Where ID_KEY = 'RLC_REKLAS_DOD_STR' and neaktiven = 0))
	UNION
	Select LTRIM(RTRIM(id)) as konto, CAST(1 as INT) as cnt From dbo.gfn_GetTableFromList ((Select val_char From dbo.general_register Where ID_KEY = 'RLC_DOD_STR_KONTO_RAZMEJ' and neaktiven = 0))
	ORDER BY konto
select * from GL_RAZMEJ where ID_GL_RAZMEJ = 81
--select * from GL_K_DNEV

-- uknjižbe stavaka ulaznog raèuna (stavke netrebaju iæi po kontu za trošak, jedan trošak se knjiži na više konta ovisno i tipu leasinga)
--stavke imaju SOURCE_TBL GL_INPUT_RK         
--uknjižbe na dobavljaèa imaju SOURCE_TBL GL_INPUT_R          
select * 
from dbo.gl 
--inner join dbo.arh_GL_INPUT_R ir on gl.id_source = ir.ID_GL_INPUT_R
inner join  dbo.ARH_GL_INPUT_RK irk on gl.id_source = irk.ID_GL_INPUT_RK --ir.ID_GL_INPUT_R = irk.ID_GL_INPUT_R
where gl.SOURCE_TBL = 'gl_input_rk'
and irk.id_vrst_dod_str is not null
and irk.id_vrst_dod_str = '01'
order by GL.ID_SOURCE

--uknjižbe razgranièenja ulaznih raèna
select gl.id_source, gl.SOURCE_TBL, rp.ID_GL_RAZ_PLAN, * from dbo.gl gl
inner join dbo.GL_RAZ_PLAN rp on gl.ID_SOURCE = rp.ID_GL_RAZ_PLAN
inner join dbo.gl_razmej r on r.ID_GL_RAZMEJ = rp.ID_GL_RAZMEJ
inner join dbo.ARH_GL_INPUT_RK irk on r.id_source = irk.ID_GL_INPUT_RK and r.SOURCE_TBL = 'gl_input_rk'
where 1=1 
--and gl.SOURCE_TBL = 'GL_RAZ_PLAN'
and irk.id_vrst_dod_str is not null
and irk.id_vrst_dod_str = '01'
order by r.ID_GL_RAZMEJ


-- uknjižbe stavaka ulaznog raèuna (stavke netrebaju iæi po kontu za trošak, jedan trošak se knjiži na više konta npr. ovisno o tipu leasinga; stavke imaju SOURCE_TBL=GL_INPUT_RK; uknjižbe na dobavljaèa imaju SOURCE_TBL=GL_INPUT_R)         
select * 
from dbo.gl 
inner join  dbo.ARH_GL_INPUT_RK irk on gl.id_source = irk.ID_GL_INPUT_RK 
where gl.SOURCE_TBL = 'gl_input_rk'
and irk.id_vrst_dod_str is not null
and irk.id_vrst_dod_str = '01'
order by GL.ID_SOURCE

--uknjižbe razgranièenja ulaznih raèna
select gl.id_source, gl.SOURCE_TBL, rp.ID_GL_RAZ_PLAN, * 
from dbo.gl gl
inner join dbo.GL_RAZ_PLAN rp on gl.ID_SOURCE = rp.ID_GL_RAZ_PLAN
inner join dbo.gl_razmej r on r.ID_GL_RAZMEJ = rp.ID_GL_RAZMEJ
inner join dbo.ARH_GL_INPUT_RK irk on r.id_source = irk.ID_GL_INPUT_RK 
where 1=1 
and r.SOURCE_TBL = 'gl_input_rk'
and irk.id_vrst_dod_str is not null
and irk.id_vrst_dod_str = '01'
order by r.ID_GL_RAZMEJ



