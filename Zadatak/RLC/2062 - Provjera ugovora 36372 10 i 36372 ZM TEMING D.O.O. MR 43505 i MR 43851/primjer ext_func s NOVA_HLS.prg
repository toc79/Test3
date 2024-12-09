OBVESTI('REPRO_SELECT_PREVERI_PODATKE_CUSTOM')

LOCAL loForm, lcXML, lcE
loForm = NULL

loForm = GF_GetFormObject("REPRO_SELECT")

IF ISNULL(loForm) THEN
	RETURN
ENDIF


IF loForm.repro_type = "2" THEN 

	if used('automatic_rpg') then
		use in _automatic_rpg
	endif

	local lcXMLresult, lcrootNode 

	lcXMLresult = loForm.XMLDoc

** obvesti (lcXMLresult) NE KORISTITI Buffer underrun error
_cliptext = lcXMLresult 

	lcrootNode = "//rpg_res/rpg_calc/automatic_rpg"

	DIMENSION CursorDescription(13,17)

	CursorDescription(1,1) = "id_cont"
	CursorDescription(1,2) = "I"
	CursorDescription(1,3) = 4
	CursorDescription(1,4) = 0
	CursorDescription(1,5) = .F.
	CursorDescription(1,6) = .F.
	CursorDescription(1,7) = "id_cont"

	CursorDescription(2,1) = "new_principal"
	CursorDescription(2,2) = "N"
	CursorDescription(2,3) = 18
	CursorDescription(2,4) = 2
	CursorDescription(2,5) = .F.
	CursorDescription(2,6) = .F.
	CursorDescription(2,7) = "new_principal"

	CursorDescription(3,1) = "new_interest_rate"
	CursorDescription(3,2) = "N"
	CursorDescription(3,3) = 9
	CursorDescription(3,4) = 4
	CursorDescription(3,5) = .F.
	CursorDescription(3,6) = .F.
	CursorDescription(3,7) = "new_interest_rate"

	CursorDescription(4,1) = "man_costs_brut"
	CursorDescription(4,2) = "N"
	CursorDescription(4,3) = 18
	CursorDescription(4,4) = 2
	CursorDescription(4,5) = .F.
	CursorDescription(4,6) = .F.
	CursorDescription(4,7) = "man_costs_brut"

	CursorDescription(5,1) = "other_services"
	CursorDescription(5,2) = "N"
	CursorDescription(5,3) = 18
	CursorDescription(5,4) = 2
	CursorDescription(5,5) = .F.
	CursorDescription(5,6) = .F.
	CursorDescription(5,7) = "other_services"

	CursorDescription(6,1) = "normal_installment_count"
	CursorDescription(6,2) = "I"
	CursorDescription(6,3) = 4
	CursorDescription(6,4) = 0
	CursorDescription(6,5) = .F.
	CursorDescription(6,6) = .F.
	CursorDescription(6,7) = "normal_installment_count"

	CursorDescription(7,1) = "new_res_value"
	CursorDescription(7,2) = "N"
	CursorDescription(7,3) = 18
	CursorDescription(7,4) = 2
	CursorDescription(7,5) = .F.
	CursorDescription(7,6) = .F.
	CursorDescription(7,7) = "new_res_value"

	CursorDescription(8,1) = "first_installment_amount"
	CursorDescription(8,2) = "N"
	CursorDescription(8,3) = 18
	CursorDescription(8,4) = 2
	CursorDescription(8,5) = .F.
	CursorDescription(8,6) = .F.
	CursorDescription(8,7) = "first_installment_amount"

	CursorDescription(9,1) = "first_installment_date"
	CursorDescription(9,2) = "D"
	CursorDescription(9,3) = 8
	CursorDescription(9,4) = 0
	CursorDescription(9,5) = .F.
	CursorDescription(9,6) = .F.
	CursorDescription(9,7) = "first_installment_date"

	CursorDescription(10,1) = "old_target_date"
	CursorDescription(10,2) = "D"
	CursorDescription(10,3) = 8
	CursorDescription(10,4) = 0
	CursorDescription(10,5) = .F.
	CursorDescription(10,6) = .F.
	CursorDescription(10,7) = "old_target_date"

	CursorDescription(11,1) = "new_target_date"
	CursorDescription(11,2) = "D"
	CursorDescription(11,3) = 8
	CursorDescription(11,4) = 0
	CursorDescription(11,5) = .F.
	CursorDescription(11,6) = .F.
	CursorDescription(11,7) = "new_target_date"

	CursorDescription(12,1) = "dynamics_id"
	CursorDescription(12,2) = "C"
	CursorDescription(12,3) = 4
	CursorDescription(12,4) = 0
	CursorDescription(12,5) = .F.
	CursorDescription(12,6) = .F.
	CursorDescription(12,7) = "dynamics_id"

	CursorDescription(13,1) = "new_r_interests"
	CursorDescription(13,2) = "N"
	CursorDescription(13,3) = 18
	CursorDescription(13,4) = 2
	CursorDescription(13,5) = .F.
	CursorDescription(13,6) = .F.
	CursorDescription(13,7) = "new_r_interests"

	GF_XML2Cursor(@CursorDescription, "_automatic_rpg", lcXMLresult, lcrootNode)
