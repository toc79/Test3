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

************************************************
** 03.07.2023 g_tomislav MID 50432 - postavljanje lnNew bez pitanja za korisnik. Logika je prebačena iz PON_PRED_ODKUP_MASKA_CALC
		
IF loForm.pgfPonudba.Page1.txtDodTer.value <> 0 THEN
	LOCAL lcid_pog, lnOld, lnNew, lnOdg, lcVal, lnZrac, lnDej
	lcId_pog = loForm.pgfPonudba.Page1.txtId_pog.value

	&& Poziv funkcije koja priprema pregled troškova
	&& ARG. => IdCont, DatIzrac, ShowForm (.t./.f.), Id_tec, RazlikaBruto (.t./.f.)
	*GF_SQLEXEC("select id_cont from pogodba where id_pog = "+gf_quotedstr(lcId_pog),"_POG")
	lnId_cont = GF_LOOKUP('pogodba.id_cont', loForm.pgfPonudba.page1.txtid_pog.value, 'pogodba.id_pog')
	lnOld = loForm.pgfPonudba.Page1.txtDodTer.value
	lnNew = GF_PrometDodatniStroski(lnId_cont, date(), .F., loForm.pgfPonudba.Page1.lstTecaj.value, .F.) 
	lcVal = loForm.pgfPonudba.Page1.txtValuta.value
	
	&& sumiranje diskontiranih stvarnih troškova
	SELECT _dejan
	GO TOP
	CALCULATE sum(znesek) TO lnZrac
	
	&& sumiranje diskontiranih prihodovanih predviđenih troškova
	SELECT _zarac
	GO TOP
	CALCULATE sum(znesek) TO lnDej
	* ili se podesi neto na način GF_PrometDodatniStroski(lnId_cont, date(), .F., loForm.pgfPonudba.Page1.lstTecaj.value, .T.) s postavkom update dbo.custom_settings set val = '1' where code = 'Nova.LE.PonPredOdkup_ShowSum_CostsDifference'
	
	&& sučeljavanje diskontiranih iznosa
	lnNew = lnZrac - lnDej
	
	&& ide neto iznos
	IF loForm.pgfPonudba.Page1.txtDodTer.value != lnNew 
		OBVESTI('Bruto iznos dodatnih troškova će se promijeniti iz '+allt(trans(lnold,gccif))+' '+lcVal+' u neto iznos '+allt(trans(lnNew,gccif))+' '+lcVal+'!') 
		loForm.pgfPonudba.Page1.txtDodTer.value = lnNew
	ENDIF
ENDIF 
**Kraj 50432 ************************************