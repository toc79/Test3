** 19.12.2023 g_tomislav MID 50837

IF POTRJENO("Da li želite uvesti i izdati poraživanja 31 za TP ugovore iz xml/excel datoteke (plugin generate_general_invoices)?")

	LOCAL lcXml, lcresult, lcResultString 

	lcXML = ""
	lcXML = "<?xml version="+GF_QuotedStr("1.0")+" encoding="+GF_QuotedStr("utf-8")+" ?>" + gcE
	lcXML = lcXML + "<generate_general_invoices xmlns="+chr(34)+"urn:gmi:nova:hr_raiffeisen"+chr(34)+">" + gcE
	lcXml = lcXml + GF_CreateNode("issue_invoice_new_third_party_contract", .T., "L", 1) + gcE
	lcXml = lcXml + "</generate_general_invoices>"

	**=obvesti(lcxml)
	WAIT WIND 'Pripremam podatke' NOWAIT
	IF GF_ProcessXml(lcXml, .F., .F.) THEN
		lcResult = GOBJ_Comm.GetResult()
		lcResultString = GF_ReadFirstNode(lcResult, "string")
	
		OBVESTI("Obrada je završena!" +gce +lcResultString)
		**loForm.runsql()	  
	ELSE
		OBVESTI("Obrada se nije izvršila!")
	ENDIF
ENDIF	  

RETURN .F.
