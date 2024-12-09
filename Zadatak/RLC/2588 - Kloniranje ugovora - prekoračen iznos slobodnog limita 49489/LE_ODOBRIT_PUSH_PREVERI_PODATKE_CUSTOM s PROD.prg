loForm = GF_GetFormObject("frmOdobrit_Push")
IF ISNULL(loForm) THEN 
	RETURN
ENDIF

*========================================
* g_tomislav MR 31112
LOCAL lcStatusNew, lcUser 

lcStatusNew = ALLTRIM(TRANSFORM(loForm.lstWF_New_Status.value))

IF lcStatusNew = "ODO" && Odobrenje 

	lcUser = allt(GObj_Comm.getUserName())

	GF_SQLEXEC("select * from dbo.wf_history where id_status_old='' and id_status_new='VNS' and id_document="+gf_quotedstr(_odobrit.id_wf_document)+" AND user_entered="+gf_quotedstr(lcUser) ,"_rf_history")
	IF RECCOUNT()>0 
		POZOR("Korisnik koji je unio odobrenje ne može isto i odobriti!")
		return .f.
	ENDIF
	USE IN _rf_history
ENDIF
* KRAJ MR 31112
*========================================
*========================================
* 03.02.2021 g_tomislav MR 46103 - obavijest kada partner ima status drugačiji od 00 BEZ POSEBNOSTI ili RCV RECOVERED
LOCAL lcId_kupca, lcP_status

lcId_kupca = _odobrit.id_kupca &&loForm.txtId_partner.Value
lcP_status = allt(GF_LOOKUP("partner.p_status", lcId_kupca , "partner.id_kupca"))

IF !GF_NULLOREMPTY(lcP_status) and lcP_status != "00" and lcP_status != "RCV" 
	POZOR("Partner ima status "+lcP_status +" "+allt(GF_GeneralRegister("P_STATUS", lcP_status, "value")) +"!") 
ENDIF
* KRAJ 46103
*========================================