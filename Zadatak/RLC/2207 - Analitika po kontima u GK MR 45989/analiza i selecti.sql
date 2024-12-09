select id_krov_pog, * from dbo.kred_pog where id_krov_pog is not null or id_krov_pog != ''
select * from dbo.gl where interna_veza = '0180 16'
select INTERNA_VEZA, ST_DOK,* from dbo.gl where id_gl =4103500

--1. Sve uknjižbe koje su vezane na kreditni ugovor vezani na krovni i u st_dok se nalazi broj krovnog ugovora=> treba napraviit update interne veze na kp.id_krov_pog
select kp.ID_KREDPOG Kreditni_ug, ST_DOK Broj_dokumenta_gl, kp.id_krov_pog Krovni_ug, INTERNA_VEZA Interna_veza_gl, GL.ST_DOK as Nova_interna_veza
, GL.OPISDOK OPIS_DOK, GL.VEZA Veza_gl, gl.njihova_st as Njinov_br, GL.SOURCE_TBL SOURCE_TBL_gl, GL.ID_SOURCE as ID_SOURCE_gl
, GL.* 
from dbo.gl 
join dbo.kred_pog kp on GL.ST_DOK = kp.ID_KREDPOG /*left*/ 
where (id_krov_pog is not null or id_krov_pog != '')
and GL.INTERNA_VEZA!=GL.st_dok --uknjižbe vezane na krovni ugovor
and exists(select * from dbo.kred_pog where id_krov_pog = gl.interna_veza)
order by gl.konto, GL.st_dok, GL.id_gl

-- 2. sve ostale uknjižbe za konta iz excela => NOVO
select '' as Nova_interna_veza, ST_DOK Broj_dokumenta_gl, INTERNA_VEZA Interna_veza_gl
, gl2.OPISDOK OPIS_DOK, gl2.VEZA Veza_gl, gl2.njihova_st as Njinov_br, gl2.SOURCE_TBL SOURCE_TBL_gl, gl2.ID_SOURCE as ID_SOURCE_gl
, gl2.* 
from dbo.gl gl2 where 1=1
and st_dok!=INTERNA_VEZA
and not exists (select * from dbo.gl 
	join dbo.kred_pog kp on GL.ST_DOK = kp.ID_KREDPOG /*left*/ 
	where (id_krov_pog is not null or id_krov_pog != '')
	and GL.INTERNA_VEZA!=GL.st_dok --uknjižbe vezane na krovni ugovor
	and ID_GL = GL2.id_gl)
and konto in ('251001','251002','251201','251202','251203','251204','961001','961002','962001','252001'
,'252221','190402','190414','190416','190418','190420','190422','720100','720001','720004','720015'
,'720016','720017','720018','720019','720050','721106')
order by gl2.konto, GL2.st_dok, GL2.id_gl

--3.  tj. 4
select '' as Nova_interna_veza, ST_DOK Broj_dokumenta_gl, INTERNA_VEZA Interna_veza_gl
, gl2.OPISDOK OPIS_DOK, gl2.VEZA Veza_gl, gl2.njihova_st as Njinov_br, gl2.SOURCE_TBL SOURCE_TBL_gl, gl2.ID_SOURCE as ID_SOURCE_gl
, gl2.* 
from dbo.gl gl2 where 1=1
and st_dok!=INTERNA_VEZA
and not exists (select * from dbo.gl 
	join dbo.kred_pog kp on GL.ST_DOK = kp.ID_KREDPOG /*left*/ 
	where (id_krov_pog is not null or id_krov_pog != '')
	and GL.INTERNA_VEZA!=GL.st_dok --uknjižbe vezane na krovni ugovor
	and kp.ID_KREDPOG = GL.st_dok --Broj dokumenta jednak kreditnom ugovoru => isto je sa i bez tog uvjeta
	and ID_GL = GL2.id_gl)
and konto in ('251001','251002','251201','251202','251203','251204','961001','961002','962001','252001'
,'252221','190402','190414','190416','190418','190420','190422','720100','720001','720004','720015'
,'720016','720017','720018','720019','720050','721106')
and charindex(gl2.INTERNA_VEZA, gl2.OPISDOK) = 0
order by gl2.konto, GL2.st_dok, GL2.id_gl


