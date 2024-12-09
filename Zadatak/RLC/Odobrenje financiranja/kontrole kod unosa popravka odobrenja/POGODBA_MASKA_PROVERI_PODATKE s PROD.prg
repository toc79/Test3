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
* 14.06.2017 g_tomislav MR 36135 - Rind strategije; Sa promjenom kontrole na ovom mjestu, potrebno je promijeniti i POGODBA_MASKA_SET_DEF_VALUES
***********************************************************************************
llfix_dat_rpg = LOOKUP(rtip.fix_dat_rpg, pogodba.id_rtip, rtip.id_rtip)

IF llfix_dat_rpg 
	LOCAL lcid_kupca, lcTip_leas, lcVr_osebe, lnObdobje_mes, lnStrategija10, lnStrategija25, lnDanUMjesecu, lnId_rind_strategije, ldRind_datum, lnRind_datumMonth, lnRind_datumYear, lcNoviDan, lnRind_dat_next
	lcid_kupca = pogodba.id_kupca
	lcTip_leas = RF_TIP_POG(pogodba.nacin_leas)
	lnObdobje_mes = 12/LOOKUP(obdobja_lookup.obnaleto, LOOKUP(rtip.id_obdrep, pogodba.id_rtip, rtip.id_rtip), obdobja_lookup.id_obd)
	GF_SQLEXEC("select vr_osebe from dbo.partner where id_kupca = "+GF_QUOTEDSTR(lcid_kupca),"_ef_vr_osebe")
	lcVr_osebe = _ef_vr_osebe.vr_osebe
	USE IN _ef_vr_osebe
	
	lnStrategija10 = 10
	lnStrategija25 = 25
	
	IF (lcVr_osebe  == 'FO' or lcVr_osebe == 'F1') and lcTip_leas = 'F1' && kao na općim uvjetima
		lnDanUMjesecu = lnStrategija10
	ELSE 
		lnDanUMjesecu = lnStrategija25
	ENDIF

	lnId_rind_strategije = LOOKUP(rind_strategije.id_rind_strategije, lnDanUMjesecu, rind_strategije.odmik)		
	
	ldRind_datum = pogodba.rind_datum
	lnRind_datumMonth = MONTH(ldRind_datum)
	lnRind_datumYear = YEAR(ldRind_datum)
	lcNoviDan = CTOD(ALLTRIM(STR(lnDanUMjesecu)+"/"+ALLTRIM(STR(lnRind_datumMonth))+"/"+ALLTRIM(STR(lnRind_datumYear))))
	lnRind_dat_next = GOMONTH(lcNoviDan, lnObdobje_mes)
	
	IF pogodba.id_rind_strategije != lnId_rind_strategije OR pogodba.Rind_dat_next != lnRind_dat_next
		if !potrjeno("Nije unešena odgovarajuća vrijednost Strategije reprograma. Želite li spremiti takav ugovor?")
			SELECT cur_extfunc_error
			REPLACE ni_napaka WITH .F. IN cur_extfunc_error
		ENDIF
		*REPLACE pogodba.id_rind_strategije WITH lnId_rind_strategije IN pogodba
		*REPLACE pogodba.Rind_dat_next WITH lnRind_dat_next IN pogodba
		*Pozor("Strategija reprograma je postavljena na "+ALLT(STR(lnDanUMjesecu))+". dan u mjesecu!")
	ENDIF
ENDIF
* KRAJ Rind strategije
*********************

****SLIJEDEĆA PROVJERA UVIJEK MORA BITI ZADNJA************************************
IF loForm.tip_vnosne_maske # 1 then

	lcdat_podpisa = pogodba.dat_podpisa
	lcdat_podpisa1 = _pogodba.dat_podpisa
	lcSQL2 = strtran(lcSQL2, "{0}", gf_quotedstr(pogodba.id_kupca))
	GF_SQLEXEC(lcSQL2, "_pe")

	IF ((gf_nullorempty(lcdat_podpisa1) and !gf_nullorempty(lcdat_podpisa)) or (lcdat_podpisa1 # lcdat_podpisa)) and _pe.dat_eval >= _pe.limit_date then

		lcSQL1 = strtran(lcSQL1, "{0}", gf_quotedstr(pogodba.id_kupca))
		**lcSQL1 = strtran(lcSQL1, "{1}", allt(trans(pogodba.id_cont)))
		llima = GF_SQLExecScalarNull(lcSQL1) 
		if llima = .f. then
			**ako je odgovor NE ne može snimiti ugovora
			**ako je odgovor DA snimi se ugovor i treba pokrenuti novi proces za partnera sa oznakom da nije bio nazočan na potpisu.

			llpotrjeno =POTRJENO("Za partnera ne postoji unesen događaj 'Orginali -Izjava i Identifikacijska isprava'. Želite li svejedno snimiti ugovor? Ukoliko odgovorite sa DA snimit će se ugovor i pokrenuti nova instanca ZSPNFT procesa.")
			if llpotrjeno = .f. then
					POZOR("Unos ugovora nije moguć dok se ne unese događaj 'Orginali -Izjava i Identifikacijska isprava'")
					SELECT cur_extfunc_error
					REPLACE ni_napaka WITH .F. IN cur_extfunc_error 
					IF !EMPTY(lcStariAlias) THEN
					 SELECT (lcStariAlias)
					ENDIF

					RETURN .F. 
			endif

			if llpotrjeno = .t. then
					***izvući zadnji ext_id iz p_eval
					
					lcext_id = altt(_p_eval.ext_id)
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