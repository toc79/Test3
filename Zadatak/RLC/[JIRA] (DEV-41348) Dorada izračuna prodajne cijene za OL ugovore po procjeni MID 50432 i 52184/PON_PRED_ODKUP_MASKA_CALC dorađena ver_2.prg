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
		
		** 03.07.2023 g_tomislav MID 50432 - logika popunjavanja txtDodTer je prebačena u PON_PRED_ODKUP_MASKA_ID_POG_VALD

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