LOCAL loForm, lcSql1, lcId_cont

lcId_cont = dokument.id_cont
loForm = NULL

FOR lnI = 1 TO _Screen.FormCount
	IF UPPER(_Screen.Forms(lnI).Name) == UPPER("frmdokument_maska") THEN
		loForm = _Screen.Forms(lnI)
		EXIT
	ENDIF
NEXT
IF ISNULL(loForm) THEN
	RETURN
ENDIF

TEXT TO lcSql1 NOSHOW
	Select id_cont, id_tec, id_val from dbo.pogodba where id_cont = {0}
ENDTEXT
lcSql1 = STRTRAN(lcSql1, '{0}', trans(lcId_cont))

if dokument.id_obl_zav = allt(GF_CustomSettings("ROL_DOCUMENT_DONT_SEND")) OR dokument.id_obl_zav = allt(GF_CustomSettings("ROL_REACTIVATE_DOCUMENT"))
	If _Screen.Forms(lnI).tip_vnosne_maske = 1
		loForm.chkPotrebno.Value = 0
		loForm.chkIma.Value = 1
	EndIf
endif

if dokument.id_obl_zav = allt(GF_CustomSettings("ROL_ADD_OBJECT_DOCUMENT"))
	loForm.txtVrednost.Obvezen = .t.
	loForm.lblVrednost.Caption = "Neto vrij. objekta"
	loForm.txtStevilka.Obvezen = .f.
	loForm.lblStevilka.Caption = "Ser.br./šas/trup"
	loForm.edtOpis1.Obvezen = .t.
	loForm.lblOpis1.Caption = "Marka"
	loForm.edtOpombe.Obvezen = .t.
	loForm.lblOpombe.Caption = "Model"
	loForm.txtId_tec.Enabled = .f.
	loForm.txtId_zapo.Enabled = .f.
	loForm.txtKategorija3.Obvezen = .t.
	loForm.lblKategorija3.Caption = "Vrsta objekta"
	loForm.chkIs_elligible.Caption = "Prodano"
	If _Screen.Forms(lnI).tip_vnosne_maske = 1
		GF_SQLEXEC(lcSQL1, "_pog_rol")
		loForm.chkPotrebno.Value = 0
		loForm.chkIma.Value = 1
		loForm.txtId_tec.Value = _pog_rol.id_tec
		loForm.txtId_Val.Value = _pog_rol.id_val
		use in _pog_rol
	EndIf
endif

if dokument.id_obl_zav = allt(GF_CustomSettings("ROL_CORRECTION_VALUE_DOCUMENT"))
	loForm.txtVrednost.Obvezen = .t.
	loForm.lblVrednost.Caption = "Neto vrij. objekta"
	loForm.txtId_tec.Enabled = .f.
	If _Screen.Forms(lnI).tip_vnosne_maske = 1
		GF_SQLEXEC(lcSQL1, "_pog_rol")
		loForm.chkPotrebno.Value = 0
		loForm.chkIma.Value = 1
		loForm.txtId_tec.Value = _pog_rol.id_tec
		loForm.txtId_Val.Value = _pog_rol.id_val
		use in _pog_rol
	EndIf
endif

**RLHR ticket ??
IF !(ISNULL(dokument.id_cont)) and dokument.id_obl_zav = 'TV'
	loForm.txtKategorija1.obvezen = .T.
ENDIF

**RLHR ticket 1575
TEXT TO lcSQL NOSHOW
	DECLARE @lista varchar(300)
	SET @lista = (Select value from dbo.GENERAL_REGISTER Where ID_REGISTER = 'RLC Reporting list' and id_key = 'RLC_OBV_HIPOT' and neaktiven = 0)

	IF EXISTS (Select LTRIM(RTRIM(id)) as id From dbo.gfn_GetTableFromList(@lista) Where  LTRIM(RTRIM(id)) = '{0}')
		BEGIN
			Select CAST(1 as bit) as ima
		END
	ELSE
		BEGIN
			Select CAST(0 as bit) as ima
		END
ENDTEXT

lcSQL = STRTRAN(lcSQL, "{0}", ALLT(dokument.id_obl_zav))
lcDOK = GF_SQLExecScalarNull(lcSQL)

IF !GF_NULLOREMPTY(lcDOK) AND lcDOK = .T. THEN
	loForm.txtid_hipot.obvezen = .T.
ENDIF

***********************************************************************************************************
**23.08.2016 - g_dejank - dodavanje kontrola, obavezna polja po vrsti dokumenta po MR 36186
**INLIST prihvača najviše 24 argumenta zato je stavljeno u 2 dijela

