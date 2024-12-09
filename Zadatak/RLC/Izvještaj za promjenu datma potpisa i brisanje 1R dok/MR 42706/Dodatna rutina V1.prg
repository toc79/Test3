* 25.07.2019 g_tomislav MR 42706 - created;

loForm = GF_GetFormObject("frmPorocilo42706")
IF ISNULL(loForm) THEN 
	RETURN
ENDIF

#INCLUDE locs.h
local ldDatPodpisa_new, lnBrOznacenih, lcId_contList, lnBrIzmjenjenih

select rezultat 
go top
select * from rezultat into cursor _dr_ugovori_promjena where oznacen = .T. AND status_akt != "Z"

lnBrOznacenih = RECCOUNT("_dr_ugovori_promjena")
IF lnBrOznacenih == 0
	obvesti("Niti jedan zapis nije označen!")
	RETURN .F.
ENDIF

** Check for permissions "GOBJ_Permissions.GetPermission" is discarded, custom permissions should be used instead 

ldDatPodpisa_new = GF_GET_DATE('Unesite novi datum potpisa ugovora', {..}, '99.99.9999', .T., 'Brisanje datum potpisa ug. i brisanje 1R dokumenta')

IF GF_NULLOREMPTY(ldDatPodpisa_new)
	RETURN .F.
ENDIF

*///////////////////////////
* CONTROLS
*********************************************************** 
* 1. created based on control in ext_func POGODBA_MASKA_PROVERI_PODATKE (24.08.2016 g_tomislav - dorada MR 36207)
TEXT TO lcSQL NOSHOW 
Select a.dat_nasl_vred
From dbo.gv_PEval_LastEvaluation_ByType a 
Where a.eval_type = 'Z' 
AND dbo.gfn_GetDatePart(a.dat_nasl_vred) > GETDATE() 
AND a.id_kupca = 
ENDTEXT 

ldDatEvalZ = GF_SQLExecScalarNull(lcSQL + GF_QuotedStr(_dr_ugovori_promjena.id_kupca)) 

IF GF_NULLOREMPTY(ldDatEvalZ) THEN 
	POZOR ("Unos podatka 'Datum potpisa od strane klijenta' nije dozvoljen zato jer partner nema važeće ZSPNFT vrednovanje."+chr(13)+"Potrebno dodjeliti ocjenu rizika klijenta!") 
	RETURN .F. 
ENDIF 

*****
* 2.  
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

lcSQL2 = strtran(lcSQL2, "{0}", gf_quotedstr(_dr_ugovori_promjena.id_kupca))
GF_SQLEXEC(lcSQL2, "_pe")

IF _pe.dat_eval >= _pe.limit_date then

	lcSQL1 = strtran(lcSQL1, "{0}", gf_quotedstr(_dr_ugovori_promjena.id_kupca))
	**lcSQL1 = strtran(lcSQL1, "{1}", allt(trans(pogodba.id_cont)))
	llima = GF_SQLExecScalarNull(lcSQL1) 
	
	IF !llima  
		POZOR("Za partnera ne postoji unesen događaj 'Orginali -Izjava i Identifikacijska isprava'! Promjena se ne može izvršiti!")
		RETURN .F. 
	ENDIF
ENDIF
* END OF CONTROLS ***
*///////////////////////////

* Data changing
lcId_contList = GF_CreateDelimitedList("_dr_ugovori_promjena", "id_cont", "1=1", ", ", .F.)

