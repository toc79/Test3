local loForm, lcSQL, lcSQL1, lcSQL2

loForm = GF_GetFormObject("frmActiveContractUpdate") 
lcStariAlias = ALIAS()
**************************************************************
* 06.09.2016 g_tomislav MR 36218 ticket 1609
local liPromjena_statusa_na_ODP, liNePostoji_snimka

liPromjena_statusa_na_ODP = GF_LOOKUP("pogodba.status",pogodba.id_cont,"pogodba.id_cont") != pogodba.status AND  "RA" == pogodba.status && GF_LOOKUP("statusi.status","ODP","statusi.sif_status")

IF liPromjena_statusa_na_ODP  
	liNePostoji_snimka = GF_NULLOREMPTY(GF_SQLExecScalarNull("SELECT * FROM dbo.planp_clone_content WHERE id_cont = "+GF_Quotedstr(pogodba.id_cont)+" AND CONVERT(date,dat_posn,101) = CONVERT(date,getdate(),101)"))
	IF liNePostoji_snimka 
		POZOR("Za ugovor nije napravljeno spremanje trenutnog plana otplate na današnji dan. Status ugovora na raskinuti se ne može promijeniti!")
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
		IF !EMPTY(lcStariAlias) THEN
			SELECT (lcStariAlias)
		ENDIF
		RETURN .F. 
	ENDIF
ENDIF
**************************************************************
*********************************************************** 
* 13.09.2016 g_tomislav - dorada MR 36207 ticket 1478
* Za N ugovore se kontrola nalazi u POGODBA_MASKA_PROVERI_PODATKE
TEXT TO lcSQL NOSHOW 
Select a.dat_nasl_vred 
From dbo.gv_PEval_LastEvaluation_ByType a 
Where a.eval_type = 'Z' 
AND dbo.gfn_GetDatePart(a.dat_nasl_vred) > GETDATE() 
AND a.id_kupca = 
ENDTEXT 

ldDatEvalZ = GF_SQLExecScalarNull(lcSQL + GF_QuotedStr(pogodba.id_kupca)) 
lcdat_podpisa = pogodba.dat_podpisa
lcdat_podpisa1 = _pogodba_copy.dat_podpisa

