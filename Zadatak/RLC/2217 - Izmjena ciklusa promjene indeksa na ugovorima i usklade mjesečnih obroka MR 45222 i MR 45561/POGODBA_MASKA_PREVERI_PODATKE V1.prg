***********************************************************************************
*S promjenom kontrole na ovom mjestu, potrebno je promijeniti POGODBA_MASKA_SET_DEF_VALUES, POGODBA_UPDATE_PREVERI_PODATKE te provjeriti i POGODBA_MASKA_AFTER_INIT
* 14.06.2017 g_tomislav MR 36135 - Rind strategije
* 25.06.2020 g_tomislav MID 44956 - bugfix;
* 23.09.2020 g_tomislav MID 45222 - nova strategija zadnji radni dan u mjesecu  
***********************************************************************************
llfix_dat_rpg = LOOKUP(rtip.fix_dat_rpg, pogodba.id_rtip, rtip.id_rtip)

IF llfix_dat_rpg 
	LOCAL lcid_kupca, lcTip_leas, lcVr_osebe, lnObdobje_mes, lnDanUMjesecu, lnId_rind_strategije, ldNoviDan, ldRind_dat_next
	lcid_kupca = pogodba.id_kupca
	lcTip_leas = RF_TIP_POG(pogodba.nacin_leas)
	lnObdobje_mes = 12/LOOKUP(obdobja_lookup.obnaleto, GF_LOOKUP("rtip.id_obdrep", pogodba.id_rtip, "rtip.id_rtip"), obdobja_lookup.id_obd)
	GF_SQLEXEC("select vr_osebe from dbo.partner where id_kupca = "+GF_QUOTEDSTR(lcid_kupca),"_ef_vr_osebe")
	lcVr_osebe = _ef_vr_osebe.vr_osebe
	USE IN _ef_vr_osebe
	
	* Region Izračun rind_dat_next - ovaj dio koda je skoro isti kao u POGODBA_MASKA_SET_DEF_VALUES
	ldTarget_date = DATE()
	
	do case
		case lnObdobje_mes = 3
			lcCalcMonth = "datepart(quarter,'{0}') * 3"
		case lnObdobje_mes = 6
			lcCalcMonth = "case when datepart(month,'{0}') <= 6 then 1 else 2 end * 6"
		*otherwise ipak bez setiranja. Jednomjesečni euribor ne koriste, nemaju aktivnih ugovora
	endcase 
	
	lcSql = "select dbo.gfn_LastWorkDay(dbo.gfn_GetLastDayOfMonth(DATEFROMPARTS(year('{0}')," +lcCalcMonth +", day('{0}'))))"
	
	lcSQL1 = strtran(lcSql, "{0}", DTOS(ldTarget_date))
	ldZadnjiRadniDanZaRazdoblje = TTOD(GF_SQLEXECScalar(lcSQL1))
	
	IF (lcVr_osebe  == 'FO' or lcVr_osebe == 'F1') and lcTip_leas = 'F1' && kao na općim uvjetima
		
		select * from rind_strategije where odmik = 10 and !working_days into cursor _ef_rind_strategija_FO
		lnId_rind_strategije = _ef_rind_strategija_FO.id_rind_strategije
		lnDanUMjesecu = _ef_rind_strategija_FO.odmik
		use in _ef_rind_strategija_FO
		
		ldNoviDan = CTOD(ALLTRIM(STR(lnDanUMjesecu)+"/"+ALLTRIM(STR(MONTH(ldZadnjiRadniDanZaRazdoblje)))+"/"+ALLTRIM(STR(YEAR(ldZadnjiRadniDanZaRazdoblje)))))
		
		IF ldNoviDan < ldZadnjiRadniDanZaRazdoblje 
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
						
			lcSQL2 = strtran(lcSql, "{0}", DTOS(ldTarget_datePomak))
			ldRind_dat_next = TTOD(GF_SQLEXECScalar(lcSql2))
		ELSE 
			ldRind_dat_next = ldZadnjiRadniDanZaRazdoblje
		ENDIF
	ENDIF
	* END Region Izračun rind_dat_next
	
	IF pogodba.id_rind_strategije != lnId_rind_strategije OR pogodba.Rind_dat_next != ldRind_dat_next
		*if !potrjeno("Nije unešena odgovarajuća vrijednost Strategije reprograma. Želite li spremiti takav ugovor?")
		POZOR("Nije unesena odgovarajuća vrijednost Strategije reprograma. Automatski će se napraviti promjena na odgovarajuće vrijednosti:" +gce;
			+"Strategija reprograma: " +allt(lookup(rind_strategije.naziv, lnId_rind_strategije, rind_strategije.id_rind_strategije)) +gce;
			+"Slj. repr.: "+trans(ldRind_dat_next) )
			*SELECT cur_extfunc_error
			*REPLACE ni_napaka WITH .F. IN cur_extfunc_error
		*ENDIF
		*REPLACE pogodba.id_rind_strategije WITH lnId_rind_strategije IN pogodba
		*REPLACE pogodba.Rind_dat_next WITH ldRind_dat_next IN pogodba
		loForm.Pageframe1.Page2.cmbRindStrategije.Value = lnId_rind_strategije
		loForm.Pageframe1.Page2.txtRindDatNext.Value = ldRind_dat_next
		*Pozor("Strategija reprograma je postavljena na "+ALLT(STR(lnDanUMjesecu))+". dan u mjesecu!")
	ENDIF
ENDIF
* KRAJ Rind strategije
*********************