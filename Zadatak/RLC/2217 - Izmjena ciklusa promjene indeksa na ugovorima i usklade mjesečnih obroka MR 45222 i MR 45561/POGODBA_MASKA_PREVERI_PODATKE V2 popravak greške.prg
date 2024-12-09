local loForm, lcSQL, lcSQL1, lcSQL2

loForm = GF_GetFormObject("frmPOGODBA_MASKA") 
lcStariAlias = ALIAS()

*********************************************************** 
* 24.08.2016 g_tomislav - dorada MR 36207
* procedura mora biti na vrhu zato jer RETURN od nižih provjera prekida izvršenje doljnjih dijelova koda u slueaju da se dva puta klikne na save. To bi trebalo pooraviti.
TEXT TO lcSQL NOSHOW 
Select a.dat_nasl_vred
From dbo.gv_PEval_LastEvaluation_ByType a 
Where a.eval_type = 'Z' 
AND dbo.gfn_GetDatePart(a.dat_nasl_vred) > GETDATE() 
AND a.id_kupca = 
ENDTEXT 

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

ldDatEvalZ = GF_SQLExecScalarNull(lcSQL + GF_QuotedStr(pogodba.id_kupca)) 

IF loForm.tip_vnosne_maske # 1 AND !GF_NULLOREMPTY(pogodba.dat_podpisa) AND GF_NULLOREMPTY(ldDatEvalZ) THEN 
	POZOR ("Unos podatka 'Datum potpisa od strane klijenta' nije dozvoljen zato jer partner nema važeae ZSPNFT vrednovanje."+chr(13)+"Potrebno dodjeliti ocjenu rizika klijenta!") 
	SELECT cur_extfunc_error
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error 
	IF !EMPTY(lcStariAlias) THEN
	 SELECT (lcStariAlias)
	ENDIF
	RETURN .F. 
ENDIF 

IF loForm.tip_vnosne_maske = 1 AND GF_NULLOREMPTY(ldDatEvalZ) THEN 
	POZOR ("Unos ugovora nije moguć zato jer partner nema važeće ZSPNFT vrednovanje."+chr(13)+"Potrebno dodjeliti ocjenu rizika klijenta!") 
	SELECT cur_extfunc_error
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error 
	IF !EMPTY(lcStariAlias) THEN
	 SELECT (lcStariAlias)
	ENDIF

	RETURN .F. 
ENDIF 
***********************************************************

*//////////////////////////////////////////////////////////
** 07.11.2018. g_tomislav MR 40602
LOCAL lcSifraVr_osebe
lcSifraVr_osebe = NVL(GF_SQLExecScalarNull("SELECT b.sifra FROM dbo.partner a INNER JOIN dbo.vrst_ose b ON a.vr_osebe = b.vr_osebe WHERE a.id_kupca = "+GF_QuotedStr(pogodba.id_kupca)), "")

IF INLIST(pogodba.nacin_leas, "F1", "F2", "F3", "F4") AND lcSifraVr_osebe == "FO"
	
	SELECT * FROM str_dobr WHERE strosek > 0 AND id_stroska IN ('KO') INTO CURSOR _ef_pon_terj_stros_KO 
	SELECT * FROM str_dobr WHERE strosek > 0 AND id_stroska IN ('IK') INTO CURSOR _ef_pon_terj_stros_IK 

	IF RECCOUNT("_ef_pon_terj_stros_KO") == 0 OR RECCOUNT("_ef_pon_terj_stros_IK") == 0
		POZOR("Za fizičku osobu za ugovore tipa F1, F2, F3 i F4 je obavezno unijeti troškove KO Kasko osiguranje i IK Interkalarna kamata!")
		SELECT cur_extfunc_error
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
	ENDIF

	IF USED ("_ef_pon_terj_stros_KO")
		USE IN _ef_pon_terj_stros_KO
	ENDIF
	IF USED ("_ef_pon_terj_stros_IK")
		USE IN _ef_pon_terj_stros_IK
	ENDIF
ENDIF
*//////////////////////////////////////////////////////////

*//////////////////////////////////////////////////////////
** 16.01.2019. g_tomislav MR 40602 - check for marginal amount of EKS; logic was taken from source and modified for client

IF nacini_l.tip_knjizenja == "2" AND !nacini_l.ol_na_nacin_fl
	loForm.calc_eom(.T.)
	loForm.check_eom_limit
	
	IF EOM_meja.exceeded 
		LOCAL lcStr, lctxt, lctxt1, lcEOM_meja_txt, lnEOMMeja
		lnEOMMeja = EOM_meja.meja
		lctxt = "Efektivna kamatna stopa je viša od zakonski propisane" && caption	
		lcEOM_meja_txt= lctxt + SPACE(1) + TRANSFORM(lnEOMMeja)  + " %!" + gcE 	
		lctxt1 = "Ugovor se ne može spremiti." && caption
		lcStr = lcEOM_meja_txt + lctxt1 
		POZOR(lcStr)
		SELECT cur_extfunc_error
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
	ENDIF
