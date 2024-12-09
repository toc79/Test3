Local loForm
loForm = GF_GetFormObject('frmPogodba_akt')

** Created: unknown
LOCAL ldDatAkt, ldDatPot
ldDatAkt = loForm.datumakt
ldDatPot = pogodba.DAT_PODPISA

IF GF_NULLOREMPTY(ldDatPot) OR ldDatAkt < ldDatPot
	IF !POTRJENO("Datum aktivacije je manji od datuma potpisa ugovora, da li želite aktivirati ugovor?")
		RETURN .F.
	ENDIF 
ENDIF

***********************************************************************************
* 25.11.2022 g_tomislav MID 49629 - Rind_strategije: provjera i promjena datuma sljedećeg reprograma 
***********************************************************************************
LOCAL lnId_cont
lcId_cont = loForm.id_cont

TEXT TO lcSql NOSHOW
	declare @today datetime = dbo.gfn_GetDatePart(getdate())
	select --case when par.vr_osebe in ('FO', 'F1') and dbo.gfn_Nacin_leas_HR(pog.nacin_leas) = 'F1' then cast(DATEFROMPARTS(year(@today), month(@today), 10) as datetime)
			--else dbo.gfn_LastWorkDay(dbo.gfn_GetLastDayOfMonth(@today)) end as Correct_rind_dat_next --alternativa je EOMONTH
		cast(rs.naziv as varchar(75)) as rind_strategije_naziv 
		, pog.rind_dat_next 
		, pog.id_cont, dbo.gfn_GetContractDataHash(pog.id_cont) as pogodba_hash 
		, pog.id_rind_strategije
		, dbo.gfn_Nacin_leas_HR(pog.nacin_leas) as tip_leas
		, 12/obd_r.obnaleto as obdobje_mes
		, par.vr_osebe
	from dbo.pogodba pog
	inner join dbo.rtip r on pog.id_rtip = r.id_rtip
	inner join dbo.obdobja as obd_r on r.id_obdrep = obd_r.id_obd
	inner join dbo.partner par on pog.id_kupca = par.id_kupca
	left join dbo.rind_strategije rs on pog.id_rind_strategije = rs.id_rind_strategije
	where r.fix_dat_rpg = 1
	and pog.id_cont = {0}
ENDTEXT 
lcSql = STRTRAN(lcSql, '{0}', ALLT(STR(lcId_cont))) 
GF_SQLEXEC(lcSql, "_ef_pogodba")

IF RECCOUNT("_ef_pogodba") > 0 
	lcTip_leas = _ef_pogodba.tip_leas &&RF_TIP_POG(pogodba.nacin_leas)
	lnObdobje_mes = _ef_pogodba.obdobje_mes && 12/LOOKUP(obdobja_lookup.obnaleto, GF_LOOKUP("rtip.id_obdrep", pogodba.id_rtip, "rtip.id_rtip"), obdobja_lookup.id_obd)
	lcVr_osebe = _ef_pogodba.vr_osebe && GF_SQLEXECScalar("select vr_osebe from dbo.partner where id_kupca = "+GF_QUOTEDSTR(lcid_kupca))
	GF_SQLEXEC("select * from dbo.rind_strategije", "rind_strategije")
	
	* Region Izračun rind_dat_next
	ldTarget_date = DATE()

	do case
		case lnObdobje_mes = 3
			lcCalcMonth = "datepart(quarter,'{0}') * 3"
		case lnObdobje_mes = 6
			lcCalcMonth = "case when datepart(month,'{0}') <= 6 then 1 else 2 end * 6"
		*otherwise ipak bez setiranja. Jednomjesečni euribor ne koriste, nemaju aktivnih ugovora
	endcase 

	lcSql45222 = "select dbo.gfn_LastWorkDay(dbo.gfn_GetLastDayOfMonth(DATEFROMPARTS(year('{0}')," +lcCalcMonth +", 1)))"

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
	* lnId_rind_strategije && ovo ne treba u ovoj kontroli
	* ldRind_dat_next

	IF NVL(TTOD(_ef_pogodba.rind_dat_next), {03.03.1903}) != ldRind_dat_next && null datumi su mogući kod starih podataka
		IF POTRJENO("Ugovor se ne može aktivirati jer nema odgovarajuću vrijednost datuma sljedećeg reprograma koji bi trebao biti " +trans(ldRind_dat_next) +"! Trenutne vrijednosti su:" +gce;
				+"Strategija reprograma: " +allt(_ef_pogodba.rind_strategije_naziv) +gce;
				+"Slj. repr.: "+trans(TTOD(_ef_pogodba.rind_dat_next)) +gce;
				+"Da li želite napraviti promjenu Datuma sljedećeg reprograma i nastaviti s aktivacijom?")

			SELE _ef_pogodba
		
			local lcpogodba_hash, lcNovaVrijednost, lnid_cont, lcOpomba, lcid_category, lcXML, tcXMLStrDobr

			lcpogodba_hash = _ef_pogodba.pogodba_hash
			lcNovaVrijednost = ldRind_dat_next
			lnid_cont = _ef_pogodba.id_cont
			lcOpomba = "Automatska promjena datuma sljedećeg reprograma kod aktivacije"
			lcid_category = "999"

			GF_SQLEXEC("select * from pogodba where id_cont="+GF_QuotedStr(lnid_cont),"_pogodba")
			GF_SQLEXEC("Select * From pogodba where id_cont="+GF_QuotedStr(lnid_cont),"_pogodba_copy")

			replace rind_dat_next with lcNovaVrijednost in _pogodba

			lcXML = GF_CreateContractUpdateXML(lnid_cont, ALLTRIM(lcOpomba), lcpogodba_hash, lcid_category, "_pogodba", "_pogodba_copy")  && 7 parametar je * tbFourEyes - set use_4eyes depends on form check; .f. znači da nema provjere 4 oka

			IF LEN(ALLTRIM(lcXml)) > 0 THEN
				IF GF_ProcessXML(lcXML) THEN
					OBVESTI("Datum sljedećeg reprograma je promijenjen na " +trans(ldRind_dat_next) +".")
				ELSE
					POZOR("Došlo je do greške. Datum sljedećeg reprograma NIJE promijenjen!")
				ENDIF
			ELSE
				POZOR("Datum je već bio promijenjen na " +trans(ldRind_dat_next) +"!")
			ENDIF
			use in _pogodba
			use in _pogodba_copy
		ELSE 
			RETURN .F.
		ENDIF
	ENDIF