select * from _automatic_rpg
	IF allt(rep_category.id_rep_category) != '004' AND (_automatic_rpg.new_principal != reprogram_sumavtomat.sumneto OR _automatic_rpg.new_interest_rate != reprogram_sumavtomat.obr_mera OR ;
	_automatic_rpg.new_res_value != reprogram_sumavtomat.opcija OR _automatic_rpg.normal_installment_count != reprogramstartdate.startdate) THEN
		IF !POTRJENO ('Došlo je do promjene u jednom od polja: Nova glavnica, Kamatna stopa, Novi broj rata ili Nova buduća vrijednost, a nije odabrana kategorija reprograma Restrukturiranje. Želite li nastaviti s reprogramom?')
			RETURN .F.
		ENDIF
	ENDIF
ELSE
	if used('_repr_samo_kamata') then
		use in _repr_samo_kamata
	endif

	select * from reprogramnew where debit = obresti and id_terj = "21" into cursor _repr_samo_kamata
    IF RECCOUNT("_repr_samo_kamata") > 0 AND allt(rep_category.id_rep_category) != '004' THEN
		IF !POTRJENO ('Postoji potraživanje NAJAMNINA/RATA koje ima samo kamatu, a nije odabrana kategorija reprograma Restrukturiranje. Želite li nastaviti s reprogramom?')
			RETURN .F.
		ENDIF
	ENDIF
ENDIF
**************************************************
IF RF_TIP_POG(REPROGRAMPOGODBA.Nacin_leas) = 'OL' and RECCOUNT("REPROGRAMNEW") > RECCOUNT("REPROGRAMOLD") THEN
	obvesti ('Nakon reprograma potrebno je izvršiti korekciju i OS!')
ENDIF

**************************************************
** 11.04.2017 g_mladens; izradio prema MR 37834
LOCAL loForm, lcApprovalApprovedEndStatuses, lcPogoj, lcOdbExt, lcSQL
loForm = GF_GetFormObject('REPRO_SELECT')

lcSQL = "Select COUNT(id_doc) as cnt From dbo.gv_ObstojaOdobrit Where "
lcOdobrit = loForm.cnt_Status.txtStOdobrit.Value

lcApprovalApprovedEndStatuses = GF_CustomSettings("approval_approved_endstatuses")
lcApprovalApprovedEndStatuses = IIF(EMPTY(lcApprovalApprovedEndStatuses), "ODO", lcApprovalApprovedEndStatuses)
lcPogoj = "CHARINDEX(id_status, '" + lcApprovalApprovedEndStatuses  + "') > 0 AND aktivna = 1 AND id_cont = " + TRANSFORM(REPROGRAMPOGODBA.id_cont) 

lcOdbExt = NVL(GF_SQLExecScalarNull(lcSQL + lcPogoj), 0)

IF lcOdbExt > 0 AND GF_NULLOREMPTY(loForm.cnt_Status.txtStOdobrit.Value) THEN
	IF !POTRJENO("Broj odobrenja nije upisan, želite li nastaviti dalje?")
		RETURN .F.
	ENDIF
ENDIF