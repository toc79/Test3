local lnid_odobrit, lcXml, lcresult, lcdoneok, lcid_pon, llje_nk 

lnid_odobrit= result.id_odobrit
lcid_pon = result.id_pon 

llje_nk = GF_SQLExecScalar("Select je_nk From dbo.ponudba where id_pon =" + GF_QuotedStr(lcid_pon))

if llje_nk = .t. then
	=obvesti("Proces se ne može pokrenuti za ponude koje imaju nestandardnu kalkulaciju!")
	return .f.
endif


lcXML = "<?xml version="+GF_QuotedStr("1.0")+" encoding="+GF_QuotedStr("utf-8")+" ?>" + gcE
lcXML= lcXML + "<start_bpm_process xmlns="+chr(34)+"urn:gmi:nova:hr_raiffeisen"+chr(34)+">" + gcE
lcXml = lcXml + GF_CreateNode("id_odobrit", lnid_odobrit, "N", 1) + gcE
lcXml = lcXml + "</start_bpm_process>"

**=obvesti(lcxml)
WAIT WIND 'Pripremam podatke' NOWAIT
if GF_ProcessXml(lcXml, .F., .F.) then
  FOR i = 1 TO _Screen.FormCount
	IF LOWER(_Screen.Forms(i).Name) == LOWER("frmodobrit_pregled") THEN
		loForm = _Screen.Forms(i)
		EXIT
	ENDIF
	NEXT
	lcResult = GOBJ_Comm.GetResult()
	lcdoneok = GF_ReadFirstNode(lcResult,"doneOk")
	lcerror = GF_ReadFirstNode(lcResult,"error")
	
	if lcdoneok = "true" then
		=obvesti("Obrada je uspješno završena.")
	else
		=obvesti("Greška kod obrade: " + gcE + allt(lcerror))
	endif
		
	**loForm.runsql()
  
else
  =obvesti("Došlo je do greške prilikom obrade!")
endif
  
return .f.