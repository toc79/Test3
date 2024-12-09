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




**** STARO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1

IF !POTRJENO('Da li želite nastaviti?')
	*loForm.pgfPonudba.page1.txtid_pog.value=""
	*loForm.pgfPonudba.page1.txtid_pog.setfocus
	*REPLACE ni_napaka WITH .F. IN cur_extfunc_error
loForm.Show()
	*return .f.
ENDIF

****************************************
** 30.3.2012 g_tomislav - MID: 23229
lcVarscina=0
lcSe_varsc=0
lcRazlika=0

lcId_cont=loForm.pgfPonudba.page1.txtid_pog.value

&& jamčevina sa ugovora u valuti ugovora
lcVarscina = GF_SQLEXECScalar("select varscina from pogodba where id_cont=dbo.gfn_id_cont4id_pog("+gf_quotedstr(lcId_cont)+")")
lcSe_varsc = GF_SQLEXECScalar("select se_varsc from pogodba where id_cont=dbo.gfn_id_cont4id_pog("+gf_quotedstr(lcId_cont)+")")
lcId_val = GF_SQLEXECScalar("select id_val from pogodba where id_cont=dbo.gfn_id_cont4id_pog("+gf_quotedstr(lcId_cont)+")")
lcRazlika = lcSe_varsc - lcVarscina

IF lcRazlika != 0
pozor("POZOR! Saldo jamčevine nije jednak jamčevini u mapi ugovora. Razlika u valuti ugovora iznosi "+allt(trans(lcRazlika,gccif))+" "+lcId_val+".")
loForm.pgfPonudba.page1.edtRazlog.value="POZOR! Saldo jamčevine na kontima nije jednak jamčevini u mapi ugovora - provjeriti saldo i izračun sa računovodstvom."
ENDIF


** ESL reklasifikacija
** 8.4.2014 g_mladens - MID: 27334
local lcID, lcReklas, lcTestNL, lcTestVar, lcTestCnt

lcID = loForm.pgfPonudba.Page1.txtId_pog.Value
lcDatIzr = loForm.pgfPonudba.Page1.txtDatumIzrac.Value

IF !GF_NULLOREMPTY(lcID_cont) THEN
	GF_SQLExec("Select varscina, se_varsc, nacin_leas, prevzeta From dbo.pogodba  Where id_pog = "+GF_QUOTEDSTR(lcID),"_PogTest")
	lcTestNL = _PogTest.nacin_leas 

	IF lcTestNL == GF_CustomSettings('Nova.LE.Reklas.OL') OR lcTestNL == GF_CustomSettings('Nova.LE.Reklas.FL') THEN
		lcTestVar = _PogTest.se_varsc
		lcTestCnt = GF_SQLExecScalar("Select count(id_pon_pred_odkup) as cnt From dbo.pon_pred_odkup Where dat_izr = "+GF_QUOTEDSTR(DTOS(lcDatIzr))+" and id_cont = dbo.gfn_id_cont4id_pog("+GF_QUOTEDSTR(lcID )+")")

		&&PROVJERA: ne smije se unosit dva puta na isti dan ponuda za isti par, O9 ne smije imati jamčevinu
		IF lcTestCnt > 0 THEN
			POZOR("Za odabrani Ugovor već postoji ponuda na "+DTOC(lcDatIzr)+".")
			REPLACE ni_napaka WITH .F. IN cur_extfunc_error
		ELSE
			IF lcTestVar > 0 THEN
				POZOR("Ugovor ima jamčevinu (reklasificirane Ugovre s jamčevinom potrebno je ručno obrađivati)")
				REPLACE ni_napaka WITH .F. IN cur_extfunc_error
			ENDIF
		ENDIF
	ENDIF
ELSE
	OBVESTI("NIJE UPISAN UGOVOR!")
ENDIF

USE IN _PogTest
** Kraj reklasifikacije




*** POZIV KALKULKACIJE NAPLAĆENOG PPMVa I PREOSTALOG IZNOSA ZA NAPLATITI - POČETAK ***
local lcSqlx, lnId_cont, ldDatIzrPPMV, lnImaPPMV, lnImaDatum_reg 

ldDatIzrPPMV = Date()

lnId_cont = GF_LOOKUP('pogodba.id_cont', loForm.pgfPonudba.page1.txtid_pog.value, 'pogodba.id_pog')
lnImaPPMV =  GF_SQLEXECScalar("select isnull(robresti_sit,0) from dbo.pogodba where id_cont="+allt(trans(lnId_cont)))

lnImaDatum_reg = GF_SQLEXECScalar("select count(dat_1upor) as broj from dbo.zap_reg where dat_1upor IS NOT NULL and id_cont="+allt(trans(lnId_cont)))

IF lnImaDatum_reg = 0 AND lnImaPPMV > 0 THEN
	Obvesti("Pažnja! Ugovor ima PPMV ali u zapisniku nije unesen Datum prve upotrebe! Izračun PPMV-a nije moguć!")
	RETURN .f.
ENDIF

IF lnImaPPMV > 0 THEN
	TEXT TO lcSqlx NOSHOW
		exec dbo.grp_ExecuteExtFunc 'HR_SQL_OST_PPMV_KALK', {0}, {1}
	ENDTEXT

	lcSqlx = STRTRAN(STRTRAN(lcSQLx,"{0}", trans(lnId_cont)), "{1}", GF_QUOTEDSTR(DTOS(ldDatIzrPPMV)))
	
	GF_SQLExec(lcSqlx,"ppmv_kalk")

	Select GF_LOOKUP('pogodba.id_pog', ppmv_kalk.id_cont, 'pogodba.id_cont') as Broj_ugovora, ;
	dtoc(calc_date) as Datum_izračuna, ;
	trans(Zac_ppmv_pog_dom, gccif) as Početni_iznos_PPMV_HRK, ;
	trans(Fakt_ppmv_racout_dom+Fakt_ppmv_tec_raz_dom, gccif) as Naplaceni_PPMV_HRK, ;
	Traj_upotrebe as Trajanje_upotrebe, ;
	trans(Calc_preost_ppmv_dom, gccif) as Preostali_dio_PPMV_prema_tabeli, ;
	trans(Stvar_preost_ppmv_dom, gccif) as Stvarni_preostali_iznos, ;
	trans(Pdv_osnova_ppmv_dom, gccif) as Osnova_PPMV_za_oporezivanje, ;
	trans(Oslob_osnova_ppmv_dom, gccif) as Oslobodeni_dio_PPMV ;
	from ppmv_kalk
ELSE 
	Return .f.
ENDIF


**DO additional_routine in custom_reports with 555

*** POZIV KALKULKACIJE NAPLAĆENOG PPMVa I PREOSTALOG IZNOSA ZA NAPLATITI - KRAJ ***

