LOCAL loForm
loForm = NULL
FOR lnI = 1 TO _Screen.FormCount
	IF UPPER(_Screen.Forms(lnI).Name) == UPPER("frmpartner_maska") THEN
	loForm = _Screen.Forms(lnI)
EXIT
ENDIF
NEXT
IF ISNULL(loForm) THEN
	RETURN
ENDIF
loForm.pgfPartner.Page1.lblDav_stev.Caption="Por.broj OIB"
loForm.pgfPartner.Page1.lblregstev.Caption="MBO/MBS"
loForm.pgfPartner.Page1.lblEmso.Caption="JMBG/MB"
loForm.pgfPartner.Page1.txtDav_Stev.obvezen = .T.
loForm.pgfPartner.Page1.txtDav_Stev.BackColor = 8454143

Replace partner.id_skis with "P" in partner
loForm.pgfPartner.Page1.txtId_skis.value="P"
loForm.pgfPartner.Page1.txtId_skis.Valid