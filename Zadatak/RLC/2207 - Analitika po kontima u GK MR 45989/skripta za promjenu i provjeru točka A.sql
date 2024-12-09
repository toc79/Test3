NAPRAVI PRVO BACKUP PODATAKA

drop table #gl_provjera
select kp.ID_KREDPOG Kreditni_ug, ST_DOK Broj_dokumenta_gl, kp.id_krov_pog Krovni_ug, INTERNA_VEZA Interna_veza_gl, GL.ST_DOK as Nova_interna_veza
, GL.OPISDOK OPIS_DOK, GL.VEZA Veza_gl, gl.njihova_st as Njinov_br, GL.SOURCE_TBL SOURCE_TBL_gl, GL.ID_SOURCE as ID_SOURCE_gl
, GL.* 
into #gl_provjera
from dbo.gl 
join dbo.kred_pog kp on GL.ST_DOK = kp.ID_KREDPOG /*left*/ 
where (id_krov_pog is not null or id_krov_pog != '')
and GL.INTERNA_VEZA!=GL.st_dok --uknjižbe vezane na krovni ugovor
and exists(select * from dbo.kred_pog where id_krov_pog = gl.interna_veza)
order by gl.konto, GL.st_dok, GL.id_gl

begin tran
UPDATE dbo.GL set interna_veza = GL.st_dok
--select kp.ID_KREDPOG Kreditni_ug, ST_DOK Broj_dokumenta_gl, kp.id_krov_pog Krovni_ug, INTERNA_VEZA Interna_veza_gl, GL.ST_DOK as Nova_interna_veza
--, GL.OPISDOK OPIS_DOK, GL.VEZA Veza_gl, gl.njihova_st as Njinov_br, GL.SOURCE_TBL SOURCE_TBL_gl, GL.ID_SOURCE as ID_SOURCE_gl
--, GL.* 
from dbo.gl gl
join dbo.kred_pog kp on GL.ST_DOK = kp.ID_KREDPOG /*left*/ 
where (id_krov_pog is not null or id_krov_pog != '')
and GL.INTERNA_VEZA!=GL.st_dok --uknjižbe vezane na krovni ugovor
and exists(select * from dbo.kred_pog where id_krov_pog = gl.interna_veza)

select kp.ID_KREDPOG Kreditni_ug, ST_DOK Broj_dokumenta_gl, kp.id_krov_pog Krovni_ug, INTERNA_VEZA Interna_veza_gl, GL.ST_DOK as Nova_interna_veza
, GL.OPISDOK OPIS_DOK, GL.VEZA Veza_gl, gl.njihova_st as Njinov_br, GL.SOURCE_TBL SOURCE_TBL_gl, GL.ID_SOURCE as ID_SOURCE_gl
, GL.* 
from dbo.gl 
left join dbo.kred_pog kp on GL.ST_DOK = kp.ID_KREDPOG /*left*/ 
where 1=1 --(id_krov_pog is not null or id_krov_pog != '')
and GL.INTERNA_VEZA=GL.st_dok --uknjižbe vezane na krovni ugovor
and exists (select * from #gl_provjera where id_gl = gl.id_gl)
order by gl.konto, GL.st_dok, GL.id_gl

--Select ispod treba vratiti 0 zapisa
select kp.ID_KREDPOG Kreditni_ug, ST_DOK Broj_dokumenta_gl, kp.id_krov_pog Krovni_ug, INTERNA_VEZA Interna_veza_gl, GL.ST_DOK as Nova_interna_veza
, GL.OPISDOK OPIS_DOK, GL.VEZA Veza_gl, gl.njihova_st as Njinov_br, GL.SOURCE_TBL SOURCE_TBL_gl, GL.ID_SOURCE as ID_SOURCE_gl
, GL.* 
from dbo.gl 
join dbo.kred_pog kp on GL.ST_DOK = kp.ID_KREDPOG /*left*/ 
where (id_krov_pog is not null or id_krov_pog != '')
and GL.INTERNA_VEZA!=GL.st_dok --uknjižbe vezane na krovni ugovor
and exists(select * from dbo.kred_pog where id_krov_pog = gl.interna_veza)
order by gl.konto, GL.st_dok, GL.id_gl

--rollback
--commit


--PROVJERA ZA 2019 GODINU U GL_ARHIV

select kp.ID_KREDPOG Kreditni_ug, ST_DOK Broj_dokumenta_gl, kp.id_krov_pog Krovni_ug, INTERNA_VEZA Interna_veza_gl, GL.ST_DOK as Nova_interna_veza
, GL.OPISDOK OPIS_DOK, GL.VEZA Veza_gl, gl.njihova_st as Njinov_br, GL.SOURCE_TBL SOURCE_TBL_gl, GL.ID_SOURCE as ID_SOURCE_gl
, GL.* 
from dbo.GL_ARHIV gl 
join dbo.kred_pog kp on GL.ST_DOK = kp.ID_KREDPOG /*left*/ 
where (id_krov_pog is not null or id_krov_pog != '')
and GL.INTERNA_VEZA!=GL.st_dok --uknjižbe vezane na krovni ugovor
and exists(select * from dbo.kred_pog where id_krov_pog = gl.interna_veza)
and [YEAR]= 2019
order by gl.konto, GL.st_dok, GL.id_gl


select VNOS_INT_VEZA,* from dbo.AKONPLAN where KONTO in (
select distinct gl.konto
from dbo.GL_ARHIV gl 
join dbo.kred_pog kp on GL.ST_DOK = kp.ID_KREDPOG /*left*/ 
where (id_krov_pog is not null or id_krov_pog != '')
and GL.INTERNA_VEZA!=GL.st_dok --uknjižbe vezane na krovni ugovor
and exists(select * from dbo.kred_pog where id_krov_pog = gl.interna_veza)
and [YEAR]= 2019)

select INTERNA_VEZA, ST_DOK, * from dbo.gl where vrsta_dok = 'otv' and konto in ('252001','961002')
INTERNA_VEZA	ST_DOK	ID_GL	KONTO	PROTIKONTO	ID_KUPCA	ID_STRM	DATUM_DOK	VRSTA_DOK
0150 15	000-252001-013555    	3935520	252001  	        	013555	0010	2020-01-01 00:00:00.000	OTV

select INTERNA_VEZA, ST_DOK, * from dbo.gl where vrsta_dok = 'otv' and konto in ('251204  ','251001', '251002')

Provjeriti još za jedan slučaj interna veza 0150 15 konto 252001  
select INTERNA_VEZA, ST_DOK as st_dok2, * from dbo.GL_ARHIV where konto in ('252001') and INTERNA_VEZA ='0150 15' and YEAR=2019  order by st_dok
INTERNA_VEZA	st_dok2	ID_GL	KONTO	PROTIKONTO	ID_KUPCA	ID_STRM	DATUM_DOK	VRSTA_DOK
0150 15	0153 15              	3868440	252001  	962001  	013555	0020	2019-10-31 00:00:00.000	TEM
0150 15	0155 15              	3868444	252001  	962001  	013555	0020	2019-10-31 00:00:00.000	TEM





