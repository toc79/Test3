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

IF !(ISNULL(dokument.id_cont)) and dokument.id_obl_zav = 'TV'
	loForm.txtKategorija1.obvezen = .T.
ENDIF