ENDIF
*//////////////////////////////////////////////////////////


***********************************************************************************
*** Popravak općih uvjeta prije provjere RLC prijava 1038 *************************
*** provjera općih uvjeta MID 20434, kada se mjenjaju opći uvjeti treba zamijeniti i default values
* 15.03.2017 g_tomislav - dorada Opći uvjeti MR 37651 
***********************************************************************************
local lcTip_leas, lcVr_osebe, lcSpl_pog01, lcSpl_pog02, lcPogoj1

lcTip_leas = RF_TIP_POG(pogodba.nacin_leas)
lcVr_osebe = GF_LOOKUP("partner.vr_osebe",pogodba.id_kupca,"partner.id_kupca")
GF_SQLEXEC("SELECT id_key, value FROM dbo.gfn_g_register('RLC_OPCI_UVJETI') WHERE neaktiven = 0", "_ef_opci_uvijeti")
lcSpl_pog01 = ALLT(LOOK(_ef_opci_uvijeti.value, "01", _ef_opci_uvijeti.id_key))
lcSpl_pog02 = ALLT(LOOK(_ef_opci_uvijeti.value, "02", _ef_opci_uvijeti.id_key))

IF (lcVr_osebe  == 'FO' or lcVr_osebe == 'F1') and lcTip_leas == 'F1'
	IF pogodba.spl_pog != lcSpl_pog01 THEN 
		REPLACE pogodba.spl_pog WITH lcSpl_pog01 IN pogodba 
	ENDIF
ELSE
	IF pogodba.spl_pog != lcSpl_pog02 THEN
		REPLACE pogodba.spl_pog WITH lcSpl_pog02 IN pogodba 
	ENDIF
ENDIF

USE IN _ef_opci_uvijeti

if used('_ef_partner_list') then
	return
endif
* Komentar: ako se u gornjoj provjeri setira, da li je uopće potrebna donja provjera ?
TEXT TO lcPogoj1 NOSHOW
	select * from partner p
		where p.id_kupca = '{0}'
ENDTEXT
lcPogoj1 = STRTRAN(lcPogoj1, '{0}', pogodba.id_kupca)
gf_sqlexec(lcPogoj1,"_ef_partner_list")
IF ((_ef_partner_list.vr_osebe  == 'FO' or _ef_partner_list.vr_osebe == 'F1') and lcTip_leas == 'F1') 
	IF pogodba.spl_pog != lcSpl_pog01
		if !potrjeno('Nije unešena odgovarajuća vrijednost općih uvjeta! Za tip financiranja F1 i fizičke osobe opći uvjeti trebaju biti '+lcSpl_pog01+', a za sve druge '+lcSpl_pog02+'. Želite li spremiti takav ugovor?')
			SELECT cur_extfunc_error
			REPLACE ni_napaka WITH .F. IN cur_extfunc_error
		ENDIF
	ENDIF
ELSE
	IF pogodba.spl_pog != lcSpl_pog02
		IF !potrjeno('Nije unešena odgovarajuća vrijednost općih uvjeta! Za tip financiranja F1 i fizičke osobe opći uvjeti trebaju biti '+lcSpl_pog01+', a za sve druge '+lcSpl_pog02+'. Želite li spremiti takav ugovor?')
			SELECT cur_extfunc_error
			REPLACE ni_napaka WITH .F. IN cur_extfunc_error
		ENDIF
	ENDIF
ENDIF

IF USED("_ef_partner_list")
	USE IN _ef_partner_list
ENDIF
************************** KRAJ PROVJERE *****************************************

***********************************************************************************
*S promjenom kontrole na ovom mjestu, potrebno je promijeniti POGODBA_MASKA_SET_DEF_VALUES, POGODBA_UPDATE_PREVERI_PODATKE te provjeriti i POGODBA_MASKA_AFTER_INIT
* 14.06.2017 g_tomislav MR 36135 - Rind strategije
* 25.06.2020 g_tomislav MID 44956 - bugfix;
* 01.10.2020 g_tomislav MID 45222 - nova strategija zadnji radni dan u mjesecu  
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
		POZOR("Nije unesena odgovarajuća vrijednost Strategije reprograma. Automatski će se napraviti promjena na odgovarajuće vrijednosti:" +gce;
			+"Strategija reprograma: " +allt(lookup(rind_strategije.naziv, lnId_rind_strategije, rind_strategije.id_rind_strategije)) +gce;
			+"Slj. repr.: "+trans(ldRind_dat_next) )
		loForm.Pageframe1.Page2.cmbRindStrategije.Value = lnId_rind_strategije
		loForm.Pageframe1.Page2.txtRindDatNext.Value = ldRind_dat_next
	ENDIF
