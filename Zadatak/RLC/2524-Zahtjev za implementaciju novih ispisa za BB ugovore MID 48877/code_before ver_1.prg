* LOCAL LcList_condition, lcList
* LcList_condition = ""  && Mora biti 

* lcList = GF_CreateDelimitedList("pogodba", "id_cont", LcList_condition, ",", .F.) &&BEZ NAVODNIKA

* GF_SQLEXEC("SELECT id_cont FROM pogodba where id_cont IN ("+iif(len(alltrim(lcList))=0,"0",lcList)+") ORDER BY id_cont", "rezultat")
*GF_SQLEXEC("SELECT COUNT(id_obl_zav) AS cnt FROM dbo.dokument where id_cont IN ("+iif(len(alltrim(lcList))=0,"0",lcList)+") AND id_obl_zav = 'B7'", "_dok")

* IF reccount() = 0 THEN
	* =POZOR("Nema podataka za ispis!")
	* RETURN .F.
* endif

*lnId = GF_InsertSsoftReportXML("rezultat", "pogodba_pregled")

**obvesti(lnId)

* IF POTRJENO("Da li želite ispis za sve ugovore, u suprotnom ide samo trenutni?")
	* lcOdgovor = "-1"
* ELSE 
	* lcOdgovor = "0"
* ENDIF

*OBJ_ReportSelector.AddReportToPrintJobWithTitleAndFormat("POG_OBV_OTK_SSOFT_RLC2", allt(str(pogodba.id_cont))+";"+lcOdgovor , 1, "UGOVOR O OBVEZI OTKUPA", "Pdf")
*IF pogodba.nacin_leas = "OF" AND _dok.cnt > 0
	*OBJ_ReportSelector.AddReportToPrintJobWithTitleAndFormat("TABLICA_B7", lnId, 1, "TABLICA_B7", "Pdf")
*ENDIF


IF POTRJENO("Da li želite ispis za sve ugovore, u suprotnom ide samo trenutni?")
	lcId_cont = "-1"
ELSE 
	lcId_cont = allt(str(pogodba.id_cont))
ENDIF

OBJ_ReportSelector.AddReportToPrintJobWithTitleAndFormat("POG_OBV_OTK_SSOFT_RLC2", allt(pogodba.kategorija)+";"+lcId_cont , 1, "UGOVOR O OBVEZI OTKUPA", "Pdf")