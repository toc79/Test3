* LE_ODOBRIT_PUSH_PREVERI_MULTIPLE_PODATKE_CUSTOM
* g_tomislav MR 31112 
loForm = GF_GetFormObject("frmOdobrit_Push")
IF ISNULL(loForm) THEN 
	RETURN 
ENDIF
*select id_document from result_multiple
LOCAL lcListaId_document, lcStatusNew, lcUser 

lcListaId_document = GF_CreateDelimitedList("result_multiple", "id_document ", "", ",")

lcStatusNew = ALLTRIM(TRANSFORM(loForm.lstWF_New_Status.value))

IF lcStatusNew = "ODO" && Odobrenje 

	lcUser = allt(GObj_Comm.getUserName())

	GF_SQLEXEC("select * from dbo.wf_history where id_status_old='' and id_status_new='VNS' and id_document in ("+lcListaId_document+") AND user_entered="+gf_quotedstr(lcUser) ,"_rf_history")
	IF RECCOUNT()>0 
		POZOR("Korisnik koji je unio odobrenje ne može isto i odobriti!")
		return .f.
	ENDIF
	USE IN _rf_history
ENDIF

* JEDNO LE_ODOBRIT_PUSH_PREVERI_PODATKE_CUSTOM
* g_tomislav MR 31112
loForm = GF_GetFormObject("frmOdobrit_Push")
IF ISNULL(loForm) THEN 
	RETURN
ENDIF

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