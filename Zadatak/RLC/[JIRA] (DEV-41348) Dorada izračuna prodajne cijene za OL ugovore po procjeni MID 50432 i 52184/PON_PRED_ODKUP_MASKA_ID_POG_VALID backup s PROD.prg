loForm = GF_GetFormObject("pon_pred_odkup")
IF ISNULL(loForm) THEN 
	RETURN
ENDIF

* 22.11.2019 g_tomislav MR 43694
lnId_cont = GF_LOOKUP('pogodba.id_cont', loForm.pgfPonudba.page1.txtid_pog.value, 'pogodba.id_pog')
GF_SQLEXEC("SELECT b.obnaleto, b.naziv FROM dbo.pogodba a JOIN dbo.obdobja b ON a.id_obd = b.id_obd WHERE id_cont ="+GF_QUOTEDSTR(lnId_cont), "_ef_obdobja")

IF _ef_obdobja.obnaleto != 12
	OBVESTI("Pozor!"+gce+"Ugovor nema mjesečnu otplatu (otplata je "+GF_QUOTEDSTR(allt(_ef_obdobja.naziv))+").")
ENDIF