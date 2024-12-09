loForm = GF_GetFormObject("frmOdobrit_Push")
IF ISNULL(loForm) THEN 
	RETURN 
ENDIF
*select * from result_multiple

*========================================
* g_tomislav MR 31112
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
* KRAJ MR 31112
*========================================
*========================================
* 03.02.2021 g_tomislav MR 46103 - obavijest kada partner ima status drugačiji od 00 BEZ POSEBNOSTI ili RCV RECOVERED
LOCAL lcListaId_kupca, lcP_status

select distinct id_kupca from result_multiple into cursor _ef_distinct_id_kupca

lcListaId_kupca = GF_CreateDelimitedList("_ef_distinct_id_kupca", "id_kupca ", "", ",", .T.)

GF_SQLEXEC("select id_kupca, naziv1_kup, p_status from dbo.partner where id_kupca in ("+lcListaId_kupca+")", "_ef_partner")

lcPoruka = ""

select _ef_partner
go top
scan
	lcP_status = allt(_ef_partner.p_status)
	
	IF !GF_NULLOREMPTY(lcP_status) and lcP_status != "00" and lcP_status != "RCV"
		lcPoruka = lcPoruka + _ef_partner.id_kupca +" " +allt(_ef_partner.naziv1_kup) +", status: " +lcP_status +" " +allt(GF_GeneralRegister("P_STATUS", lcP_status, "value")) + gce
	ENDIF
endscan

use in _ef_distinct_id_kupca
use in _ef_partner

IF !empty(lcPoruka) 
	POZOR("Partner(i) ima(ju) status: " +gce +lcPoruka +"!") 
ENDIF
* KRAJ 46103
*========================================