IF ((gf_nullorempty(lcdat_podpisa1) and !gf_nullorempty(lcdat_podpisa)) or (lcdat_podpisa1 # lcdat_podpisa)) AND GF_NULLOREMPTY(ldDatEvalZ) THEN 
	POZOR ("Unos podatka 'Datum potpisa od strane klijenta' nije dozvoljen zato jer partner nema važeće ZSPNFT vrednovanje."+chr(13)+"Potrebno dodjeliti ocjenu rizika klijenta!") 
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error 
	IF !EMPTY(lcStariAlias) THEN
		SELECT (lcStariAlias)
	ENDIF
	RETURN .F. 
ENDIF 

***********************************************************
* 19.12.2019 g_tomislav MR 43479 - added new control for dat_podpisa
IF !INLIST(pogodba.nacin_leas, "NF", "NO", "PF", "PO", "TP") AND !gf_nullorempty(lcdat_podpisa) THEN 
	
	lnBroj_1R_dok = GF_SQLEXECScalar("SELECT COUNT(*) AS broj_1R_dok FROM dbo.dokument a WHERE a.id_obl_zav = '1R' AND a.id_cont = "+GF_Quotedstr(pogodba.id_cont))

	IF lnBroj_1R_dok > 0
		OBVESTI ("S unosom datuma potpisa potrebno je obavezno obrisati 1R dokument iz dokumentacije ugovora!")
	ENDIF
ENDIF

***********************************************************
* 05.02.2020 g_tomislav MR 43505 - control for interest rate
IF _pogodba_copy.id_rtip != pogodba.id_rtip OR _pogodba_copy.rind_zadnji != pogodba.rind_zadnji OR _pogodba_copy.fix_del != pogodba.fix_del
	IF !POTRJENO("Na ugovoru su promijenjeni sljedeći podaci:"+gce+"stara vrijednost  ->  nova vrijednost"+gce ;
			+"Indeks kamata: "+trans(_pogodba_copy.id_rtip)+"  ->  "+trans(pogodba.id_rtip)+gce ;
			+"Vrijednost indeksa: "+trans(_pogodba_copy.rind_zadnji)+"  ->  "+trans(pogodba.rind_zadnji)+gce ;
			+"Marža (fiksni dio): "+trans(_pogodba_copy.fix_del)+"  ->  "+trans(pogodba.fix_del)+gce ;
			+"Da li želite nastaviti sa spremanjem?")
		RETURN .F. 
	ENDIF
ENDIF

***********************************************************************************
*S promjenom kontrole na ovom mjestu, potrebno je promijeniti POGODBA_MASKA_SET_DEF_VALUES, POGODBA_MASKA_PREVERI_PODATKE te provjeriti i POGODBA_MASKA_AFTER_INIT
* 01.10.2020 g_tomislav MID 45222 - Rind_strategije: nova strategija zadnji radni dan u mjesecu  
***********************************************************************************
llfix_dat_rpg = LOOKUP(rtip.fix_dat_rpg, pogodba.id_rtip, rtip.id_rtip)

IF llfix_dat_rpg 
	LOCAL lcid_kupca, lcTip_leas, lcVr_osebe, lnObdobje_mes, lnDanUMjesecu, lnId_rind_strategije, ldNoviDan, ldRind_dat_next
	lcid_kupca = pogodba.id_kupca
	lcTip_leas = RF_TIP_POG(pogodba.nacin_leas)
	lnObdobje_mes = 12/LOOKUP(obdobja.obnaleto, GF_LOOKUP("rtip.id_obdrep", pogodba.id_rtip, "rtip.id_rtip"), obdobja.id_obd)
	GF_SQLEXEC("select vr_osebe from dbo.partner where id_kupca = "+GF_QUOTEDSTR(lcid_kupca),"_ef_vr_osebe")
	lcVr_osebe = _ef_vr_osebe.vr_osebe
	USE IN _ef_vr_osebe
	
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
						
			lcSQL45222_2 = strtran(lcSql45222, "{0}", DTOS(ldTarget_datePomak))
			ldRind_dat_next = TTOD(GF_SQLEXECScalar(lcSql45222_2))
		ELSE 
			ldRind_dat_next = ldZadnjiRadniDanZaRazdoblje
		ENDIF
	ENDIF
	* END Region Izračun rind_dat_next
	
	IF pogodba.id_rind_strategije != lnId_rind_strategije OR pogodba.Rind_dat_next != ldRind_dat_next
		if potrjeno("Nije unešena odgovarajuća vrijednost Strategije reprograma. Odgovarajuće vrijednosti su:" +gce;
				+"Strategija reprograma: " +allt(lookup(rind_strategije.naziv, lnId_rind_strategije, rind_strategije.id_rind_strategije)) +gce;
				+"Slj. repr.: "+trans(ldRind_dat_next) +gce;
				+"Želite li spremiti te vrijednosti?")
			loForm.pgfPogodba.pagSplosni.txtrindDatNext.Value = ldRind_dat_next
			loForm.pgfPogodba.pagSplosni.cmbRindStrategije.Value = lnId_rind_strategije
		ENDIF
	ENDIF
ENDIF
* KRAJ Rind strategije
*********************

***********************************************************
****SLIJEDEĆA PROVJERA UVIJEK MORA BITI ZADNJA************************************
IF loForm.tip_vnosne_maske = 2 then
	TEXT TO lcSQL1 NOSHOW 
		Select CAST(count(*) as bit) as ima
		From dbo.ss_dogodek
		where id_tip_dog = '08' and ID_KUPCA ={0} 
	ENDTEXT 
**and ID_CONT = {1}
	TEXT TO lcSQL2 NOSHOW 
		Select a.ext_id, a.dat_eval, a.dat_nasl_vred, cast('20170425' as datetime) as limit_date
		From dbo.gv_PEval_LastEvaluation_ByType a 
		Where a.eval_type = 'Z' 
		AND a.id_kupca = {0} 
		AND dbo.gfn_GetDatePart(a.dat_nasl_vred) > GETDATE() 
	ENDTEXT 

	lcSQL2 = strtran(lcSQL2, "{0}", gf_quotedstr(pogodba.id_kupca))
	GF_SQLEXEC(lcSQL2, "_pe")

	IF ((gf_nullorempty(lcdat_podpisa1) and !gf_nullorempty(lcdat_podpisa)) or (lcdat_podpisa1 # lcdat_podpisa)) and _pe.dat_eval >= _pe.limit_date then

		lcSQL1 = strtran(lcSQL1, "{0}", gf_quotedstr(pogodba.id_kupca))
**		lcSQL1 = strtran(lcSQL1, "{1}", allt(trans(pogodba.id_cont)))
		llima = GF_SQLExecScalarNull(lcSQL1) 
		if llima = .f. then
			**ako je odgovor NE ne može snimiti ugovora
			**ako je odgovor DA snimi se ugovor i treba pokrenuti novi proces za partnera sa oznakom da nije bio nazočan na potpisu.

			llpotrjeno =POTRJENO("Za partnera ne postoji unesen događaj 'Orginali -Izjava i Identifikacijska isprava'. Želite li svejedno snimiti ugovor? Ukoliko odgovorite sa DA snimit će se ugovor i pokrenuti nova instanca ZSPNFT procesa.")
			if llpotrjeno = .f. then
					POZOR("Unos datuma potpisa nije moguć dok se ne unese događaj 'Orginali -Izjava i Identifikacijska isprava'")
					SELECT cur_extfunc_error
					REPLACE ni_napaka WITH .F. IN cur_extfunc_error 
					IF !EMPTY(lcStariAlias) THEN
					 SELECT (lcStariAlias)
					ENDIF

					RETURN .F. 
			endif

			if llpotrjeno = .t. then
				***izvući zadnji ext_id iz p_eval

				lcext_id = allt(_pe.ext_id)
				lcXml = "<zspnft_clone_instance_starter xmlns='urn:gmi:nova:integration'>" + gcE
				lcXml = lcXml + "<clone_instance_data>" +gcE
				if gf_nullorempty(lcext_id) then
					lcXml = lcXml + GF_CreateNode("instance_id", -1, "I", 1) +gcE
				else
					lcXml = lcXml + GF_CreateNode("instance_id", allt(lcext_id), "I", 1) +gcE
				endif
				lcXml = lcXml + GF_CreateNode("id_kupca", pogodba.id_kupca , "C", 1) +gcE
				lcxml = lcXml + "<fix_field_value>" + gcE
				lcxml = lcXml + "<name>customer_not_present</name>" + gcE
				lcxml = lcXml + "<value>true</value>" + gcE
				lcxml = lcXml + "</fix_field_value>" + gcE
				lcXml = lcXml + "</clone_instance_data>" +gcE
				lcXml = lcXml + "</zspnft_clone_instance_starter>"


				gf_processxml(lcXML, .f., .f.)
			endif
		endif
	endif
endif




IF !EMPTY(lcStariAlias) THEN
	SELECT (lcStariAlias)
ENDIF
************************** KRAJ PROVJERE *****************************************