ENDIF
* KRAJ Rind strategije
*********************

****SLIJEDEĆA PROVJERA UVIJEK MORA BITI ZADNJA************************************
*06.09.2019 g_tkovacev MR 43084 - uklanjanje upita u slučaju da partner na ugovoru nema unešen događaj, sada se samo zabrani spremanje ugovora u slučaju da ju nema

**IF loForm.tip_vnosne_maske # 1 then

	lcdat_podpisa = pogodba.dat_podpisa
	lcdat_podpisa1 = _pogodba.dat_podpisa
	lcSQL2 = strtran(lcSQL2, "{0}", gf_quotedstr(pogodba.id_kupca))
	GF_SQLEXEC(lcSQL2, "_pe")

	IF ((gf_nullorempty(lcdat_podpisa1) and !gf_nullorempty(lcdat_podpisa)) or (lcdat_podpisa1 # lcdat_podpisa)) and _pe.dat_eval >= _pe.limit_date then

		lcSQL1 = strtran(lcSQL1, "{0}", gf_quotedstr(pogodba.id_kupca))
		**lcSQL1 = strtran(lcSQL1, "{1}", allt(trans(pogodba.id_cont)))
		llima = GF_SQLExecScalarNull(lcSQL1) 
		if llima = .f. then
			POZOR("Unos ugovora nije moguć dok se ne unese događaj 'Orginali -Izjava i Identifikacijska isprava'")
			SELECT cur_extfunc_error
			REPLACE ni_napaka WITH .F. IN cur_extfunc_error 
			IF !EMPTY(lcStariAlias) THEN
			 SELECT (lcStariAlias)
			ENDIF

			RETURN .F. 
		endif
	endif
**endif

IF !EMPTY(lcStariAlias) THEN
	SELECT (lcStariAlias)
ENDIF


************************** KRAJ PROVJERE *****************************************

**********************************************************************************
**PROVJERA UNOSA POREZ U MPC U ODNOSU NA STOPU POREZA U MPC NA PONUDI*************
**********************************************************************************
* LOCAL loForm, lcPogoj

* lcPogoj = ""
* loForm = NULL


* FOR lnI = 1 TO _Screen.FormCount
	* IF UPPER(_Screen.Forms(lnI).Name) == UPPER("frmPOGODBA_MASKA") THEN
	* loForm = _Screen.Forms(lnI)
* EXIT
* ENDIF
* NEXT

* IF ISNULL(loForm) THEN
	* RETURN
* ENDIF

* if used('_ponudba_list') then
	* return
* endif

* TEXT TO lcPogoj NOSHOW
	* select * from ponudba pon
		* where pon.id_pon = '{0}'
* ENDTEXT
* lcPogoj = STRTRAN(lcPogoj, '{0}', pogodba.id_pon)

* gf_sqlexec(lcPogoj,"_ponudba_list")
* &&select _test
* &&brow

* if len(alltrim(_ponudba_list.id_pon))>0 and pogodba.id_dav_op!=_ponudba_list.id_dav_op
	* if !potrjeno('Porez u MPC na ugovoru drugaeiji od Poreza u MPC unešenog na ponudi. Želite li spremiti takav ugovor?')
		* SELECT cur_extfunc_error
		* REPLACE ni_napaka WITH .F. IN cur_extfunc_error
		* if used("_ponudba_list")
			* use in _ponudba_list
		* endif
	* endif
* endif
********************************************************** 

**********************************************************************************
**** MR 38358 g_mladens; RLHR Ticket 1752 - Unos ugovora, provjera za ROL*********
**********************************************************************************
IF loForm.tip_vnosne_maske = 1 THEN 
	IF !POTRJENO("Da li ste provjerili ROL?") THEN 
		RETURN .F.
	ENDIF
ENDIF
************************** KRAJ **************************************************
**********************************************************************************
**** g_dejank; MR 41269 - provjera da li je partner na ugovoru FO,F1*********
**** 13.11.2018. g_tomislav MR 41506; dorada
**** 18.06.2020. g_vuradin MR 44962; promjena LOOKUP u GF_LOOKUP
**********************************************************************************
llIzvedeniIndeks = ! GF_NULLOREMPTY(GF_LOOKUP("rtip.id_rtip_base", pogodba.id_rtip, "rtip.id_rtip"))

IF llIzvedeniIndeks AND INLIST(GF_LOOKUP("partner.vr_osebe", pogodba.id_kupca,"partner.id_kupca"), "FO","F1") AND !potrjeno('Ugovor se sklapa s fizičkom osobom i izvedenim indeksom - da li ste provjerili kamatnu stopu?') THEN
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error
ENDIF
************************** KRAJ 41269**********************************************
