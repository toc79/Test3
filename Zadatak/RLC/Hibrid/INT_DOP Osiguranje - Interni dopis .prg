* NOVO
local lcid_cont, lcid_pon
lcid_cont=pogodba.id_cont
lcid_pon=pogodba.id_pon

TEXT TO lcSQL1 NOSHOW
Select a.id_obl_zav, a.opis
From dbo.dokument a 
inner join dbo.pogodba b on a.id_cont=b.id_cont 
inner join general_register c on c.id_register='RLC_LISTA_POLICA' and charindex(a.id_obl_zav,c.value)>0
where a.status_akt='A' and b.id_cont={0}
ENDTEXT

lcSQL1 = STRTRAN(lcSQL1, "{0}", TRANS(lcid_cont))
GF_SQLEXEC(lcSQL1,"_police")

TEXT TO lcSQL3 NOSHOW
select 
-- dbo.gfn_xchange('000',Case When p.je_foseba = 1 OR (nl.tip_knjizenja = 2 AND g.val_char = 'OV') Then p.neto*(1+(p.dav_vred_op/100))/*p.bruto*/ Else p.neto End, p.id_tec_n, p.dat_pon) as vrijednost_dom STARO MR 39200
dbo.gfn_xchange('000',Case When p.je_foseba = 1 OR (dbo.gfn_Nacin_leas_HR(p.nacin_leas) = 'F1' AND g.val_char = 'OV') Then p.neto*(1+(p.dav_vred_op/100))/*p.bruto*/ Else p.neto End, p.id_tec_n, p.dat_pon) as vrijednost_dom
from dbo.ponudba p
inner join dbo.general_register g on id_register = 'OSIG_PONUDA' AND 0 = g.neaktiven AND p.id_vrste = g.id_key 
--inner join dbo.nacini_l nl on p.nacin_leas = nl.nacin_leas
where p.id_pon={0}
ENDTEXT

lcSQL3 = STRTRAN(lcSQL3, "{0}", TRANS(lcid_pon))
GF_SQLEXEC(lcSQL3,"_osiguranja")

IF RECCOUNT("_police")=0 THEN 
APPEND BLANK IN _police
ENDIF

GF_SQLEXEC("select * from ponudba where id_pon="+gf_quotedstr(lcid_pon),"_cur_ponudba")


*Provjera podataka
select id_pon, p.nacin_leas,
dbo.gfn_xchange('000',Case When p.je_foseba = 1 OR (dbo.gfn_Nacin_leas_HR(p.nacin_leas) = 'F1' AND g.val_char = 'OV') Then p.neto*(1+(p.dav_vred_op/100))/*p.bruto*/ Else p.neto End, p.id_tec_n, p.dat_pon) as vrijednost_dom
, dbo.gfn_xchange('000',Case When p.je_foseba = 1 OR (nl.tip_knjizenja = 2 AND g.val_char = 'OV') Then p.neto*(1+(p.dav_vred_op/100))/*p.bruto*/ Else p.neto End, p.id_tec_n, p.dat_pon) as vrijednost_dom_STARO
from dbo.ponudba p
inner join dbo.general_register g on id_register = 'OSIG_PONUDA' AND 0 = g.neaktiven AND p.id_vrste = g.id_key 
inner join dbo.nacini_l nl on p.nacin_leas = nl.nacin_leas
order by id_pon desc

select NACIN_LEAS,* from pogodba where id_pon in (select id_pon from dbo.ponudba p
inner join dbo.general_register g on id_register = 'OSIG_PONUDA' AND 0 = g.neaktiven AND p.id_vrste = g.id_key 
inner join dbo.nacini_l nl on p.nacin_leas = nl.nacin_leas)
AND NACIN_LEAS = 'OF'


*STARO
local lcid_cont, lcid_pon
lcid_cont=pogodba.id_cont
lcid_pon=pogodba.id_pon

TEXT TO lcSQL1 NOSHOW
Select a.id_obl_zav, a.opis
From dbo.dokument a 
inner join dbo.pogodba b on a.id_cont=b.id_cont 
inner join general_register c on c.id_register='RLC_LISTA_POLICA' and charindex(a.id_obl_zav,c.value)>0
where a.status_akt='A' and b.id_cont={0}
ENDTEXT

lcSQL1 = STRTRAN(lcSQL1, "{0}", TRANS(lcid_cont))
GF_SQLEXEC(lcSQL1,"_police")

TEXT TO lcSQL3 NOSHOW
select 
dbo.gfn_xchange('000',Case When p.je_foseba = 1 OR (nl.tip_knjizenja = 2 AND g.val_char = 'OV') Then p.neto*(1+(p.dav_vred_op/100))/*p.bruto*/ Else p.neto End, p.id_tec_n, p.dat_pon) as vrijednost_dom
from dbo.ponudba p
inner join dbo.general_register g on id_register = 'OSIG_PONUDA' AND 0 = g.neaktiven AND p.id_vrste = g.id_key 
inner join dbo.nacini_l nl on p.nacin_leas = nl.nacin_leas
where p.id_pon={0}
ENDTEXT

lcSQL3 = STRTRAN(lcSQL3, "{0}", TRANS(lcid_pon))
GF_SQLEXEC(lcSQL3,"_osiguranja")

IF RECCOUNT("_police")=0 THEN 
APPEND BLANK IN _police
ENDIF

GF_SQLEXEC("select * from ponudba where id_pon="+gf_quotedstr(lcid_pon),"_cur_ponudba")