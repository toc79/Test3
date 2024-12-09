*******************************************************
** 06.07.2021 g_tomislav MID 47163 - podešavanje obaveznih polja 'Dozvoljeni kilometri' i 'Cijena dodatnog km' te izračun cijene za grupe "VNC", "VLT", "VUC";

lcTip_opr = allt(GF_LOOKUP("vrst_opr.tip_opr", ponudba.id_vrste, "vrst_opr.id_vrste"))

IF RF_TIP_POG(ponudba.nacin_leas) == "OL" AND lcTip_opr == "V"
	
	lcGrupa = allt(GF_LOOKUP("vrst_opr.id_grupe", ponudba.id_vrste, "vrst_opr.id_vrste"))
	lnCena_dkm = ponudba.Cena_dkm
	lnIzracunataCijenaDodatnogKM = ROUND((ponudba.vr_val * 0.004) / 1000 , 2)
		
	IF INLIST(lcGrupa, "VNC", "VLT", "VUC") AND ponudba.nacin_leas != "OF" AND lnCena_dkm != lnIzracunataCijenaDodatnogKM 
		IF POTRJENO("Uneseni iznos cijene dodatnog km "+allt(trans(lnCena_dkm, gccif))+" nije jednak izračunatom "+allt(trans(lnIzracunataCijenaDodatnogKM, gccif))+". Da li želite promijeniti podatak na "+allt(trans(lnIzracunataCijenaDodatnogKM, gccif))+"?")
			loForm.pgfSve.pgPon.pgfPon.pgOsn.txtCena_dkm.Value = lnIzracunataCijenaDodatnogKM
		ENDIF
	ENDIF
	
	lnCena_dkm = ponudba.Cena_dkm

	
	IF lnCena_dkm = 0 OR ponudba.dovol_km = 0
		POZOR("Unos u polja 'Dozvoljeni kilometri' i 'Cijena dodatnog km' je obavezan za operativni leasing i tip opreme 'Vozila'!")
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
	ENDIF
ENDIF 
*******************************************************