TEXT TO lcSQL NOSHOW
	SELECT a.id_cont, dbo.gfn_GetContractDataHash(a.id_cont) as pogodba_hash 
		, ISNULL(b.id_frame, 0) as id_frame
		/*, cast(a.sys_ts as bigint) as sys_ts_bigint*/
		, a.id_pog
		, a.status_akt
		, a.dat_podpisa
	FROM dbo.pogodba a 
	LEFT JOIN dbo.frame_pogodba b ON a.id_cont = b.id_cont
	WHERE a.id_cont IN (

ENDTEXT
GF_SQLEXEC(lcSQL+lcId_contList + ")", "_dr_izmjena_dat_podpisa")

lnBrIzmjenjenih = 0
lnBrGrešaka = 0
lnNepromijenjeni = 0

SELECT _dr_izmjena_dat_podpisa
GO TOP
SCAN
	WAIT WIND ("Pripremam podatke za ugovor " +allt(_dr_izmjena_dat_podpisa.id_pog)+"!") NOWAIT
	LOCAL lcXml
	lcXml = ""
	
	* 1. Changing contract signature
	IF NVL(_dr_izmjena_dat_podpisa.dat_podpisa, {..}) != ldDatPodpisa_new
		IF INLIST(_dr_izmjena_dat_podpisa.status_akt, "D", "A")
			LOCAL lcpogodba_hash, lcOpomba, lcid_category, lnid_cont
			
			lcpogodba_hash = _dr_izmjena_dat_podpisa.pogodba_hash
			lnid_cont = _dr_izmjena_dat_podpisa.id_cont

			lcOpomba = "Masovna promjena datuma potpisa preko posebnog izvještaja"
			lcid_category = "999"
			
			GF_SQLEXEC("select * from pogodba where id_cont = " + GF_QuotedStr(lnid_cont),"_pogodba")
			GF_SQLEXEC("Select * From pogodba where id_cont = " + GF_QuotedStr(lnid_cont),"_pogodba_copy")
			
			REPLACE dat_podpisa WITH ldDatPodpisa_new IN _pogodba
			
			lcXML = GF_CreateContractUpdateXML(lnid_cont, ALLTRIM(lcOpomba), lcpogodba_hash, lcid_category, "_pogodba", "_pogodba_copy") && 7 parametar je * tbFourEyes - set use_4eyes depends on form check; .f. znači da nema provjere 4 oka
			
			USE IN _pogodba
			USE IN _pogodba_copy
		
		ELSE IF INLIST(_dr_izmjena_dat_podpisa.status_akt, "N")
			* GF_CreateUpdateDifFieldsXML je možda bolje ne koristiti zato što npr. kada je OPCIJA_TREN = 0, tada vrati node is null true te se NULL zapisalo u bazu => zato je bolje koristiti statičku skriptu
						
			lnid_cont = _dr_izmjena_dat_podpisa.id_cont 
			GF_SQLEXEC("select *, cast(sys_ts as bigint) as sys_ts_bigint from dbo.pogodba where id_cont="+GF_QuotedStr(lnid_cont), "pogodba")
			
			lcS = SPACE(2)
			* Pogodba
			* zamenjamo vrednost polja vnesel
			* REPLACE vnesel WITH "g_system" IN pogodba OVO JE UNIO (a ne popravio)
			*lcXMLPogodba = GF_CreateUpdateDifFieldsXML("POGODBA", "pogodba", "_pogodba_copy")
			
			* Prepare XML with data for inserting or updating contract
			lcXML = "<inactive_contract_update xmlns='urn:gmi:nova:leasing'>" + gcE
			lcXML = lcXML + GF_CreateNode("id_cont", pogodba.id_cont, "I", 1) + gcE
			lcXML = lcXML + GF_CreateNode("dat_sklen", pogodba.dat_sklen, "D", 1) + gcE
			lcXML = lcXML + GF_CreateNode("prevzeta", pogodba.prevzeta, "C", 1) + gcE
			* IF GF_NullOrEmpty(_pogodba_copy.prevzeta) AND !GF_NullOrEmpty(pogodba.prevzeta) AND !GF_NullOrEmpty(Thisform.PrevPogKateg1) THEN 
				* lcXml = lcXml + GF_CreateNode("prev_pog_kategorija1", Thisform.PrevPogKateg1, "C", 1) + gcE
			* ENDIF
			lcXML = lcXML + GF_CreateNode("id_frame", _dr_izmjena_dat_podpisa.id_frame, "I", 1) + gcE  && pogodba.id_frame
			lcXML = lcXML + GF_CreateNode("master_ts", pogodba.sys_ts_bigint, "C", 1) + gcE  && cast(sys_ts as bigint) as sys_ts
			lcXML = lcXML + GF_CreateNode("generate_planp", .F., "L", 1) + gcE   && tlGenerate_planp	
			*IF LEN(lcXMLPogodba) > 0 THEN 
				lcXML = lcXML + "<pogodba>" + gcE
				lcXML = lcXML + "<updated_values>" + gcE
				lcXML = lcXML + lcS + GF_CreateNode("table_name", "POGODBA", "C", 1) + gcE
				lcXML = lcXML + lcS + GF_CreateNode("name", "DAT_PODPISA", "C", 1) + gcE
				lcXML = lcXML + lcS + GF_CreateNode("updated_value", ldDatPodpisa_new, "D", 1) + gcE
				lcXML = lcXML + "</updated_values>" + gcE
				lcXML = lcXML + "</pogodba>" + gcE	
			*ENDIF 
			lcXML = lcXML + GF_CreateNode("enforce4eye", .T., "L", 1) + gcE
			lcXML = lcXML + GF_CreateNode("transf_doc_from_approval", .F., "L", 1) + gcE  && thisform.transf_doc; kod popravka je FALSE
			lcXML = lcXML + "</inactive_contract_update>"
		
		ENDIF 
	ENDIF	
	
	IF LEN(ALLTRIM(lcXml)) > 0 THEN
		IF GF_ProcessXML(lcXML) THEN
			lnBrIzmjenjenih = lnBrIzmjenjenih + 1
		ELSE
			*obvesti("Promjena datuma potpisa nije napravljena za ugovor ugovor:" + allt(_dr_izmjena_dat_podpisa.id_pog))
			lnBrGrešaka = lnBrGrešaka + 1
		ENDIF
	ELSE
		*obvesti("Za ugovor "+ allt(_dr_izmjena_dat_podpisa.id_pog) + " nema promjene!")
		 lnNepromijenjeni = lnNepromijenjeni + 1
	ENDIF
	
	* 2. Deleting 1R documents (4 eyes check is discarded)
	LOCAL lnOK, lnError
	lnOK = 0
	lnError = 0
	
	GF_SQLEXEC("SELECT a.id_dokum FROM dbo.dokument a WHERE a.id_obl_zav = '1R' AND a.id_cont IN ("+trans(_dr_izmjena_dat_podpisa.id_cont)+") ORDER BY a.id_cont", "_dr_DokZaPromjenu")

	lnForDelete = RECCOUNT("_dr_DokZaPromjenu")

	IF lnForDelete > 0   && AND POTRJENO("Da li želite obrisati 1R dokumente ("+TRANS(lnForDelete)+" kom.) označenih ugovora?")

		LOCAL llConfirm, llDeleteLinks
		llConfirm = .T.
		llDeleteLinks = .T.
		lcXml = ""

		SELE _dr_DokZaPromjenu
		GO TOP
		SCAN
		*dokument_krovni_vsi_pregled.scx
			LOCAL lcXmlResult 
			
			* Delete documents
			lcXml = '<delete_dokument xmlns="urn:gmi:nova:leasing">' + gcE
			lcXml = lcXml + GF_CreateNode("id_dokum", _dr_DokZaPromjenu.id_dokum, "N", 1) + gcE
			IF llDeleteLinks = .T. THEN
				lcXml = lcXml + GF_CreateNode("delete_linked_docs", .T., "L", 1) + gcE
			ENDIF
			lcXml = lcXml + "</delete_dokument>"
			
			IF llConfirm THEN
				lcXmlResult = GF_ProcessXml(lcXml, .T., .T.)
				
				IF TYPE("lcXmlResult") != "C" THEN
					lnError = lnError + 1				
				ELSE 
					lnOK = lnOK + 1	
				ENDIF	
			
			ENDIF
		ENDSCAN
		USE IN _dr_DokZaPromjenu
	ENDIF
ENDSCAN

USE IN _dr_ugovori_promjena
USE IN _dr_izmjena_dat_podpisa
	
OBVESTI("Datum potpisa ugovora uspješno izmijenjen za " + tran(lnBrIzmjenjenih) + " ugovora (neuspješno: "+ tran(lnBrGrešaka) +", bez promjene: "+ tran(lnNepromijenjeni)+")."  +gce+ "1R dokument - uspješno je obrisano "+TRANS(lnOK)+" (neuspješno: "+TRANS(lnError)+").")

* Refresh data on grid
loForm.runsql()