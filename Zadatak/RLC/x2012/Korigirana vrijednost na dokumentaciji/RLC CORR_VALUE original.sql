LOCAL lcText, lnOcen_vred, lnFx_discount, lcContrac_tec, lcEntity_name, llIs_resaled

loForm = GF_GetFormObject("frmdokument_maska")
IF ISNULL(loForm) THEN 
	RETURN
ENDIF

LOCAL lcSql

TEXT TO lcSql NOSHOW
	SELECT p.dat_aktiv, p.dat_sklen, p.id_vrste
	  FROM dbo.dokument d 
	 INNER JOIN dbo.pogodba p ON d.id_cont = p.id_cont 
	 WHERE d.id_cont = {0}
ENDTEXT
lcSql = STRTRAN(lcSql, "{0}", TRANSFORM(dokument.id_cont))
GF_SQLEXEC(lcSql, "_pog")

* resaled assets
llIs_resaled = .F.
lcEntity_name = GF_SQLExecScalarNull("select entity_name from dbo.loc_nast")
IF ((INLIST(lcEntity_name, "RLRS", "RRRS") AND dokument.id_obl_zav = "RE") OR (INLIST(lcEntity_name, "RLHR", "RLBH") AND dokument.velja_do <= DATE())) THEN
	llIs_resaled = .T.
ENDIF

IF llIs_resaled THEN
	loForm.txtKorig_vred.Value = 0
	RETURN
ENDIF

* hipoteke, zaloge, individualne evaluacije
IF (lcEntity_name = "RLHR" AND INLIST(loForm.txtid_obl_zav.Value, "H1", "H2", "H4", "H6", "HL", "IE")) ;
	OR (lcEntity_name = "RLBH" AND INLIST(loForm.txtid_obl_zav.Value, "HL", "H1", "H2", "H4", "HI", "ZG", "ZP", "IE", "EP", "ZY")) ;
	OR (INLIST(lcEntity_name, "RLRS", "RRRS") AND INLIST(loForm.txtid_obl_zav.Value, "ZA", "HI", "HL", "IE")) THEN
	
	IF EMPTY(dokument.id_hipot) OR ISNULL(dokument.id_hipot)
		lnOcen_vred = loForm.txtVrednost.Value
		loForm.txtKorig_vred.Value = round(dokument.vrednost - dokument.zn_prednos, 2)
	ELSE
		TEXT TO lcSql NOSHOW
			SELECT dbo.gfn_GetValueTableFactor('{0}', GETDATE(), null, '{1}', 2) as si
		ENDTEXT

		lcSql = STRTRAN(lcSql, "{0}", DTOS(IIF(ISNULL(dokument.dat_korig_vred), (IIF(ISNULL(_pog.dat_aktiv), _pog.dat_sklen, _pog.dat_aktiv)), dokument.dat_korig_vred)))
		lcSql = STRTRAN(lcSql, "{1}", IIF(EMPTY(loForm.txtID_hipot.Value), "null", ALLTRIM(loForm.txtID_hipot.Value)))
		GF_SQLEXEC(lcSql, "korig_hipot")
		
		lnOcen_vred = round((loForm.txtVrednost.Value * korig_hipot.si) / 100, 2)
		loForm.txtKorig_vred.Value = round((dokument.vrednost * korig_hipot.si) / 100 - dokument.zn_prednos, 2)
	ENDIF
	
	IF !(TYPE("loForm.ActiveControl") = "O" AND loForm.ActiveControl.Name = "txtOcen_vred") AND lnOcen_vred != dokument.ocen_vred AND potrjeno("Procenjena vrednost se promenila! Da li želite da je ispravite?") THEN
		loForm.txtOcen_vred.Value = lnOcen_vred
	ENDIF
	
	IF loForm.txtKorig_vred.Value < 0 THEN
		loForm.txtKorig_vred.Value = 0
	ENDIF
ENDIF

* prevzete pogodbe (dokument TV)
IF (loForm.txtid_obl_zav.Value = "TV" AND dokument.kategorija1 = 'PU') THEN
	TEXT TO lcSql NOSHOW
		SELECT dbo.gfn_GetValueTableFactor('{0}', GETDATE(), '{1}', null, 2) as si
	ENDTEXT
	
	lcSql = STRTRAN(lcSql, "{0}", DTOS(IIF(ISNULL(dokument.dat_korig_vred), (IIF(ISNULL(_pog.dat_aktiv), _pog.dat_sklen, _pog.dat_aktiv)), dokument.dat_korig_vred)))
	lcSql = STRTRAN(lcSql, "{1}", _pog.id_vrste)
	GF_SQLEXEC(lcSql, "korig_tv")
	
	loForm.txtKorig_vred.Value = round((dokument.vrednost * korig_tv.si) / 100, 2)
ENDIF