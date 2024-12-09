loForm = GF_GetFormObject("frmPogodba_maska")
IF ISNULL(loForm) THEN 
	RETURN
ENDIF

***********************************************************************************
* 23.09.2020 g_tomislav MID 45222 - Rind strategije: nova strategija zadnji radni dan u mjesecu  
***********************************************************************************
*llfix_dat_rpg = LOOKUP(rtip.fix_dat_rpg, ponudba.id_rtip, rtip.id_rtip) ponudba kursor nije dignut 
*Pageframe1.Page2.cmbRindStrategije

loForm.Pageframe1.Page2.txtRindDatNext.Enabled = .F.
