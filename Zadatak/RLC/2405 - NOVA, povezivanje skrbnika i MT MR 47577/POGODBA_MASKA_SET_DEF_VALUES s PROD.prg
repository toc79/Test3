REPLACE pogodba.rind_tgor WITH 0 IN pogodba 
REPLACE pogodba.rind_zahte WITH .F. IN pogodba 
REPLACE pogodba.opc_datzad WITH 0 IN pogodba

***********************************************************************************
* provjera općih uvjeta MID 20434, kada se mjenjaju opći uvjeti treba uz na ovom mjestu zamijeniti i u PREVERI_PODATKE
* 15.03.2017 g_tomislav - dorada Opći uvjeti MR 37651
* 10.03.2021 g_vuradin - dorada Opći uvjeti MR 46394
***********************************************************************************
local   lcuvjeti

TEXT TO lcSQL46180 NOSHOW

declare @dat_sklen date 
set @dat_sklen = {4}

select 
--pon.id_kupca,pon.refinanc,pon.nacin_leas,pon.dat_sklen,part.vr_osebe,
  case when  pon.refinanc = 'EIB' then  (SELECT top 1  cast(value as varchar(100)) FROM dbo.general_register where neaktiven = 0 and val_char='EIB' and ID_REGISTER='RLC_OPCI_UVJETI' and val_datetime<=convert(date,{4},104) order by val_datetime desc) 
   when  pon.refinanc= 'HBOR' then  (SELECT top 1  cast(value as varchar(100)) FROM dbo.general_register where neaktiven = 0 and val_char='HBOR' and ID_REGISTER='RLC_OPCI_UVJETI' and val_datetime<=convert(date,{4},104) order by val_datetime desc)
   when  ((part.vr_osebe in ('FO','F1') or (pon.id_kupca=''  and pon.je_foseba = 1)) and pon.nacin_leas='F1') then  (SELECT top 1  cast(value as varchar(100)) FROM dbo.general_register where neaktiven = 0 and val_char='F1FO' and ID_REGISTER='RLC_OPCI_UVJETI' and val_datetime<=convert(date,{4},104)  order by val_datetime desc)
   when  ((part.vr_osebe not in ('FO','F1') or (pon.id_kupca='' and pon.je_foseba = 0)) and pon.nacin_leas='F1') then  (SELECT top 1  cast(value as varchar(100)) FROM dbo.general_register where neaktiven = 0 and val_char='F1PO' and ID_REGISTER='RLC_OPCI_UVJETI' and val_datetime<=convert(date,{4},104)  order by val_datetime desc)
	else (SELECT top 1  cast(value as varchar(100)) FROM dbo.general_register where neaktiven = 0 and val_char='OLFOPO' and ID_REGISTER='RLC_OPCI_UVJETI' and val_datetime<=convert(date,{4},104)  order by val_datetime desc)
                                         end  as uvjeti
 from dbo.PONUDBA pon
 left join dbo.PARTNER part on pon.id_kupca=part.id_kupca
 where pon.id_pon ={0}
  ENDTEXT

lcSQL46180 = STRTRAN(lcSQL46180, '{0}', gf_quotedstr(ponudba.ID_PON))
lcSQL46180 = STRTRAN(lcSQL46180, '{4}', gf_quotedstr(pogodba.DAT_SKLEN))


lcuvjeti= GF_SQLEXECSCALAR(lcSQL46180)

IF !GF_NULLOREMPTY(lcuvjeti)
	REPLACE pogodba.spl_pog WITH lcuvjeti  
ELSE
obvesti("Nema defiranih uvjeta!")
ENDIF

* KRAJ OPĆI UVJETI
*********************

******* DOZVOLJENI BROJ KM ************
* 30.03.2017 g_tomislav - dorada MR 37674 i 37797, da se povlače s ponude
* 08.09.2017 g_barbarak - dorada MR 38852
* 15.09.2017 g_barbarak - dorada MR 38927, po tipu leasinga i se_regis
LOCAL lnDovol_km, lnCena_dkm, lcTip_leas, lcSe_regis

GF_SQLEXEC("SELECT b.se_regis FROM dbo.ponudba a INNER JOIN dbo.vrst_opr b ON a.id_vrste=b.id_vrste WHERE a.id_pon ="+gf_quotedstr(ponudba.id_pon),"_vrsta_opreme")

lcTip_leas = RF_TIP_POG(ponudba.nacin_leas)
lnDovol_km = ponudba.Dovol_km
lnCena_dkm = ponudba.Cena_dkm
lcSe_regis = _vrsta_opreme.se_regis

IF lnDovol_km = 0 and lcTip_leas = 'OL' and lcSe_regis = '*'
	REPLACE pogodba.dovol_km WITH 25000 IN pogodba
ELSE
	REPLACE pogodba.dovol_km WITH lndovol_km IN pogodba
ENDIF

IF lncena_dkm = 0.00 and lcTip_leas = 'OL' and lcSe_regis = '*'
	REPLACE pogodba.cena_dkm WITH 0.15 IN pogodba
ELSE
	REPLACE pogodba.cena_dkm WITH lncena_dkm IN pogodba
ENDIF

* KRAJ DOZVOLJENI BROJ KM 
**************************

*********************************************
* 16.05.2016 g_tomislav - MR 35121 
local lcId_odobrit 
lcId_odobrit = pogodba.id_odobrit

IF ! gf_nullorempty(lcId_odobrit) 
	GF_SQLEXEC("SELECT a.id_cont, a.id_odobrit FROM dbo.Odobrit a JOIN dbo.pogodba b ON a.id_odobrit=b.ID_ODOBRIT WHERE a.ID_ODOBRIT ="+gf_quotedstr(lcId_odobrit),"_ef_odobrit")
	select _ef_odobrit
	IF RECCOUNT() > 0
		pozor ('Za ovo odobrenje već postoji ugovor. Molim provjeru podataka!')
	ENDIF
	use in _ef_odobrit
ENDIF
*******END MR 35121**************************************

***********************************************************************************
*S promjenom kontrole na ovom mjestu, potrebno je promijeniti i POGODBA_MASKA_PREVERI_PODATKE, POGODBA_UPDATE_PREVERI_PODATKE te provjeriti i POGODBA_MASKA_AFTER_INIT
* 14.06.2017 g_tomislav MID 36135 - Rind strategije
* 25.06.2020 g_tomislav MID 44956 - bugfix;
* 01.10.2020 g_tomislav MID 45222 - nova strategija zadnji radni dan u mjesecu
* 21.10.2020 g_tomislav	MID 45655 - bugfix: zamijenjena varijabla ldZadnjiRadniDanZaRazdoblje s ldTarget_date pa je sada izraz ldNoviDan < ldTarget_date
* 27.10.2020 g_tomislav MID 45222 - micanje kontrole koja postavlja vrijednosti jer su suvišna. Sada se postavljanje radi u POGODBA_MASKA_RIND_STRATEGIJE_LOSTFOCUS
* KRAJ Rind strategije*************************************************************

