*PROD
*g_vuradin 04.05.2021 - MID 46678 2319 - BS- Business segmentacija i evidentiranje u NOVA  

loForm = GF_GetFormObject("frmpartner_eval_maska")

IF ISNULL(loForm) THEN 
 RETURN
ENDIF


IF p_eval_vnos.EVAL_TYPE == 'B'
	loForm.txteval_type.Enabled = .F. && da se ne može raditi promjena vrste evaluacije
loForm.txtasset_clas.obvezen = .T.
loForm.txtasset_clas.BackColor = 8454143
ENDIF

*TEST
loForm = GF_GetFormObject("frmpartner_eval_maska")

IF ISNULL(loForm) THEN 
 RETURN
ENDIF


IF p_eval_vnos.EVAL_TYPE == 'B'
	loForm.txteval_type.Enabled = .F. && da se ne može raditi promjena vrste evaluacije
loForm.txtasset_clas.obvezen = .T.
loForm.txtasset_clas.BackColor = 8454143
ENDIF


*05.07.2022 g_vuradin - MID47492 validacija za unos ratinga za tip C evaluacije

IF p_eval_vnos.EVAL_TYPE == 'C'
	loForm.txteval_type.Enabled = .F. && da se ne može raditi promjena vrste evaluacije
loForm.txtcust_ratin.obvezen = .T.
loForm.txtcust_ratin.BackColor = 8454143
loForm.txtoall_ratin.obvezen = .T.
loForm.txtoall_ratin.BackColor = 8454143
ENDIF



*PREBAČENO

loForm = GF_GetFormObject("frmpartner_eval_maska")

IF ISNULL(loForm) THEN 
 RETURN
ENDIF

*g_vuradin 04.05.2021 - MID 46678 2319 - BS- Business segmentacija i evidentiranje u NOVA 
IF p_eval_vnos.EVAL_TYPE == 'B'
	loForm.txteval_type.Enabled = .F. && da se ne može raditi promjena vrste evaluacije
loForm.txtasset_clas.obvezen = .T.
loForm.txtasset_clas.BackColor = 8454143
ENDIF


*05.07.2022 g_vuradin - MID47492 validacija za unos ratinga za tip C evaluacije
** 18.07.2022 g_tomislav MID 49144 - prebacivanje na produkciju i poravnavanje. Dodan komentar za iznad MID 46678

IF p_eval_vnos.EVAL_TYPE == 'C'
	loForm.txteval_type.Enabled = .F. && da se ne može raditi promjena vrste evaluacije
	loForm.txtcust_ratin.obvezen = .T.
	loForm.txtcust_ratin.BackColor = 8454143
	loForm.txtoall_ratin.obvezen = .T.
	loForm.txtoall_ratin.BackColor = 8454143
ENDIF 
