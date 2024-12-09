* Netreba na PROVERI PODATKE
lcdat_podpisa = pogodba.dat_podpisa && kursor se puni iz maske
lcdat_podpisa1 = _pogodba.dat_podpisa &&cursor se puni iz pogodbe, ili iz dbo.pogodba
lcDat_podpisa_dbo = GF_LOOKUP("pogodba.dat_podpisa", pogodba.id_cont, "pogodba.id_cont")

obvesti ("Pogodba novi podatak sa maske: "+trans(lcdat_podpisa) +gce+  "_pogodba stari podatak s ugovora: "+trans(lcdat_podpisa1 ) +gce+  "dbo.pogodba novi podatak s ugovora: "+trans(lcDat_podpisa_dbo )) 

* Mora ići iznad postojeće funkcionalnosti dodavanja na krovni ugovor
* 08.11.2019 g_tomislav MR 43479 - created;

LOCAL lcDat_podpisa_dbo 
*lcdat_podpisa1 = _pogodba.dat_podpisa &&kursor se puni iz dbo.pogodba; stari podatak
lcDat_podpisa_dbo = GF_LOOKUP("pogodba.dat_podpisa", pogodba.id_cont, "pogodba.id_cont") && novi podatak

IF !INLIST(pogodba.nacin_leas, "NF", "NO", "PF", "PO", "TP") AND !GF_NULLOREMPTY(lcDat_podpisa_dbo) &&always ask  gf_nullorempty(lcdat_podpisa1) and 
	
	* 2. Deleting 1R documents (4 eyes check is discarded); the same logic like in custom report additional routine MR 42706 
	LOCAL lnOK, lnError
	lnOK = 0
	lnError = 0
	
	GF_SQLEXEC("SELECT a.id_dokum FROM dbo.dokument a WHERE a.id_obl_zav = '1R' AND a.id_cont IN ("+trans(pogodba.id_cont)+") ORDER BY a.id_cont", "_dr_DokZaPromjenu")

	lnForDelete = RECCOUNT("_dr_DokZaPromjenu")

	IF lnForDelete > 0  AND POTRJENO("Unesen je datum potpisa, da li želite obrisati 1R dokumente ("+TRANS(lnForDelete)+" kom.)?")

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
		
		OBVESTI("1R dokumenti uspješno obrisani: "+TRANS(lnOK)+" (neuspješno: "+TRANS(lnError)+").")
	ENDIF
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