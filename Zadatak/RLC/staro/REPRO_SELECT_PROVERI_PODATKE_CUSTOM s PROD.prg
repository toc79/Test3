LOCAL loForm, lcApprovalApprovedEndStatuses, lcPogoj, lcOdbExt, lcSQL
loForm = GF_GetFormObject('REPRO_SELECT')
lcStariAlias = ALIAS()

**************************************************
** 11.04.2017 g_mladens; izradio prema MR 37834
**************************************************
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

**************************************************
* 05.02.2020 g_tomislav MR 43505 - created and modified;
**************************************************
IF loForm.repro_type = "2" THEN  && type of reprogram: 1= manual 2 = automatic

	if used('_ef_automatic_rpg') then
		use in _ef_automatic_rpg
	endif

	local lcXMLresult, lcrootNode 

	lcXMLresult = loForm.XMLDoc

	*_cliptext = lcXMLresult
		lcXMLresult = strtran(lcXMLresult, '<new_index_rate xsi:nil="true" />', '') && removing unsupported node
		lcXMLresult = strtran(lcXMLresult, '<new_index_date xsi:nil="true" />', '') && removing unsupported node

	lcrootNode = "//rpg_res/rpg_calc/automatic_rpg"

	DIMENSION CursorDescription(4,17)

	CursorDescription(1,1) = "id_cont"
	CursorDescription(1,2) = "I"
	CursorDescription(1,3) = 4
	CursorDescription(1,4) = 0
	CursorDescription(1,5) = .F.
	CursorDescription(1,6) = .F.
	CursorDescription(1,7) = "id_cont"

	CursorDescription(2,1) = "new_interest_rate"
	CursorDescription(2,2) = "N"
	CursorDescription(2,3) = 9
	CursorDescription(2,4) = 4
	CursorDescription(2,5) = .F.
	CursorDescription(2,6) = .F.
	CursorDescription(2,7) = "new_interest_rate"

	CursorDescription(3,1) = "new_index_rate"
	CursorDescription(3,2) = "N"
	CursorDescription(3,3) = 9
	CursorDescription(3,4) = 4
	CursorDescription(3,5) = .F.
	CursorDescription(3,6) = .F.
	CursorDescription(3,7) = "new_index_rate"
	
	CursorDescription(4,1) = "new_index_date"
	CursorDescription(4,2) = "D"
	CursorDescription(4,3) = 8
	CursorDescription(4,4) = 0
	CursorDescription(4,5) = .F.
	CursorDescription(4,6) = .F.
	CursorDescription(4,7) = "new_index_date"

	GF_XML2Cursor(@CursorDescription, "_ef_automatic_rpg", lcXMLresult, lcrootNode)

	GF_SQLEXEC("SELECT id_cont, obr_mera, fix_del, rind_zadnji, rind_datum, b.id_tiprep FROM dbo.pogodba a JOIN dbo.rtip b ON a.id_rtip = b.id_rtip WHERE id_cont = "+GF_Quotedstr(_ef_automatic_rpg.id_cont), "_ef_pogodba")

	IF _ef_automatic_rpg.new_interest_rate != _ef_pogodba.obr_mera OR !GF_NULLOREMPTY(_ef_automatic_rpg.new_index_rate) OR !GF_NULLOREMPTY(_ef_automatic_rpg.new_index_date)
		
		lnNew_index_rate = IIF(GF_NULLOREMPTY(_ef_automatic_rpg.new_index_date), _ef_pogodba.rind_zadnji, _ef_automatic_rpg.new_index_rate) && ne koristiti GF_NULLOREMPTY na polju new_index_rate zato jer EMPTY numeric polje vraća T kada je iznos 0
		ldNew_index_date = IIF(GF_NULLOREMPTY(_ef_automatic_rpg.new_index_date), _ef_pogodba.rind_datum, _ef_automatic_rpg.new_index_date)
		
		IF _ef_pogodba.id_tiprep == 0  && with no index
			lcNew_fix_del = _ef_automatic_rpg.new_interest_rate
		ELSE  && has index
			lcNew_fix_del = _ef_automatic_rpg.new_interest_rate - lnNew_index_rate
		ENDIF
		
		IF !POTRJENO("Na ugovoru su promijenjeni sljedeći podaci:"+gce+"stara vrijednost  ->  nova vrijednost"+gce ;
				+"Kamatna stopa: "+trans(_ef_pogodba.obr_mera)+"  ->  "+trans(_ef_automatic_rpg.new_interest_rate)+gce ;
				+"Marža (fiksni dio): "+trans(_ef_pogodba.fix_del)+"  ->  "+trans(lcNew_fix_del)+gce ; 
				+"Vrijednost indeksa: "+trans(_ef_pogodba.rind_zadnji)+"  ->  "+trans(lnNew_index_rate)+gce ;
				+"Datum indeksa: "+trans(DTOC(_ef_pogodba.rind_datum))+"  ->  "+trans(DTOC(ldNew_index_date))+gce ;
				+"Da li želite nastaviti?")
			RETURN .F. 
		ENDIF
	ENDIF
ENDIF
*END MR 43505 *******************************************


IF !EMPTY(lcStariAlias) THEN
 SELECT (lcStariAlias)
ENDIF