loForm = GF_GetFormObject("frmKalkulacija")

IF ISNULL(loForm) THEN 
 RETURN
ENDIF

LOCAL lcStariAlias, lcSql, lcZakupi, LcList_condition, llol_na_nacin_fl
lcStariAlias = ALIAS()

**Obavezan unos kategorije na ponudu RLC #1666 !!drugi dio u preveri podatke!!
loForm.pgfSve.pgPon.pgfPon.pgOsn.cboKategorija.obvezen = .T.
loForm.pgfSve.pgPon.pgfPon.pgOsn.cboKategorija.BackColor = 8454143

lcSql="Select Left(val,50) as val From dbo.custom_settings where code in ("+gf_quotedstr('Nova.LE.Zakup.Nekretnina')+","+gf_quotedstr('Nova.LE.Najam.Nekretnina')+")"

GF_SQLEXEC(lcSql,"tmp_zakupi")

LcList_condition = ""
lcZakupi = GF_CreateDelimitedList("tmp_zakupi", "val", LcList_condition, ",",.f.)	

select * from ponudba where id_pon = "<new>" into cursor _newponudba

if allt(lookup(nacini_l.tip_knjizenja, _newponudba.nacin_leas, nacini_l.nacin_leas)) = '1' AND ATC(allt(_newponudba.nacin_leas),lcZakupi) = 0  THEN

	llol_na_nacin_fl = lookup(nacini_l.ol_na_nacin_fl, _newponudba.nacin_leas, nacini_l.nacin_leas)

	local lnbuyback, lcXml

	lnbuyback = 0

**GF_GET_NUMBER("Unesite iznos ugovorenog otkupa, buyback/ostalo", _newponudba.opcija, "", .F., "Buyback")

	Select lnbuyback as buyback, a.opcija, a.vr_val, a.varscina, a.prv_obr_n, a.obr_mera, a.traj_naj, a.st_obrok, a.beg_end, a.man_str_n, a.dat_pon, a.str_notar, llol_na_nacin_fl as ol_na_nacin_fl From _newponudba a into cursor _zapoziv
	
	lcXML = "<?xml version="+GF_QuotedStr("1.0")+" encoding="+GF_QuotedStr("utf-8")+" ?>" + gcE
	lcXML= lcXML + "<hanfa_reklas_check xmlns="+chr(34)+"urn:gmi:nova:hr_integration_module"+chr(34)+">" + gcE
	lcXml = lcXml + GF_CreateNode("buyback", _zapoziv.buyback, "N", 1) + gcE
	lcXml = lcXml + GF_CreateNode("vr_val", _zapoziv.vr_val, "N", 1) + gcE
	lcXml = lcXml + GF_CreateNode("varscina", _zapoziv.varscina, "N", 1) + gcE
	lcXml = lcXml + GF_CreateNode("polog", _zapoziv.prv_obr_n, "N", 1) + gcE
	lcXml = lcXml + GF_CreateNode("obr_mera", _zapoziv.obr_mera, "N", 1) + gcE
	lcXml = lcXml + GF_CreateNode("opcija", _zapoziv.opcija, "N", 1) + gcE
	lcXml = lcXml + GF_CreateNode("traj_naj", _zapoziv.traj_naj, "I", 1) + gcE
	lcXml = lcXml + GF_CreateNode("st_obrok", _zapoziv.st_obrok, "I", 1) + gcE
	lcXml = lcXml + GF_CreateNode("begin_end", iif(_zapoziv.beg_end=0, .F., .T.), "L", 1) + gcE
	lcXml = lcXml + GF_CreateNode("man_str", _zapoziv.man_str_n, "N", 1) + gcE
	lcXml = lcXml + GF_CreateNode("dat_pon", _zapoziv.dat_pon, "D", 1) + gcE
	lcXml = lcXml + GF_CreateNode("ol_na_nacin_fl", llol_na_nacin_fl, "L", 1) + gcE
	lcXml = lcXml + "</hanfa_reklas_check>"

	if gf_processxml(lcXml) then
		lcResult = GOBJ_Comm.GetResult()
		lccheckresult = GF_GetSingleNodeXml(lcResult, "leas_check_type")
		
		If (lccheckresult = "FL" OR (llol_na_nacin_fl=.f. And lccheckresult = "OF")) then
			if llol_na_nacin_fl = .f. then
				=POZOR("Kalkulacija OL nije udgovoljila provjeri tipa financiranja, ponuda po takvoj kalkulaciji trebala bi biti reklasificirana u "+allt(lccheckresult)+"!")
			else
				=POZOR("Kalkulacija OF nije udgovoljila provjeri tipa financiranja, ponuda po takvoj kalkulaciji trebala bi biti reklasificirana u "+allt(lccheckresult)+"!")

			endif

			use in _newponudba
			use in _zapoziv
			if used("ponudba") then
				delete from ponudba where id_pon = "<new>"
			endif
			If !Empty(lcStariAlias) THEN
				Select (lcStariAlias)
			ENDIF	
			return .f.
		endif
	endif

endif

use in _newponudba

    If !Empty(lcStariAlias) THEN
        Select (lcStariAlias)
    ENDIF
