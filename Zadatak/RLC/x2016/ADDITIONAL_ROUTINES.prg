
	LOCAL llSuccess, lcE, lcXml, lcSql, lcCommand

	llSuccess = .F.

	SELECT dod_opravki

	DO CASE

	**Start - Dnevna rutina dodavanja retail partnera u iznimke kod zatvaranja plaćanja
	CASE ALLTRIM(opravki.klic) == 'RL_APP_NAS'
		TEXT TO lcSql NOSHOW
			exec dbo.grp_ExecuteExtFunc 'RL_SQL_APP_NAST'
		ENDTEXT
				
		GF_EXECNONQUERY(lcSql)
			**, "_APP_nast_res"
		**lcmsg1='Broj novo dodanih zapisa/partnera: '+allt(str(lookup(_app_nast_res.broj,'INSERT',_app_nast_res.upd_ins)))+CHR(13)+CHR(10)+ ;
			  'Broj postojećih zapisa/partnera dodanih u Retail: '+allt(str(lookup(_app_nast_res.broj,'UPDATE',_app_nast_res.upd_ins)))+CHR(13)+CHR(10)+ ;
			  'Broj postojećih zapisa/partnera izašlih iz Retail: '+allt(str(lookup(_app_nast_res.broj,'REMOVE',_app_nast_res.upd_ins)))+CHR(13)+CHR(10)+ ;
			  'Broj nepravilnih zapisa (unos sa brojem ugovora): '+allt(str(lookup(_app_nast_res.broj,'ERROR',_app_nast_res.upd_ins)))
		**obvesti(lcmsg1)
		llSuccess = .T.

	**End - Dnevna rutina dodavanja retail partnera u iznimke kod zatvaranja plaćanja

	CASE ALLTRIM(opravki.klic) == 'EVAL_ZPPD'
	FOR i = 1 TO _Screen.FormCount
		IF LOWER(_Screen.Forms(i).Name) == LOWER("DNEV_RUT") THEN
		loForm = _Screen.Forms(i)
		EXIT
	ENDIF
	NEXT

	&& update
	TEXT TO lcUpdate NOSHOW
		update dbo.p_eval
		set dat_nasl_vred =
			case when oall_ratin = 'XA' then dateadd(mm, 60, dat_eval)
				when oall_ratin = 'XB' then dateadd(mm, 36, dat_eval)
				when oall_ratin = 'XC' then dateadd(mm, 12, dat_eval)
				else dat_nasl_vred
		end
		where eval_type = 'Z' and dat_nasl_vred is null
	ENDTEXT
        
        	GF_ExecNonQuery(lcUpdate)

	&& select (za pregled)
	TEXT TO lcSql NOSHOW
		select count(*) as lnstevilo
		from dbo.p_eval
		where eval_type = 'Z'
		and dat_nasl_vred >= dbo.gfn_GetDatePart(getdate())
		and dat_nasl_vred <= dateadd(dd, {0}, dbo.gfn_GetDatePart(getdate()))
		and id_kupca not in (select p.id_kupca as id_kupca from dbo.p_eval p where p.eval_type='Z' and dat_nasl_vred > dateadd(dd, {0}, dbo.gfn_GetDatePart(getdate())))
	ENDTEXT
	lcSql = strtran(lcSql, "{0}", transform(loForm.txtcez_dni.value))
	GF_SQLEXEC(lcSql, "eval_result")
	lcmsg='Broj partnera za ponovno ocjenjivanje: '+allt(str(eval_result.lnstevilo))
	obvesti(lcmsg)
	llSuccess = .T.


	CASE ALLTRIM(opravki.klic) == 'DOKUM_TV'
		loForm = GF_GetFormObject("DNEV_RUT")
		IF ISNULL(loForm) THEN
			RETURN
		ENDIF
	
		lcXml = '<generate_missing_prev_pog_documents xmlns="urn:gmi:nova:common_raiffeisen">' + gcE
		lcXml = lcXml + "</generate_missing_prev_pog_documents>"

		IF !GF_ProcessXml(lcXml, .T., .F.) THEN
			llSuccess = .F.
		ELSE
			llSuccess = .T.
		ENDIF

	CASE ALLTRIM(opravki.klic) == 'INDEXIM'
			local lcResult, lcreport
			
			lcXML = "<?xml version="+GF_QuotedStr("1.0")+" encoding="+GF_QuotedStr("utf-8")+" ?>" + gcE
   			lcXML= lcXML + "<index_import_prepare xmlns="+chr(34)+"urn:gmi:nova:hr_integration_module"+chr(34)+"/>"

   			if GF_ProcessXml(lcXml, .F., .F.) then
			    lcResult = GOBJ_Comm.GetResult()
			    lcreport = GF_ReadFirstNode(lcResult,"index_import_prepare_response")
			    =obvesti(lcreport)
				llSuccess = .T.
			else
				=obvesti("Došlo je do greške kod uvoza podataka")
		   endif

