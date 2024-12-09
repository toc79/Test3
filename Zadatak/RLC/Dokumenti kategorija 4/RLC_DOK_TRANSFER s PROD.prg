#INCLUDE locs.h

IF !USED("Candidates") OR RECCOUNT("Candidates") = 0
	POZOR("Za odabrane ugovore ne postoje dokumenti za koje bi se popravili podatci")
	RETURN .F.
ENDIF

LOCAL lcXml, lcXmlResult, lcID


Sele Candidates
GO TOP

SCAN
	lcID = Candidates.id_dokum
	SELECT * FROM Candidates WHERE id_dokum = lcID INTO CURSOR _dok READWRITE
	
	SELECT _dok
	SELECT * FROM _dok INTO CURSOR _dok_copy
	
	SELECT _dok
	REPLACE ima WITH pattern, popravil WITH GOBJ_Comm.GetUserName(), dat_poprave WITH DATETIME()
	
	IF _dok.ima <> _dok_copy.ima 
		lcXmlDiff = GF_CreateUpdateDifFieldsXML('DOKUMENT', "_dok", "_dok_copy")
	ELSE
		RETURN .F.
	ENDIF
	
	lcXmlDiff = lcXmlDiff + '<updated_values>' + gcE
	lcXmlDiff = lcXmlDiff + GF_CreateNode("table_name", "DOKUMENT", "C", 1)+ gcE
	lcXmlDiff = lcXmlDiff + GF_CreateNode("name", "dat_poprave", "C", 1)+ gcE
	lcXmlDiff = lcXmlDiff + GF_CreateNode("updated_value", DATETIME(), "T", 1)+ gcE
	lcXmlDiff = lcXmlDiff + '</updated_values>'+ gcE


	lcXML = "<?xml version='1.0' encoding='utf-8' ?>"+ gcE
	lcXML = lcXML + '<rpg_documentation_update_delete xmlns="urn:gmi:nova:leasing">' + gcE
	lcXML = lcXML + '<common_parameters>'+ gcE
	
	IF !GF_NULLOREMPTY(_dok.id_cont) THEN
		lcXML = lcXML + GF_CreateNode("id_cont", _dok.id_cont, "C", 1)+ gcE
	ENDIF
	IF !GF_NULLOREMPTY(_dok.id_kupca) THEN
		lcXML = lcXML + GF_CreateNode("id_kupca", _dok.id_kupca, "C", 1)+ gcE
	ENDIF

	lcXML = lcXML + GF_CreateNode("comment", _dok.opombe, "C", 1)+ gcE
	IF !GF_NULLOREMPTY(_dok.sys_ts) THEN
		lcXML = lcXML + GF_CreateNode("sys_ts", _dok.sys_ts, "I", 1) + gcE
	ENDIF
	IF !GF_NULLOREMPTY(_dok.id_dokum) THEN
		lcXML = lcXML + GF_CreateNode("id_dokum", _dok.id_dokum, "N", 1) + gcE
	ENDIF
	
	lcXML = lcXML + '</common_parameters>'+ gcE
	
	lcXML = lcXML + GF_CreateNode("is_update", .T., "L", 1) + gcE

	lcXML = lcXML + lcXmlDiff
	lcXML = lcXML + "</rpg_documentation_update_delete>"

	GF_ProcessXml(lcXml, .T., .T.)
	
	USE IN _dok
	USE IN _dok_copy	
ENDSCAN

OBVESTI("Obrada je uspješno dovršena!")

loForm = GF_GetFormObject("frmPripDok")
loForm.Release