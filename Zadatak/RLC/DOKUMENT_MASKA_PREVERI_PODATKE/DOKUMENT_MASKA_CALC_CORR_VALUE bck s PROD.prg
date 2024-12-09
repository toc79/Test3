LOCAL lcText, lnOcen_vred, lnFx_discount, lcContrac_tec, lcEntity_name, llIs_resaled
LOCAL ldDate_corr_factor, lcId_vrste

loForm = GF_GetFormObject("frmdokument_maska")
IF ISNULL(loForm) THEN 
	RETURN
ENDIF

LOCAL lcSql, llMatch
llMatch = .F.

* Contract
IF !GF_NULLOREMPTY(dokument.id_cont) THEN
	llMatch = .T.
	
	IF loForm.tip_vnosne_maske = 1 THEN
		TEXT TO lcSql NOSHOW
			SELECT IsNull(p.dat_aktiv, p.dat_sklen) as date_corr_factor, p.id_vrste
			  FROM dbo.pogodba p
			 WHERE p.id_cont = {0}
		ENDTEXT
		lcSql = STRTRAN(lcSql, "{0}", TRANSFORM(dokument.id_cont))
		GF_SQLEXEC(lcSql, "_pog")
	ELSE
		TEXT TO lcSql NOSHOW
			SELECT IsNull(d.dat_korig_vred, IsNull(p.dat_aktiv, p.dat_sklen)) as date_corr_factor, p.id_vrste
			  FROM dbo.dokument d 
			 INNER JOIN dbo.pogodba p ON d.id_cont = p.id_cont 
			 WHERE d.id_cont = {0}
		ENDTEXT
		lcSql = STRTRAN(lcSql, "{0}", TRANSFORM(dokument.id_cont))
		GF_SQLEXEC(lcSql, "_pog")
	ENDIF
	
	IF !GF_NULLOREMPTY(loForm.txtDat_korig_vred.Value) THEN
		ldDate_corr_factor = loForm.txtDat_korig_vred.Value
	ELSE
		ldDate_corr_factor = _pog.date_corr_factor
	ENDIF
	
	lcId_vrste = _pog.id_vrste
	
	USE IN _pog
ENDIF

* Frame or krov. pog.
IF !GF_NULLOREMPTY(dokument.id_frame) OR !GF_NULLOREMPTY(dokument.id_krov_pog) THEN
	llMatch = .T.
	
	IF !GF_NULLOREMPTY(loForm.txtDat_korig_vred.Value) THEN
		ldDate_corr_factor = loForm.txtDat_korig_vred.Value
	ELSE
		ldDate_corr_factor = DATE()
	ENDIF
	
	lcId_vrste = null
ENDIF


* Offer
IF !GF_NULLOREMPTY(dokument.id_pon) THEN
	llMatch = .T.
	
	IF loForm.tip_vnosne_maske = 1 THEN
		TEXT TO lcSql NOSHOW
			SELECT p.dat_pon as date_corr_factor, p.id_vrste
			  FROM dbo.ponudba p
			 WHERE p.id_pon = '{0}'
		ENDTEXT
		lcSql = STRTRAN(lcSql, "{0}", dokument.id_pon)
		GF_SQLEXEC(lcSql, "_pon")
	ELSE
		TEXT TO lcSql NOSHOW
			SELECT IsNull(d.dat_korig_vred, p.dat_pon) as date_corr_factor, p.id_vrste
			  FROM dbo.dokument d 
			 INNER JOIN dbo.ponudba p ON d.id_pon = p.id_pon
			 WHERE d.id_pon = '{0}'
		ENDTEXT
		lcSql = STRTRAN(lcSql, "{0}", dokument.id_pon)
		GF_SQLEXEC(lcSql, "_pon")
	ENDIF
	
	IF !GF_NULLOREMPTY(loForm.txtDat_korig_vred.Value) THEN
		ldDate_corr_factor = loForm.txtDat_korig_vred.Value
	ELSE
		ldDate_corr_factor = _pon.date_corr_factor
	ENDIF
	
	lcId_vrste = _pon.id_vrste
	
	USE IN _pon
ENDIF


* Odobrit
IF !GF_NULLOREMPTY(dokument.id_odobrit) THEN
	llMatch = .T.
	
	IF loForm.tip_vnosne_maske = 1 THEN
		TEXT TO lcSql NOSHOW
			SELECT IsNull(p.dat_pon, getdate()) as date_corr_factor, o.id_vrste
			  FROM dbo.odobrit o
			 LEFT JOIN dbo.ponudba p on p.id_pon = o.id_pon
			 WHERE o.id_odobrit = {0}
		ENDTEXT
		lcSql = STRTRAN(lcSql, "{0}", TRANSFORM(dokument.id_odobrit))
		GF_SQLEXEC(lcSql, "_odob")
	ELSE
		TEXT TO lcSql NOSHOW
			SELECT IsNull(d.dat_korig_vred, IsNull(p.dat_pon, getdate())) as date_corr_factor, o.id_vrste
			  FROM dbo.dokument d 
			 INNER JOIN dbo.odobrit o ON d.id_pon = o.id_pon
			 LEFT JOIN dbo.ponudba p on p.id_pon = o.id_pon
			 WHERE o.id_odobrit = {0}
		ENDTEXT
	ENDIF
	lcSql = STRTRAN(lcSql, "{0}", TRANSFORM(dokument.id_odobrit))
	GF_SQLEXEC(lcSql, "_odob")
	
	IF !GF_NULLOREMPTY(loForm.txtDat_korig_vred.Value) THEN
		ldDate_corr_factor = loForm.txtDat_korig_vred.Value
	ELSE
		ldDate_corr_factor = _odob.date_corr_factor
	ENDIF
	
	lcId_vrste = _odob.id_vrste
	
	USE IN _odob