CASE ALLTRIM(opravki.klic) == 'VANBILAN'
     lnIdOcReport = GF_GET_NUMBER("Unesite broj snimke", 0, "", .T., "Snimka stanja")

     if lnIdOcReport = 0 Then
        obvesti("Nepravilan broj snimke")
        llSuccess = .F.
     endif

     lnExists = GF_SQLExecScalar("Select count(*) From dbo.oc_reports Where id_oc_report ="+trans(lnIdOcReport))

     If lnExists = 0 Then
        obvesti("Nepostojeća snimka stanja!")
        llSuccess = .F.
     Endif

     If lnExists # 0 Then
        GF_SQLEXEC("Select *,  DATEADD(mm, DATEDIFF(mm, -1, date_to ), -1) as endofmonth From dbo.oc_reports Where id_oc_report = " + trans(lnIdOcReport), "_oc_reports")

	ldDateTo = _oc_reports.date_to
	lcCode = _oc_reports.code
	ldEndOfMonth = _oc_reports.endofmonth

	lnCount = GF_SQLExecScalar("Select count(*) From dbo.gl Where datum_dok = " + Gf_QuotedStr(dtos(ldDateTo)) + " And vrsta_dok = " + GF_QUOTEDSTR("VBE") + " And source_tbl =" + GF_QUOTEDSTR("FRAME_LIST"))
        lnCount1 = GF_SQLExecScalar("Select count(*) From dbo.gl_k_dnev Where datum_dok = " + Gf_QuotedStr(dtos(ldDateTo)) + " And vrsta_dok = " + GF_QUOTEDSTR("VBE") + " And source_tbl =" + GF_QUOTEDSTR("FRAME_LIST"))

	use in _oc_reports

	If lnCount = 0 And lnCount1 = 0 And lcCode = "MAIN" And (ldDateTo = ldEndOfMonth) Then
	   TEXT TO lcSql NOSHOW
	        exec dbo.grp_ExecuteExtFunc 'VBE_OFFBALANCE_BOOKINGS_FRAMES', {0}, {1}
           ENDTEXT

	   lcSql = STRTRAN(STRTRAN(lcSQL,"{0}",trans(lnIdOcReport)), "{1}", allt(GObj_Comm.UserData.GetUserName()))
           llSuccess = GF_ExecNonQuery(lcSql)
        Else
	    If lnCount #0 OR lnCount1 # 0 Then
	       lcmsg = IIF(lnCount#0,'U glavnoj knjizi postoje uknjižbe za odabranu snimku!','U dnevniku knjiženja postoje uknjižbe za odabranu snimku!')
	       obvesti(lcmsg)
	    EndIf
	    If lcCode # "MAIN" OR (ldDateTo # ldEndOfMonth) Then
	       obvesti("Odabrali ste snimku koja nije mjesečna snimka!")
	    EndIf
	    llSuccess = .F.
	Endif
     endif

	**Start - Dnevna rutina isključenje polica iz ispisa (prema doc RA)
	CASE ALLTRIM(opravki.klic) == 'RL_DOC_RA'
		TEXT TO lcSql NOSHOW
			exec dbo.grp_ExecuteExtFunc 'RL_SQL_DAILY_EX_INSURANCE_RA'
		ENDTEXT
				
		llSuccess = GF_EXECNONQUERY(lcSql)

	**End - Dnevna rutina isključenje polica iz ispisa (prema doc RA)

	CASE ALLTRIM(opravki.klic) == 'CCOAST_RET'

		loForm = GF_GetFormObject("DNEV_RUT")
		IF ISNULL(loForm) THEN
			RETURN
		ENDIF

		lcXml = '<return_assets_to_credit_contracts xmlns="urn:gmi:nova:common_raiffeisen">' + gcE
		lcXml = lcXml + "</return_assets_to_credit_contracts>"

		IF !GF_ProcessXml(lcXml, .T., .F.) THEN
			llSuccess = .F.
		ELSE
			llSuccess = .T.
		ENDIF
	
	**Start - Dnevna rutina PPMV_AKT
	CASE ALLTRIM(opravki.klic) == 'PPMV_AKT'
		TEXT TO lcSql NOSHOW
			exec dbo.grp_ExecuteExtFunc 'SQL_DAILY_PPMV_AKT'
		ENDTEXT
		
		lcSql = STRTRAN(lcSql, '{0}', ALLTRIM(GObj_Comm.UserData.GetUserName()))
		llSuccess = GF_ExecNonQuery(lcSql)
	**End - Dnevna rutina PPMV_AKT


	**Start - Dnevna rutina ALLOCATION
	CASE ALLTRIM(opravki.klic) == 'ALLOCATION'

		loForm = GF_GetFormObject("DNEV_RUT")
		IF ISNULL(loForm) THEN
			RETURN
		ENDIF
		lcXml = '<prepare_allocation_documents xmlns="urn:gmi:nova:common_raiffeisen">' + gcE
		lcXml = lcXml + "</prepare_allocation_documents>"

		IF !GF_ProcessXml(lcXml, .T., .F.) THEN
			llSuccess = .F.
		ELSE
			llSuccess = .T.
		ENDIF
	**End - Dnevna rutina ALLOCATION
	
	OTHERWISE 
		obvesti('Dnevna rutina ' + dod_opravki.klic + ' ne postoji!')
	
	ENDCASE

	REPLACE uspeh WITH llSuccess IN dod_opravki