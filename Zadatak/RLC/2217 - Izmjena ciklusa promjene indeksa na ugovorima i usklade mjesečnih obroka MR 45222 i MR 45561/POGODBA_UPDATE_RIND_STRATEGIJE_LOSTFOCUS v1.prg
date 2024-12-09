loForm = GF_GetFormObject("frmActiveContractUpdate") 
IF ISNULL(loForm) THEN 
 RETURN
ENDIF

***********************************************************************************
* S promjenom kontrole na ovom mjestu, potrebno je promijeniti i POGODBA_MASKA_SET_DEF_VALUES, POGODBA_MASKA_RIND_STRATEGIJE_LOSTFOCUS, POGODBA_MASKA_PREVERI_PODATKE, POGODBA_UPDATE_PREVERI_PODATKE te provjeriti i POGODBA_MASKA_AFTER_INIT
* 22.10.2020 g_tomislav MID 45222 - Rind_strategije  
***********************************************************************************
LOCAL lcid_kupca, lcTip_leas, lcVr_osebe, lnObdobje_mes, lnDanUMjesecu, lnId_rind_strategije, ldNoviDan, ldRind_dat_next
lcid_kupca = pogodba.id_kupca
lcTip_leas = RF_TIP_POG(pogodba.nacin_leas)
lnObdobje_mes = 12/LOOKUP(obdobja.obnaleto, GF_LOOKUP("rtip.id_obdrep", pogodba.id_rtip, "rtip.id_rtip"), obdobja.id_obd)
lcVr_osebe = GF_SQLEXECScalar("select vr_osebe from dbo.partner where id_kupca = "+GF_QUOTEDSTR(lcid_kupca))
 
* Region Izračun rind_dat_next - ovaj dio koda je isti kao u POGODBA_MASKA_SET_DEF_VALUES, ali je izbačen kursor ponudba
ldTarget_date = DATE()

do case
	case lnObdobje_mes = 3
		lcCalcMonth = "datepart(quarter,'{0}') * 3"
	case lnObdobje_mes = 6
		lcCalcMonth = "case when datepart(month,'{0}') <= 6 then 1 else 2 end * 6"
	*otherwise ipak bez setiranja. Jednomjesečni euribor ne koriste, nemaju aktivnih ugovora
endcase 

lcSql45222 = "select dbo.gfn_LastWorkDay(dbo.gfn_GetLastDayOfMonth(DATEFROMPARTS(year('{0}')," +lcCalcMonth +", day('{0}'))))"

lcSQL45222_1 = strtran(lcSql45222, "{0}", DTOS(ldTarget_date))
ldZadnjiRadniDanZaRazdoblje = TTOD(GF_SQLEXECScalar(lcSQL45222_1))

IF (lcVr_osebe  == 'FO' or lcVr_osebe == 'F1') and lcTip_leas = 'F1' && kao na općim uvjetima
	
	select * from rind_strategije where odmik = 10 and !working_days into cursor _ef_rind_strategija_FO
	lnId_rind_strategije = _ef_rind_strategija_FO.id_rind_strategije
	lnDanUMjesecu = _ef_rind_strategija_FO.odmik
	use in _ef_rind_strategija_FO
	
	ldNoviDan = CTOD(ALLTRIM(STR(lnDanUMjesecu)+"/"+ALLTRIM(STR(MONTH(ldZadnjiRadniDanZaRazdoblje)))+"/"+ALLTRIM(STR(YEAR(ldZadnjiRadniDanZaRazdoblje)))))
	
	IF ldNoviDan < ldTarget_date 
		ldRind_dat_next = GOMONTH(ldNoviDan, lnObdobje_mes) && pomak za razdoblje (kao što je bilo do sada)
	ELSE
		ldRind_dat_next = ldNoviDan
	ENDIF
	
ELSE 
	select * from rind_strategije where odmik = 0 and !working_days into cursor _ef_rind_strategija_PO
	lnId_rind_strategije = _ef_rind_strategija_PO.id_rind_strategije
	use in _ef_rind_strategija_PO	
	
	IF ldZadnjiRadniDanZaRazdoblje < ldTarget_date 
		ldTarget_datePomak = GOMONTH(ldTarget_date, lnObdobje_mes) && pomak za razdoblje (kao što je bilo do sada)
					
		lcSQL45222_2 = strtran(lcSql45222, "{0}", DTOS(ldTarget_datePomak))
		ldRind_dat_next = TTOD(GF_SQLEXECScalar(lcSql45222_2))
	ELSE 
		ldRind_dat_next = ldZadnjiRadniDanZaRazdoblje
	ENDIF
ENDIF
* END Region Izračun rind_dat_next

IF pogodba.id_rind_strategije != lnId_rind_strategije OR pogodba.Rind_dat_next != ldRind_dat_next
	POZOR("Nije unešena odgovarajuća vrijednost Strategije reprograma. Odgovarajuće vrijednosti su:" +gce;
		+"Strategija reprograma: " +allt(lookup(rind_strategije.naziv, lnId_rind_strategije, rind_strategije.id_rind_strategije)) +gce;
		+"Slj. repr.: "+trans(ldRind_dat_next) +gce;
		+"Navedene vrijednosti će se sada postaviti!")
	loForm.pgfPogodba.pagSplosni.txtrindDatNext.Value = ldRind_dat_next
	loForm.pgfPogodba.pagSplosni.cmbRindStrategije.Value = lnId_rind_strategije
ENDIF
* KRAJ Rind strategije
*********************