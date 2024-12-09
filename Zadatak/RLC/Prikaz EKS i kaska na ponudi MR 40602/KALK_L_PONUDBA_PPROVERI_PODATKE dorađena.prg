*//////////////////////////////////////////////////////////
** 07.11.2018. g_tomislav MR 40602
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
** 16.01.2019. g_tomislav MR 40602 - check for marginal amount of EKS; logic was taken from source and modified for client

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



IF nacini_l.tip_knjizenja = '2' and !nacini_l.ol_na_nacin_fl
	LOCAL llSkipEom
	llSkipEom = LOOKUP(lookup_nacini_l.eom_zero, ponudba.nacin_leas, lookup_nacini_l.nacin_leas)
	thisform.check_eom_limit
	IF !llSkipEom AND EOM_meja.exceeded THEN 
		LOCAL lcStr, lctxt, lctxt1, lnEOMMeja, lcEOM_meja_txt
		lnEOMMeja = EOM_meja.meja
		lctxt = "Efektivna obrestna mera je višja od zakonsko predpisane" && caption
		lcEOM_meja_txt= lctxt + SPACE(1) + TRANSFORM(lnEOMMeja)  + " %!" + gcE 
		lcStr = lcEOM_meja_txt
		lctxt1 = "Ali vseeno želite shraniti ponudbo?" && caption
		lcStr = lcStr + lctxt1 
		IF !potrjeno(lcStr) THEN
			RETURN .F.
		ENDIF	
	ENDIF 
ENDIF 

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



	