--5 arhiv 1 . Sve uknjižbe koje su vezane na kreditni ugovor vezani na krovni i u st_dok se nalazi broj krovnog ugovora=> treba napraviit update interne veze na kp.id_krov_pog
select kp.ID_KREDPOG Kreditni_ug, ST_DOK Broj_dokumenta_gl, kp.id_krov_pog Krovni_ug, INTERNA_VEZA Interna_veza_gl, GL.ST_DOK as Nova_interna_veza
, GL.OPISDOK OPIS_DOK, GL.VEZA Veza_gl, gl.njihova_st as Njinov_br, GL.SOURCE_TBL SOURCE_TBL_gl, GL.ID_SOURCE as ID_SOURCE_gl
, GL.* 
from dbo.gl_arhiv gl 
join dbo.kred_pog kp on GL.ST_DOK = kp.ID_KREDPOG /*left*/ 
where (id_krov_pog is not null or id_krov_pog != '')
and GL.INTERNA_VEZA!=GL.st_dok --uknjižbe vezane na krovni ugovor
and exists(select * from dbo.kred_pog where id_krov_pog = gl.interna_veza)
and YEAR = '2019'
order by gl.konto, GL.st_dok, GL.id_gl

--NAPRAVITI novi select za 6 na temelju 4 za 2019 nisam ga prebacio....


select * from dbo.GL_RAZ_PLAN where ID_GL_RAZ_PLAN=16433
select * from dbo.GL_RAZmej where ID_GL_RAZMEJ=572
select * from dbo.rac_in where DDV_id ='N2018000199 '--20180008591' --select * from dbo.rac_out where DDV_id ='20180008591'
--neke uknjižbe imaju u st_dok broj ulaznog računa i tamo je zapisano u Opisu na koji KU s eodnosi, mada piše i krovni ugovor
--treba napraviti da se opisdok replace ENTERe sa '' ili probati kroz leasing prebaciti podatke
--provjeriti  107_veza razgr 1013  	0184 17	000413809            	commit.fee EBRD 0184 17 (krovni 0175 16)-do12/2021


--Imaju krovne ugovore i uknjižbe za njih, a isti nemaju niti jedan kreditni vezani na krovni
--0234 20 nema kreditni vezan na njega
select * from dbo.kred_pog where id_krov_pog ='0234 20'-- 0 zapisa
select distinct id_krov_pog from dbo.kred_pog where (id_krov_pog is not null or id_krov_pog != '')
id_krov_pog
0126 12        
0140 13        
0150 15        
0160 15        
0175 16        
0180 16        
0182 17        
0184 17        
0200 18        
0208 18        
0214 19     

--Imaju kredite ugovore koji imaju ulazni račun i u njemu upisanu vezu u vr_rac_veza

select id_krov_pog, * from dbo.kred_pog where (id_krov_pog is not null or id_krov_pog != '')
id_krov_pog	ID_KREDPOG
0126 12        	0124 12        
0126 12        	0127 12        
0126 12        	0132 13        
0140 13        	0147 14        
0150 15        	0153 15        
0150 15        	0155 15        
0150 15        	0158 15        
0150 15        	0162 16        
0140 13        	0163 16        
0140 13        	0164 16        
0160 15        	0168 16        
0160 15        	0171 16        
0160 15        	0172 16        
0175 16        	0176 16        
0160 15        	0179 16        
0175 16        	0183 17        
0175 16        	0186 17        
0184 17        	0187 17        
0182 17        	0188 17        
0184 17        	0189 17        
0182 17        	0190 17        
0184 17        	0191 17        
0175 16        	0192 17        
0182 17        	0194 18        
0182 17        	0195 18        
0182 17        	0199 18        
0200 18        	0201 18        
0180 16        	0202 18        
0200 18        	0203 18        
0182 17        	0204 18        
0180 16        	0205 18        
0200 18        	0206 18        
0182 17        	0207 18        
0208 18        	0209 19        
0208 18        	0210 19        
0208 18        	0211 19        
0208 18        	0212 19        
0208 18        	0215 19        
0175 16        	0216 19        
0175 16        	0217 19        
0214 19        	0221 19        
0214 19        	0222 19        
0180 16        	0223 19        
0208 18        	0224 19        
0208 18        	0225 19        
0182 17        	0226 19        
0214 19        	0227 19        
0214 19        	0228 19        
0208 18        	0229 19        
0208 18        	0230 19        
0214 19        	0231 19        
0180 16        	0232 19        
0214 19        	0233 19        
0180 16        	0236 20        
0180 16        	0238 20        
0180 16        	0242 20               
