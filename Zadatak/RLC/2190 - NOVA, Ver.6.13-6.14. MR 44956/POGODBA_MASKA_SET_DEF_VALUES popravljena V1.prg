REPLACE pogodba.rind_tgor WITH 0 IN pogodba 
REPLACE pogodba.rind_zahte WITH .F. IN pogodba 
REPLACE pogodba.opc_datzad WITH 0 IN pogodba

***********************************************************************************
* provjera općih uvjeta MID 20434, kada se mjenjaju opći uvjeti treba uz na ovom mjestu zamijeniti i u PREVERI_PODATKE
* 15.03.2017 g_tomislav - dorada Opći uvjeti MR 37651
***********************************************************************************

LOCAL lcid_kupca, lcTip_leas, lcVr_osebe, lcSpl_pog01, lcSpl_pog02
lcid_kupca = ponudba.id_kupca
lcTip_leas = RF_TIP_POG(ponudba.nacin_leas)
GF_SQLEXEC("select vr_osebe from dbo.partner where id_kupca = "+GF_QUOTEDSTR(lcid_kupca),"_ef_vr_osebe")
GF_SQLEXEC("SELECT id_key, value FROM dbo.gfn_g_register('RLC_OPCI_UVJETI') WHERE neaktiven = 0", "_ef_opci_uvijeti")

lcVr_osebe = _ef_vr_osebe.vr_osebe
lcSpl_pog01 = ALLT(LOOK(_ef_opci_uvijeti.value, "01", _ef_opci_uvijeti.id_key))
lcSpl_pog02 = ALLT(LOOK(_ef_opci_uvijeti.value, "02", _ef_opci_uvijeti.id_key))
USE IN _ef_vr_osebe
USE IN _ef_opci_uvijeti

IF (lcVr_osebe  == 'FO' or lcVr_osebe == 'F1') and lcTip_leas = 'F1'
	REPLACE pogodba.spl_pog WITH lcSpl_pog01 IN pogodba 
ELSE
	REPLACE pogodba.spl_pog WITH lcSpl_pog02 IN pogodba 
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
* 14.06.2017 g_tomislav MR 36135 - Rind strategije; Sa promjenom kontrole na ovom mjestu, potrebno je promijeniti i POGODBA_MASKA_PREVERI PODATKE
* 25.06.2020 g_tomislav MID 44956 - bugfix;
***********************************************************************************
llfix_dat_rpg = LOOKUP(rtip.fix_dat_rpg, ponudba.id_rtip, rtip.id_rtip)

IF llfix_dat_rpg 
	LOCAL lcid_kupca, lcTip_leas, lcVr_osebe, lnObdobje_mes, lnStrategija10, lnStrategija25, lnDanUMjesecu, lnId_rind_strategije, ldRind_datum, lnRind_datumMonth, lnRind_datumYear, lcNoviDan, lnRind_dat_next
	lcid_kupca = ponudba.id_kupca
	lcTip_leas = RF_TIP_POG(ponudba.nacin_leas)
	lnObdobje_mes = 12/LOOKUP(obdobja_lookup.obnaleto, GF_LOOKUP("rtip.id_obdrep", ponudba.id_rtip, "rtip.id_rtip"), obdobja_lookup.id_obd)
	GF_SQLEXEC("select vr_osebe from dbo.partner where id_kupca = "+GF_QUOTEDSTR(lcid_kupca),"_ef_vr_osebe")
	lcVr_osebe = _ef_vr_osebe.vr_osebe
	USE IN _ef_vr_osebe
	
	lnStrategija10 = 10
	lnStrategija25 = 25
	
	IF (lcVr_osebe  == 'FO' or lcVr_osebe == 'F1' OR ponudba.je_foseba) and lcTip_leas = 'F1' && kao na općim uvjetima
		lnDanUMjesecu = lnStrategija10
	ELSE 
		lnDanUMjesecu = lnStrategija25
	ENDIF
	
	lnId_rind_strategije = LOOKUP(rind_strategije.id_rind_strategije, lnDanUMjesecu, rind_strategije.odmik)
	
	ldRind_datum = ponudba.rind_datum
	lnRind_datumMonth = MONTH(ldRind_datum)
	lnRind_datumYear = YEAR(ldRind_datum)
	lcNoviDan = CTOD(ALLTRIM(STR(lnDanUMjesecu)+"/"+ALLTRIM(STR(lnRind_datumMonth))+"/"+ALLTRIM(STR(lnRind_datumYear))))
	lnRind_dat_next = GOMONTH(lcNoviDan, lnObdobje_mes)
		
	REPLACE pogodba.id_rind_strategije WITH lnId_rind_strategije IN pogodba
	REPLACE pogodba.Rind_dat_next WITH lnRind_dat_next IN pogodba
		
ENDIF
* KRAJ Rind strategije
*********************