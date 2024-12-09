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