ENDIF
* KRAJ - Rind_strategije
***********************************************************************************
* 20.02.2023 - g_tkovacev, MR #50155, kontrola unesenog datuma indeksa kamate i automatska korekcija unesenog datuma

lcDatum = pogodba.rind_datum
lcId_rtip = pogodba.id_rtip
lcId_cont = pogodba.id_cont
lcOpomba = "Automatska promjena datuma indeksa kamate kod aktivacije"
lcId_category = "999"

IF ALLT(lcId_rtip) <> '0'
	TEXT TO lcSql NOSHOW
		SELECT 
			dbo.gfn_LastWorkDay(
			CASE 12 / FLOOR(obd.obnaleto)
			WHEN 6 THEN IIF(YEAR(DATEADD(MONTH, -6, GETDATE())) < YEAR(GETDATE()), DATEADD(yy, DATEDIFF(yy, 0, DATEADD(MONTH, -6, GETDATE())) + 1, -1), EOMONTH(DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0), 5))
			WHEN 3 THEN DATEADD(QUARTER, DATEDIFF(QUARTER, 0, GETDATE()), 0) - 1
			WHEN 1 THEN IIF(MONTH(GETDATE()) = 1, DATEADD(DAY, -1, DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0)), EOMONTH(GETDATE(), -1))
			END) AS datum_value,
			dbo.gfn_GetContractDataHash(pog.id_cont) AS pogodba_hash
		FROM dbo.pogodba pog
		JOIN dbo.rtip r ON pog.id_rtip = r.id_rtip
		JOIN dbo.obdobja obd ON r.id_obdrep = obd.id_obd
		WHERE pog.id_cont = {0}
	ENDTEXT

	lcSql = STRTRAN(lcSql, '{0}', ALLT(STR(lcId_cont)))
	GF_SQLEXEC(lcSql, "_ef_pog")

	IF lcDatum != _ef_pog.datum_value
		POZOR("Trenutni datum indeksa kamate je " + DTOC(lcDatum) + ". Automatizmom će se izmijeniti u " + DTOC(_ef_pog.datum_value))
		GF_SQLEXEC("select * from pogodba where id_cont="+GF_QuotedStr(lcId_cont),"_pogodba")
		GF_SQLEXEC("select * from pogodba where id_cont="+GF_QuotedStr(lcId_cont),"_pogodba_copy")
		
		lcHash = _ef_pog.pogodba_hash
		lcNew_date = _ef_pog.datum_value

		replace rind_datum with lcNew_date in _pogodba
		
		lcXML = GF_CreateContractUpdateXML(lcId_cont, ALLTRIM(lcOpomba), lcHash, lcId_category, "_pogodba", "_pogodba_copy")  && 7 parametar je * tbFourEyes - set use_4eyes depends on form check; .f. znači da nema provjere 4 oka

		IF LEN(ALLTRIM(lcXML)) > 0 THEN
			IF GF_ProcessXML(lcXML) THEN
				OBVESTI("Datum indeksa kamate je promijenjen na " + dtoc(_ef_pog.datum_value) +".")
			ELSE
				POZOR("Došlo je do greške. Datum indeksa kamate NIJE promijenjen!")
			ENDIF
			use in _pogodba
			use in _pogodba_copy
		ENDIF
	ENDIF
ENDIF
**********************************KRAJ KONTROLE***********************************
**MR50725 g_igorp - generiranje poruke za interkalarnu kamatu kod financijskog leasinga za fizičke osobe

LOCAL lcVrOsebe, lcTipLeas
lcVrOsebe = GF_SQLEXECSCALARNULL("SELECT dbo.gfn_GetVrOsebeSIFRA_forContract(" + STR(pogodba.id_cont) + ")")
lcTipLeas = GF_SQLEXECSCALARNULL("SELECT dbo.gfn_Nacin_leas_HR("+ GF_QUOTEDSTR(pogodba.nacin_leas) +")")

*=OBVESTI(ALLT(lcVrOsebe))
*=OBVESTI(ALLT(lcTipLeas))

IF INLIST(ALLT(lcVrOsebe),"FO","F1") AND ALLT(lcTipLeas) == "F1"
	=OBVESTI("Aktiviran ugovor o financijskom leasingu sa fizičkom osobom - potrebno izdati račun za interkalarnu kamatu.")
ENDIF