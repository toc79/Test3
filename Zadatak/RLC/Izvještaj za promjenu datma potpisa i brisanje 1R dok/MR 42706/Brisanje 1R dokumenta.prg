<delete_dokument xmlns="urn:gmi:nova:leasing">
<id_dokum>928137</id_dokum>
<delete_linked_docs>true</delete_linked_docs>
</delete_dokument>

<check_for_linked_docs xmlns="urn:gmi:nova:leasing">
<id_dokum>928137</id_dokum>
</check_for_linked_docs>

frmMassiveChangeDat_podpisa    
Poštovana/i, 

u privitku vam šaljemo ponudu za izradu:
1. posebnog izvještaja u kojemu će se odabirati kandidati za promjenu podataka pod točkama 2 i 3.
Izvještaj bi imao jedan kriterij pretrage "Partner" te bi za njega prikazali sve nezaključene ugovore koji nemaju unesen datum potpisa (bez obzira da li imaju 1R dokument), te uz te i aktivne ugovore koji imaju R1 dokument i nemaju datum potpisa. 
Kolone bi bile: Označen, Broj ugovora, Šifra partnera, Datum potpisa, Da li ima 1R dokument.

2. dodatne rutine za promjenu datuma potpisa označenih zapisa ugovora na navedenom izvještaju (pod 1)

3. dodatne rutine za brisanje 1R dokumenta. Promjena će biti zapisana u pregled reprograma zato što je tako podešeno u šifrantu Vrste dokumentacije.


* 04.06.2019 g_tomislav MR 42706 
IF GOBJ_Permissions.GetPermission('CollectionDocumentationDelete') < 2 THEN 
	pozor(STRTRAN(PERMISSION_DENIED, "{0}", "CollectionDocumentationDelete"))
	* Thisform.bgridResult.SetFocus
	RETURN 
ENDIF

** zadnji označen zapis ne uvažava pa su potrebne sljedeće 3 linije		
SELECT rezultat 
SCAN FOR oznacen = .t.
ENDSCAN


LcList_condition = ""  && Mora biti 
lcList = GF_CreateDelimitedList("rezultat", "id_cont", LcList_condition, ",", .f.) 

GF_SQLEXEC("SELECT a.id_dokum FROM dbo.dokument a WHERE a.id_obl_zav = '1R' AND a.id_cont IN ("+iif(len(alltrim(lcList))=0,"0",lcList)+") ORDER BY a.id_cont", "_dr_DokZaPromjenu")

lnForDelete = RECCOUNT("_dr_DokZaPromjenu")

IF lnForDelete > 0 AND POTRJENO("Da li želite obrisati 1R dokumente ("+TRANS(lnForDelete)+" kom.) označenih ugovora?")

	LOCAL lnOK, lnError, llConfirm, llDeleteLinks

	lnOK = 0
	lnError = 0
	llConfirm = .T.
	llDeleteLinks = .T.

	*SELECT id_dokum FROM _dr_DokZaPromjenu
	SELE _dr_DokZaPromjenu
	GO TOP
	SCAN
	*dokument_krovni_vsi_pregled.scx
	* PROCEDURE TBRACTIONS.btnBrisi.Click
			* LOCAL lcXml, lcXmlResult, lcCursor, llConfirm, llDeleteLinks
			LOCAL lcXml, lcXmlResult 

			* IF Thisform.pgfDokument_krovni.ActivePage != 1
				* RETURN
			* ENDIF
			
			* lcCursor = Thisform.cursorname_detail
			
			* IF RECCOUNT(lcCursor) = 0 THEN 
				* Thisform.bgridResult.SetFocus
				* RETURN 
			* ENDIF
			
			* Check permission

			* lcE = CHR(13) + CHR(10)
			
			* Checks
			* DIMENSION laResult[2]
			* laResult = GF_CheckBeforeDeletingDocs(&lcCursor..id_dokum)
			* llConfirm = laResult[1]
			* llDeleteLinks = laResult[2]

			
			* Delete documents
			lcXml = '<delete_dokument xmlns="urn:gmi:nova:leasing">' + gcE
			*lcXml = lcXml + GF_CreateNode("id_dokum", &lcCursor..id_dokum, "N", 1) + gcE
			lcXml = lcXml + GF_CreateNode("id_dokum", _dr_DokZaPromjenu.id_dokum, "N", 1) + gcE
			IF llDeleteLinks = .T. THEN
				lcXml = lcXml + GF_CreateNode("delete_linked_docs", .T., "L", 1) + gcE
			ENDIF
			lcXml = lcXml + "</delete_dokument>"
			
			IF llConfirm THEN
				lcXmlResult = GF_ProcessXml(lcXml, .T., .T.)
				
				IF TYPE("lcXmlResult") != "C" THEN
					* Thisform.bgridResult.SetFocus
					POZOR("TYPE(lcXmlResult) != C")	
					lnError = lnError + 1				
					*RETURN .F.
				ELSE 
					lnOK = lnOK + 1	
				ENDIF	
	*Napomenuti da je isključena provjera 4 oka
				* ll4Eyes = XMLDataType(GF_GetSingleNodeXml(lcXmlResult, "sent_to_4eyes"), 'L', 2)
			
				* IF TYPE("ll4Eyes") != "L" THEN
					* Thisform.bgridResult.SetFocus
					* RETURN .F.
				* ENDIF
				
				* IF (ll4Eyes)
					* OBVESTI(FOUREYES_QUEUE_OK)
				* ELSE 
					* obvesti(INFDELETED_LOC)
					* thisform.runsql
				* ENDIF
			ENDIF
			* Thisform.bgridResult.SetFocus
		* ENDPROC
	ENDSCAN
ENDIF
OBVESTI ("Uspješno: "+TRANS(lnOK) +gce + "Neuspješno"+TRANS(lnError))
