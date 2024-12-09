loForm = GF_GetFormObject("frmKalkulacija")

IF ISNULL(loForm) THEN 
 RETURN
ENDIF

* 22.05.2017 g_tomislav MR 37739
loForm.pgfSve.pgPon.pgfPon.pgOsn.txtZap_2ob.obvezen = .T.
loForm.pgfSve.pgPon.pgfPon.pgOsn.txtZap_2ob.BackColor = 8454143

** 22.11.2018 g_dejank MR 41561

loForm.pgfSve.pgPon.pgfPon.pgOsn.txtProdajalec.obvezen = .T.
loForm.pgfSve.pgPon.pgfPon.pgOsn.txtProdajalec.BackColor = 8454143

loForm.pgfSve.pgPon.pgfPon.pgOsn.txtPosrednik.obvezen = .T.
loForm.pgfSve.pgPon.pgfPon.pgOsn.txtPosrednik.BackColor = 8454143

**03.04.2020 g_tkovacev MR 43354
loForm.pgfSve.pgPon.pgfPon.pgOsn.txtRefinanc.obvezen = .T.
loForm.pgfSve.pgPon.pgfPon.pgOsn.txtRefinanc.BackColor = 8454143

**30.06.2021 g_tomislav MID 47163
IF !GF_NULLorEMPTY(ponudba.nacin_leas) AND RF_TIP_POG(ponudba.nacin_leas) == "OL" 
	loForm.pgfSve.pgPon.pgfPon.pgOsn.txtCena_dkm.obvezen = .T.
	loForm.pgfSve.pgPon.pgfPon.pgOsn.txtCena_dkm.BackColor = 8454143
	loForm.pgfSve.pgPon.pgfPon.pgOsn.txtDovol_km.obvezen = .T.
	loForm.pgfSve.pgPon.pgfPon.pgOsn.txtDovol_km.BackColor = 8454143
else
	loForm.pgfSve.pgPon.pgfPon.pgOsn.txtDovol_km.obvezen = .F.
	loForm.pgfSve.pgPon.pgfPon.pgOsn.txtDovol_km.BackColor = RGB(255,255,255)
	loForm.pgfSve.pgPon.pgfPon.pgOsn.txtCena_dkm.obvezen = .F.
	loForm.pgfSve.pgPon.pgfPon.pgOsn.txtCena_dkm.BackColor = RGB(255,255,255)
ENDIF