ENDIF

IF llMatch = .F. THEN
	RETURN .F.
ENDIF


* resaled assets
llIs_resaled = .F.
lcEntity_name = GF_SQLExecScalarNull("select entity_name from dbo.loc_nast")
IF ((INLIST(lcEntity_name, "RLRS", "RRRS", "RLHR") AND dokument.id_obl_zav = "RE") OR (INLIST(lcEntity_name, "RLBH") AND dokument.id_obl_zav = "RA" AND !GF_NULLOREMPTY(dokument.velja_do) AND dokument.velja_do <= DATE())) THEN
	llIs_resaled = .T.
ENDIF

IF llIs_resaled THEN
	loForm.txtKorig_vred.Value = 0
	RETURN
ENDIF

* hipoteke, zaloge, individualne evaluacije
IF (lcEntity_name = "RLHR" AND INLIST(loForm.txtid_obl_zav.Value, "H1", "H2", "H4", "H6", "HL", "IE")) ;
	OR (lcEntity_name = "RLBH" AND INLIST(loForm.txtid_obl_zav.Value, "HL", "H1", "H2", "H4", "HI", "ZG", "ZP", "IE", "EP", "ZY")) ;
	OR (INLIST(lcEntity_name, "RLRS", "RRRS") AND INLIST(loForm.txtid_obl_zav.Value, "ZA", "HI", "HL", "IE")) ;
	OR (lcEntity_name = "RLSI" AND INLIST(loForm.txtid_obl_zav.Value, "IE", "ZA", "ZC", "ZD", "ZE", "ZF", "ZQ", "ZR", "ZS", "ZT", "ZI", "ZJ", "ZM", "ZN")) THEN
	
	IF EMPTY(dokument.id_hipot) OR ISNULL(dokument.id_hipot)
		lnOcen_vred = loForm.txtVrednost.Value
		loForm.txtKorig_vred.Value = round(dokument.vrednost - IIF(GF_NULLOREMPTY(dokument.zn_prednos), 0, dokument.zn_prednos), 2)
	ELSE
		IF (lcEntity_name = "RLHR" AND INLIST(loForm.txtid_obl_zav.Value, "H1", "HL")) ;
			OR (lcEntity_name = "RLBH" AND INLIST(loForm.txtid_obl_zav.Value, "HL", "HI")) ;
			OR (INLIST(lcEntity_name, "RLRS", "RRRS") AND INLIST(loForm.txtid_obl_zav.Value, "HI", "HL")) ;
			OR (lcEntity_name = "RLSI" AND INLIST(loForm.txtid_obl_zav.Value, "ZI", "ZJ", "ZM", "ZN")) THEN
		
			TEXT TO lcSql NOSHOW
				SELECT dbo.gfn_RaiffRegionGetValueTableFactor('{0}', GETDATE(), null, '{1}', 0) as si
			ENDTEXT
		ELSE
			TEXT TO lcSql NOSHOW
				SELECT dbo.gfn_RaiffRegionGetValueTableFactor('{0}', GETDATE(), null, '{1}', 1) as si
			ENDTEXT
		ENDIF

		lcSql = STRTRAN(lcSql, "{0}", DTOS(ldDate_corr_factor))
		lcSql = STRTRAN(lcSql, "{1}", IIF(EMPTY(loForm.txtID_hipot.Value), "null", ALLTRIM(loForm.txtID_hipot.Value)))
		GF_SQLEXEC(lcSql, "korig_hipot")
		
		lnOcen_vred = round((loForm.txtVrednost.Value * korig_hipot.si) / 100, 2)
		loForm.txtKorig_vred.Value = round((dokument.vrednost * korig_hipot.si) / 100 - IIF(GF_NULLOREMPTY(dokument.zn_prednos), 0, dokument.zn_prednos), 2)
	ENDIF
	
	IF !(TYPE("loForm.ActiveControl") = "O" AND loForm.ActiveControl.Name = "txtOcen_vred") AND lnOcen_vred != dokument.ocen_vred AND potrjeno("Procjenjena vrijednost se promijenila! Da li želite da je ispravite?") THEN
		loForm.txtOcen_vred.Value = lnOcen_vred
	ENDIF
	
	IF loForm.txtKorig_vred.Value < 0 THEN
		loForm.txtKorig_vred.Value = 0
	ENDIF
ENDIF

* prevzete pogodbe (dokument TV)
IF (!GF_NULLOREMPTY(dokument.id_cont) AND loForm.txtid_obl_zav.Value = "TV" AND dokument.kategorija1 = 'PU') THEN
	TEXT TO lcSql NOSHOW
		SELECT dbo.gfn_GetValueTableFactor('{0}', GETDATE(), '{1}', null, 2) as si
	ENDTEXT
	
	lcSql = STRTRAN(lcSql, "{0}", DTOS(ldDate_corr_factor))
	lcSql = STRTRAN(lcSql, "{1}", lcId_vrste)
	GF_SQLEXEC(lcSql, "korig_tv")
	
	loForm.txtKorig_vred.Value = round((dokument.vrednost * korig_tv.si) / 100, 2)
ENDIF