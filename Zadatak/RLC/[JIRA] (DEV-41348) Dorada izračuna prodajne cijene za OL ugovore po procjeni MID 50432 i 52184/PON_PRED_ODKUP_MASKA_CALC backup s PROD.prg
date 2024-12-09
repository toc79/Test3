LOCAL loForm

loForm = GF_GetFormObject("PON_PRED_ODKUP")

FOR i = 1 TO _Screen.FormCount

	IF UPPER(_Screen.Forms(i).Name) == "PON_PRED_ODKUP" THEN
		loForm = _Screen.Forms(i)

		&& Provjera datuma ponude po MR 22954
		IF loForm.pgfPonudba.Page1.txtDatumPonudbe.value != DATE() THEN
			POZOR("Datum ponude ne smije biti različit od današnjeg!")
			loForm.pgfPonudba.Page1.txtDatumPonudbe.Setfocus
			REPLACE ni_napaka WITH .f. IN cur_extfunc_error
		ENDIF

		IF _Screen.Forms(i).pgfPonudba.Page1.txtDodTer.value <> 0 THEN
			LOCAL lcid_pog, lnOld, lnNew, lnOdg, lcVal, lnZrac, lnDej
			lcId_pog = loForm.pgfPonudba.Page1.txtId_pog.value

			&& Poziv funkcije koja priprema pregled troškova
			&& ARG. => IdCont, DatIzrac, ShowForm (.t./.f.), Id_tec, RazlikaBruto (.t./.f.)
			GF_SQLEXEC("select id_cont from pogodba where id_pog = "+gf_quotedstr(lcId_pog),"_POG")
			lnOld = loForm.pgfPonudba.Page1.txtDodTer.value
			lnNew = GF_PrometDodatniStroski(_pog.id_cont, date(), .F., 	loForm.pgfPonudba.Page1.lstTecaj.value,.F.)
			lcVal = loForm.pgfPonudba.Page1.txtValuta.value
			
			&& sumiranje diskontiranih stvarnih troškova
			SELECT _dejan
			GO TOP
			CALCULATE sum(znesek) TO lnZrac
			
			&& sumiranje diskontiranih prihodovanih predviđenih troškova
			SELECT _zarac
			GO TOP
			CALCULATE sum(znesek) TO lnDej
			
			&& sučeljavanje diskontiranih iznosa
			lnNew = lnZrac - lnDej
			
			&& pitaj korniska da li želiš neto sučeljeni iznos ili zadrži ponuđeni iznos
			IF loForm.pgfPonudba.Page1.txtDodTer.value != lnNew and potrjeno('Bruto iznos dodatnih troškova iznosi '+allt(trans(lnold,gccif))+' '+lcVal+', da li želite koristiti neto iznos ('+allt(trans(lnNew,gccif))+' '+lcVal+') dodatnih troškova kod izračuna ponude?') THEN
				loForm.pgfPonudba.Page1.txtDodTer.value = lnNew
			ENDIF

		ENDIF
	ENDIF

NEXT

**12.01.2022 g_vuradin MR48007- kreiranje provjere i obavijesti prilikom izrade ponude

TEXT TO lcSQL NOSHOW   

select sum(a.obavijest) as obavijest
from(
select count(*) as obavijest from dbo.gl where konto in ('412301' ,'710107' ,'710104') and id_kupca='000040' and id_cont={1}
union all
select count(*) as obavijest from dbo.GL_ARHIV
where konto in ('412301' ,'710107' ,'710104') and id_kupca='000040' and id_cont= {1}) a

ENDTEXT 

lcSql = STRTRAN(lcSql, "{1}", TRANS(POGODBA.id_cont))

GF_SQLEXEC(lcSql, "_FINA_PROVJERA")

IF _FINA_PROVJERA.obavijest >=1
Obvesti("Pažnja! Ostali troškovi – FINA.")
ENDIF