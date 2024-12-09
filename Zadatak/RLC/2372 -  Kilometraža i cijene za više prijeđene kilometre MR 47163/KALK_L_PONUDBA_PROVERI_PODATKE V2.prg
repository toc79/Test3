loForm = GF_GetFormObject("frmKalkulacija")

IF ISNULL(loForm) THEN 
 RETURN
ENDIF

LOCAL lcStariAlias
lcStariAlias = ALIAS()

**Obavezan unos kategorije na ponudu RLC #1666
IF GF_NULLOREMPTY(ponudba.kategorija) THEN
	POZOR("Na ponudi je obaveznno odabrati kategoriju")
	loForm.pgfSve.pgPon.pgfPon.pgOsn.cboKategorija.SetFocus
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error
ENDIF


*//////////////////////////////////////////////////////////
** 01.02.2019. g_tomislav MR 40602
LOCAL lcSifraVr_osebe
lcSifraVr_osebe = NVL(GF_SQLExecScalarNull("SELECT b.sifra FROM dbo.partner a INNER JOIN dbo.vrst_ose b ON a.vr_osebe = b.vr_osebe WHERE a.id_kupca = "+GF_QuotedStr(ponudba.id_kupca)), "")

IF INLIST(ponudba.nacin_leas, "F1", "F2", "F3", "F4") AND (lcSifraVr_osebe == "FO" OR ponudba.je_foseba)
	
	SELECT * FROM pon_terj_stros WHERE znesek > 0 AND id_stroska IN ('KO') INTO CURSOR _ef_pon_terj_stros_KO 
	SELECT * FROM pon_terj_stros WHERE znesek > 0 AND id_stroska IN ('IK') INTO CURSOR _ef_pon_terj_stros_IK 

	IF RECCOUNT("_ef_pon_terj_stros_KO") == 0 OR RECCOUNT("_ef_pon_terj_stros_IK") == 0
		POZOR("Za fizičku osobu za ugovore tipa F1, F2, F3 i F4 je obavezno unijeti troškove KO Kasko osiguranje i IK Interkalarna kamata!")
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error 
	ENDIF

	IF USED ("_ef_pon_terj_stros_KO")
		USE IN _ef_pon_terj_stros_KO
	ENDIF
	IF USED ("_ef_pon_terj_stros_IK")
		USE IN _ef_pon_terj_stros_IK
	ENDIF
ENDIF
*//////////////////////////////////////////////////////////

*//////////////////////////////////////////////////////////
** 01.02.2019. g_tomislav MR 40602 - check for marginal amount of EKS; logic was taken from source and modified for client

IF LOOKUP(lookup_nacini_l.tip_knjizenja, ponudba.nacin_leas, lookup_nacini_l.nacin_leas) == "2" AND ! LOOKUP(lookup_nacini_l.ol_na_nacin_fl, ponudba.nacin_leas, lookup_nacini_l.nacin_leas)
	LOCAL llSkipEom
	llSkipEom = LOOKUP(lookup_nacini_l.eom_zero, ponudba.nacin_leas, lookup_nacini_l.nacin_leas)
	
	loForm.check_eom_limit
	
	IF !llSkipEom AND EOM_meja.exceeded THEN 
		LOCAL lcStr, lctxt, lctxt1, lnEOMMeja, lcEOM_meja_txt
		lnEOMMeja = EOM_meja.meja
		lctxt = "Efektivna kamatna stopa je viša od zakonski propisane" && caption
		lcEOM_meja_txt= lctxt + SPACE(1) + TRANSFORM(lnEOMMeja)  + " %!" + gcE 
		lcStr = lcEOM_meja_txt
		lctxt1 = "Ponuda se ne može spremiti." && caption
		lcStr = lcStr + lctxt1 
		POZOR(lcStr) 
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error		
	ENDIF 
ENDIF 
*//////////////////////////////////////////////////////////


If !GF_NULLOREMPTY(lcStariAlias) THEN
	Select (lcStariAlias)
ENDIF

***********************************************************
** MID: 42571 g_tkovacev 31.05.2019 - kontrola zbog ne osvježavanja tečaja ponude (neto)
** MID: 42571 g_tkovacev 04.06.2019 - prepravljena kontrola da se ne može koristiti samo tečaj '005'

