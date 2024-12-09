LPARAMETERS lcId_kupca 
*obvesti ("ODOBRIT_MASKA_CUSTOM_CHECK")

loForm = GF_GetFormObject("frmOdobrit_Maska")
IF ISNULL(loForm) THEN 
	RETURN
ENDIF


* g_tomislav MR 40667
IF loForm.tip_vnosne_maske == 1 && Novi zapis 
	POZOR("Da li ste predali Asistentu dokumentaciju klijenta ili Grupe na ažuriranje (evaluacija, ZSPNFT ..)?")
ENDIF