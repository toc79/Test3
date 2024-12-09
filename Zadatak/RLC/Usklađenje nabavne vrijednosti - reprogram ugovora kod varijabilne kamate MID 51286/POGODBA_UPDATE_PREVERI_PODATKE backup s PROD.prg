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
** S promjenom kontrole na ovom mjestu, potrebno je promijeniti POGODBA_MASKA_PREVERI_PODATKE, POGODBA_MASKA_RIND_STRATEGIJE_LOSTFOCUS, POGODBA_UPDATE_RIND_STRATEGIJE_LOSTFOCUS te provjeriti POGODBA_MASKA_AFTER_INIT i POGODBA_UPDATE_INIT
** 14.10.2020 g_tomislav MID 45222 - Rind_strategije: nova strategija zadnji radni dan u mjesecu 
** 20.10.2020 g_tomislav MID 45655 - bugfix: zamijenjena varijabla ldZadnjiRadniDanZaRazdoblje s ldTarget_date pa je sada izraz ldNoviDan < ldTarget_date 
** 30.10.2020 g_tomislav MID 45655 - provjera se isključuje kada se mijenja status ugovora, a ne postoje više potraživanja za rate/obrok sa datumom u budućnosti 
** 29.07.2021 g_tomislav MID 47073 - bugfix: umjesto day('{0}') je podešeno 1 (za izračun zadnjeg radnog rada u mjesecu nije bitno koji je dan u mjesecu)
***********************************************************************************
llfix_dat_rpg = LOOKUP(rtip.fix_dat_rpg, pogodba.id_rtip, rtip.id_rtip)

ldMax_datum_dok_lobr = NVL(GF_SQLExecScalarNull("select max(max_datum_dok_lobr) as max_datum_dok_lobr from dbo.planp_ds where id_cont = " + trans(pogodba.id_cont)), DATE() -1 ) && istekli ugovori nemaju zapis u planp_ds

IF llfix_dat_rpg AND ! (_pogodba_copy.status != pogodba.status AND ldMax_datum_dok_lobr < DATE() )
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
	
	IF pogodba.id_rind_strategije != lnId_rind_strategije OR TTOD(pogodba.Rind_dat_next) != ldRind_dat_next
		if potrjeno("Nije unešena odgovarajuća vrijednost Strategije reprograma. Odgovarajuće vrijednosti su:" +gce;
				+"Strategija reprograma: " +allt(lookup(rind_strategije.naziv, lnId_rind_strategije, rind_strategije.id_rind_strategije)) +gce;
				+"Slj. repr.: "+trans(ldRind_dat_next) +gce;
				+"Želite li spremiti te vrijednosti? Nastavak spremanja ugovora nije moguć s neodgovarajućim vrijednostima!")
			loForm.pgfPogodba.pagSplosni.txtrindDatNext.Value = ldRind_dat_next
			loForm.pgfPogodba.pagSplosni.cmbRindStrategije.Value = lnId_rind_strategije
		ELSE
			REPLACE ni_napaka WITH .F. IN cur_extfunc_error
			IF !EMPTY(lcStariAlias) THEN
				SELECT (lcStariAlias)
			ENDIF
		ENDIF
	ENDIF
ENDIF
* KRAJ Rind strategije
*********************

*********************************************
* 13.12.2021 g_tomislav MID 47577 - mjesto troška ugovora se postavlja prema kategorija4 od skrbnika 1 partnera sa ugovora

TEXT TO lcSql NOSHOW
	select s1.kategorija4 
	from dbo.partner par 
	inner join dbo.partner s1 on par.skrbnik_1 = s1.id_kupca
	inner join dbo.strm1 MT on isnull(s1.kategorija4, '') = MT.id_strm -- ako MT/kategorija4 postoji u dbo.STRM1 da tek onda ide
	where par.id_kupca = 
ENDTEXT

lcMT = allt(GF_SQLEXECScalarNull(lcSql +gf_quotedstr(pogodba.id_kupca)))

IF !GF_NULLOREMPTY(lcMT) and lcMT != allt(pogodba.id_strm)
	IF POTRJENO("Mjesto troška na ugovoru treba biti " +lcMT +" " +allt(GF_LOOKUP("strm1.strm_naz", lcMT, "strm1.id_strm")) +"!" +gce;
		+"Želite li spremiti navedenu odgovarajuću vrijednost? Nastavak spremanja ugovora nije moguć s neodgovarajućom vrijednosti (" +allt(pogodba.id_strm) +")!")
		loForm.pgfPogodba.pagOstali.txtId_strm.Value = lcMT
	ELSE
		SELECT cur_extfunc_error
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
	ENDIF
ENDIF 
*******END MID 47577***************************
**********************************************************************************
* 13.02.2023 - g_tkovacev, MR #50155, dodavanje kontrole na unos datuma indeksa kamate
* 01.03.2023 - g_tkovacev, MR #50325, dorada kontrole za unos datuma indeksa kamate, sada se izvršava samo za ugovore sa status_akt = 'D'

lcDatum = pogodba.rind_datum
lcId_rtip = pogodba.id_rtip
lcStatus_akt = pogodba.status_akt

IF ALLT(lcId_rtip) <> '0' AND lcStatus_akt = 'D'
	TEXT TO lcSql NOSHOW
		SELECT
			dbo.gfn_LastWorkDay(CASE 12 / FLOOR(b.obnaleto)
				WHEN 6 THEN IIF(YEAR(DATEADD(MONTH, -6, GETDATE())) < YEAR(GETDATE()), DATEADD(yy, DATEDIFF(yy, 0, DATEADD(MONTH, -6, GETDATE())) + 1, -1), EOMONTH(DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0), 5))
				WHEN 3 THEN DATEADD(QUARTER, DATEDIFF(QUARTER, 0, GETDATE()), 0) - 1
				WHEN 1 THEN IIF(MONTH(GETDATE()) = 1, DATEADD(DAY, -1, DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0)), EOMONTH(GETDATE(), -1))
			END) AS datum_value
		FROM dbo.rtip a
		JOIN dbo.obdobja b ON a.id_obdrep = b.id_obd
		WHERE LTRIM(RTRIM(a.id_rtip)) = '{0}'
	ENDTEXT

	lcSql = STRTRAN(lcSql, '{0}', ALLT(lcId_rtip))
	GF_SQLEXEC(lcSql, "_ef_rtip")

	IF lcDatum != _ef_rtip.datum_value
		POZOR("Potrebno je odabrati datum " + DTOC(_ef_rtip.datum_value))
		RETURN .F.
	ENDIF
ENDIF

**********************************KRAJ KONTROLE***********************************
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