IF ponudba.neto != 0 and ponudba.id_tec_n = '005'
	pozor ('Gornji tečaj na podkalkulaciji ne smije biti ('+ponudba.id_tec_n+').')
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error 
ENDIF

***********************************************************
** MID: 42571 g_tkovacev 31.05.2019 - kontrola zbog ne osvježavanja tečaja ponude (bruto)
** MID: 42571 g_tkovacev 04.06.2019 - prepravljena kontrola da se ne može koristiti samo tečaj '005'

IF ponudba.bruto != 0 and ponudba.id_tecvr = '005'
	pozor ('Donji tečaj na podkalkulaciji ne smije biti ('+ponudba.id_tecvr+').')
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error 
ENDIF

*******************************************************
*MID: 42571 g_tkovacev 09.05.2019. - provjera tečaja kod spremanja ponude

lcTec = ponudba.id_tec
IF lcTec = '005'
	POZOR('Nije moguće spremiti ponudu sa tečajem - Srednji tečaj EUR RBA')
	return .F.
ENDIF
*******************************************************
** 14.06.2019, g_dejank, MR 41640
** 26.02.2020, g_dejank, MR 44301 uz RBAP dodan i RBAF
** 21.4.2021. g_andrijap mr 46654 dodano DOBP I DOPF
IF INLIST(TRIM(ponudba.id_posrednik), "RBAP","RBAF","DOBP","DOPF") AND GF_NULLOREMPTY(ponudba.id_pon_ext) THEN
	pozor ('Ponuda je sa portala i potrebno je popuniti polje Br. pon. vanj. sistem.')
	loForm.pgfSve.pgPon.pgfPon.pgOsn.txtStPonZunSistem.SetFocus
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error 
ENDIF
*******************************************************
** 18.09.2020. g_tomislav MR 45384
* 1.
lcId_tiprep = lookup(rtip.id_tiprep, ponudba.id_rtip, rtip.id_rtip) && 0 označava fiksnu stopu

IF ponudba.id_tec == "000" and lcId_tiprep != 0 && za fizičke i pravne to znači da ovo vrijedi za sve!? Kontrola ne može ići KALK_L_BTNDODAJ_RETURN zato što SPEC_CENE nije obavezna za sve tipove leasinga
	POZOR ("Ponuda nije ispravna: financiranje u "+allt(GOBJ_Settings.GetVal("dom_valuta"))+" i promjenjiva kamatna stopa!")
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error
ENDIF
* 2.
lcId_rtip_base = lookup (rtip.id_rtip_base , ponudba.id_rtip, rtip.id_rtip) && not null označava izvedeni indeks

IF ponudba.je_foseba and rf_tip_pog(ponudba.nacin_leas) == "F1" and !gf_nullorempty(lcId_rtip_base)
	POZOR ("Ponuda nije ispravna: financiranje fizičkih osoba na financijski leasing i promjenjiva kamatna stopa s izvedenim indeksom!")
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error
ENDIF
*******************************************************
** 02.07.2021 g_tomislav MID 47163 - created;

lcGrupa = allt(GF_LOOKUP("vrst_opr.id_grupe", ponudba.id_vrste, "vrst_opr.id_vrste"))

IF RF_TIP_POG(ponudba.nacin_leas) == "OL" AND INLIST(lcGrupa, "VNC", "VLT", "VUC") 
	lnCena_dkm = ponudba.Cena_dkm

	IF lnCena_dkm = 0 OR ponudba.dovol_km = 0
		POZOR("Unos u polja 'Dozvoljeni kilometri' i 'Cijena dodatnog km' je obavezan za operativni leasing i grupu opreme VNC, VLT i VUC!")
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
	ELSE
	
		lnCijenaDodatnogKM = ROUND((ponudba.vr_val * 0.004) / 1000 , 2)
		
		IF lnCena_dkm != lnCijenaDodatnogKM AND ponudba.nacin_leas != "OF"
			IF POTRJENO("Uneseni iznos cijene dodatnog km "+allt(trans(lnCena_dkm, gccif))+" nije jednak izračunatom "+allt(trans(lnCijenaDodatnogKM, gccif))+". Da li želite promijeniti podatak na "+allt(trans(lnCijenaDodatnogKM, gccif))+"?")
				loForm.pgfSve.pgPon.pgfPon.pgOsn.txtCena_dkm.Value = lnCijenaDodatnogKM
			ENDIF
		ENDIF
	ENDIF
ENDIF 
*******************************************************