IF INLIST(dokument.id_obl_zav,'AK','BG','BK','D1','E1','E2','ED','EG','EL','EN','EO','EP','EZ') OR INLIST(dokument.id_obl_zav,'G1','G2','GL','GO','H1','H2','HL','IE','OP','OZ','PW','PZ','PŽ','RA','RE')
	loForm.txtvelja_do.Obvezen = .t.
	loForm.txtvelja_do.BackColor = 8454143
	loForm.txtzacetek.Obvezen = .t.
	loForm.txtzacetek.BackColor = 8454143
	loForm.txtid_tec.Obvezen = .t.
	loForm.txtid_tec.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'AK','BG','BK','D1','E1','E2','ED','EG','EL','EN','EO','EP','EZ') OR INLIST(dokument.id_obl_zav,'G1','G2','GL','GO','H1','H2','HL','IE','OP','OZ','PW','PZ','PŽ','RA')
	loForm.txtOcen_vred.Obvezen = .t.
	loForm.txtOcen_vred.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'BG','D1','E1','E2','ED','EG','EL','EN','EO','EP') OR INLIST(dokument.id_obl_zav,'G1','G2','GL','GO','H1','H2','HL','IE','RA','RE')
	loForm.txtvrednost.Obvezen = .t.
	loForm.txtvrednost.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'BG','D1','E1','E2','ED','EG','EL','EN','EO','EP','EZ') OR INLIST(dokument.id_obl_zav,'G1','G2','GL','GO','H1','H2','HL','IE','OZ','RA')
	loForm.txtTip_cen.Obvezen = .t.
	loForm.txtTip_cen.BackColor = 8454143
	loForm.txtDat_ocene.Obvezen = .t.
	loForm.txtDat_ocene.BackColor = 8454143
	loForm.txtid_hipot.Obvezen = .t.
	loForm.txtid_hipot.BackColor = 8454143
	loForm.txtDat_vred.Obvezen = .t.
	loForm.txtDat_vred.BackColor = 8454143
	loForm.txtKategorija1.Obvezen = .t.
	loForm.txtKategorija1.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'BG','D1','E1','E2','ED','EG','EL','EN','EO','EP','EZ') OR INLIST(dokument.id_obl_zav,'G1','G2','GL','GO','H1','H2','OZ')
	loForm.txtExtid.Obvezen = .t.
	loForm.txtExtid.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'D1','E1','E2','ED','EL','EO','EZ','EP','H2') OR INLIST(dokument.id_obl_zav,'G1','G2','GL','GO','OZ')
	loForm.txtId_kupca.Obvezen = .t.
	loForm.txtId_kupca.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'E1','E2','ED','EG','EL','EN','EO','EP','EZ')
	loForm.txtKategorija4.Obvezen = .t.
	loForm.txtKategorija4.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'BG','E1','E2','EG','EL','EO','G1','G2','GO','RA','RE')
	loForm.txtKategorija2.Obvezen = .t.
	loForm.txtKategorija2.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'EZ','PW','PZ','PŽ')
	loForm.txtId_pov_dok.Obvezen = .t.
	loForm.txtId_pov_dok.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'RA')
	loForm.txtDat_korig_vred.Obvezen = .t.
	loForm.txtDat_korig_vred.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'RA')
	loForm.txtdatum.Obvezen = .t.
	loForm.txtdatum.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'AK','BK','D1','ED','EZ','OP','OZ','PW','PZ','PŽ')
	loForm.txtstevilka.Obvezen = .t.
	loForm.txtstevilka.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'AK','BK','EZ','OP','OZ','PW','PZ','PŽ')
	loForm.txtid_zav.Obvezen = .t.
	loForm.txtid_zav.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'BG','D1','E1','ED','EG')
	loForm.txtid_sdk.Obvezen = .t.
	loForm.txtid_sdk.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'EN','H1','HL')
	loForm.txtStatus_zk.Obvezen = .t.
	loForm.txtStatus_zk.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'EN','H1','HL')
	loForm.txtid_npr_enote.Obvezen = .t.
	loForm.txtid_npr_enote.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'EN','EP','H1','H2')
	loForm.txtRang_hipo.Obvezen = .t.
	loForm.txtRang_hipo.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'EN','EP','H1','H2')
	loForm.txtZn_prednos.Obvezen = .t.
	loForm.txtZn_prednos.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'EN','H1','HL','RE')
	loForm.txtKategorija3.Obvezen = .t.
	loForm.txtKategorija3.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'BG','E1','E2','EG','EO','G1','G2','GO')
	loForm.txtKategorija6.Obvezen = .t.
	loForm.txtKategorija6.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'HP','PU')
	loForm.txtDat_ocene.Obvezen = .t.
	loForm.txtDat_ocene.BackColor = 8454143
	loForm.txtTip_cen.Obvezen = .t.
	loForm.txtTip_cen.BackColor = 8454143
	loForm.txtvrednost.Obvezen = .t.
	loForm.txtvrednost.BackColor = 8454143
	loForm.txtid_tec.Obvezen = .t.
	loForm.txtid_tec.BackColor = 8454143
ENDIF
***********************************************************************************************************