Local lcID, lcFilter
lcID = ''

lcFilter = filter("DOKUMENT_OPOM")
lcFilter = iif(empty(lcFilter),".t.",lcFilter)
 
IF DOKUMENT_OPOM.ST_OPOMINA != 3 THEN
	lnAli_celo = rf_msgbox("Pitanje","Želite li ispis svih označenih partnera ili trenutnog partnera?","Svih","Trenutnog","Poništi")

	DO CASE
	 CASE lnAli_celo = 1 && Vse 
		Select * From DOKUMENT_OPOM Where &lcFilter AND Oznacen = .T.  ORDER BY pogodba_id_kupca, id_cont INTO CURSOR dokument_tmp
	 CASE lnali_celo = 2 && Trenutnega
		lcID = DOKUMENT_OPOM.pogodba_id_kupca
		Select * From DOKUMENT_OPOM Where &lcFilter AND pogodba_id_kupca = lcID AND Oznacen = .T. ORDER BY pogodba_id_kupca, id_cont INTO CURSOR dokument_tmp
	 OTHERWISE
		 obj_ReportSelector.obj_reportPrinter.rep_scope = "NEXT 0"
		 RETURN .f.
	ENDCASE
ELSE
	Select * From DOKUMENT_OPOM Where &lcFilter AND Oznacen = .T. AND !GF_NULLOREMPTY(DDV_ID) ORDER BY pogodba_id_kupca, id_cont INTO CURSOR dokument_tmp
ENDIF

IF RECCOUNT("dokument_tmp") = 0 THEN
	POZOR("Nema zapisa za ispis!")
	RETURN .F.
ELSE
	TEXT TO lcSQL NOSHOW
		Select a.id_kupca, a.skrbnik_1, a.stev_reg, b.naz_kr_kup, b.telefon, b.fax 
		From dbo.partner a
		Left join dbo.partner b on a.skrbnik_1 = b.id_kupca 
	ENDTEXT
		
	GF_SQLExec(lcSQl, "Skrbnik")
ENDIF

*code after
#INCLUDE locs.h

IF !POTRJENO(RECORD_PRINTED)
	RETURN .F.
ENDIF

IF upper(allt(obj_ReportSelector.obj_reportPrinter.rep_scope)) = "ALL" 
 GF_UpdateDbfield ("dokument_tmp","dok_opom","izpisan",1,"id_opom","N","","","oznacen = .T. and !isnull(ddv_id)")
ELSE
 GF_UpdateDbfield ("dokument_tmp","dok_opom","izpisan",1,"id_opom","N","",1,"oznacen = .T. and !isnull(ddv_id)")
ENDIF

USE IN dokument_tmp
USE IN Skrbnik