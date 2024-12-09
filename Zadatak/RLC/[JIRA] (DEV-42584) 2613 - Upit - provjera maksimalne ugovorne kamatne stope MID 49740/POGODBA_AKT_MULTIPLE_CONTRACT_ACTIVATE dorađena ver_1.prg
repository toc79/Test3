lcStariAlias = ALIAS()
loForm = GF_GetFormObject('frmPogodba_akt')

IF ISNULL(loForm) THEN 
	RETURN
ENDIF

*///////////////////////////////////////////////////////////////////////////
* similar control and comment should be placed in POGODBA_AKT_CONTRACT_ACTIVATE
* all new controls ahould be placed inside SCAN loop
* 11.04.2024 g_tomislav MID 49740 - created

LOCAL lcMassage

lcMassage = ""
lcMassageActivationStopped = ""

SELECT pogodba 
SCAN
* first control
	*/////////////////////////////////////////////////
	** 27.12.2023 - g_tomislav MID 49740 - provjera na maksimalnu zakonsku dozvoljenu kamatnu stopu (based from GF_MaxAllowedIR(ponudba.dej_obr, ponudba.vr_val, ponudba.je_foseba, nacini_l.tip_knjizenja, pogodba.dat_sklen, 0))

	lnDej_obr = pogodba.dej_obr
	lcVr_osebe = GF_SqlExecScalar("select vr_osebe from dbo.partner where id_kupca = " +GF_QUOTEDSTR(pogodba.id_kupca))
	llJeFOseba = IIF(GF_LOOKUP("vrst_ose.sifra", lcVr_osebe, "vrst_ose.vr_osebe") = "FO", .T., .F.)

	LOCAL  laPar[5] &&, lnInterestRate, llReturn   && lcSQL,lcCursor,
	TEXT TO lcSql NOSHOW
		SELECT max_ir_used, max_allowedIR
		FROM dbo.gfn_CalculateMaxAllowedIR(?p1, ?p2, ?p3, ?p4, ?p5)
	ENDTEXT
	laPar[1] = lnDej_obr
	laPar[2] = pogodba.vr_val
	laPar[3] = llJeFOseba
	laPar[4] = nacini_l.tip_knjizenja
	laPar[5] = DTOS(DATE())

	GF_SqlExec_P(lcSql, @laPar, "_ef_CalculatedMaxAllowedIR")

	IF _ef_CalculatedMaxAllowedIR.max_ir_used 
		lcMassageActivationStopped = lcMassageActivationStopped +"Kamatna stopa (" +ALLT(TRANS(lnDej_obr, gcOM)) +") je viša od maksimalno dozvoljene kamatne stope (" +ALLT(TRANS(_ef_CalculatedMaxAllowedIR.max_allowedIR, gcOM)) +")." +gce +"Ugovor se ne može aktivirati!" +gce
		*USE IN _ef_CalculatedMaxAllowedIR
		*RETURN .F.
	ENDIF 
	** KRAJ MID 49740//////////////////////////////////
ENDSCAN

** for controls that do not stop activation
IF !EMPTY(lcMassage) AND !POTRJENO(lcMassage+gcE+"Da li želite nastaviti s aktivacijom ugovora?")
	RETURN .F. 
ENDIF

** for controls that stop activation
IF !EMPTY(lcMassageActivationStopped) 
	POZOR(lcMassageActivationStopped +gcE +"Aktivacija je zaustavljena!")
	RETURN .F. 
ENDIF

IF !EMPTY(lcStariAlias) THEN
   Select (lcStariAlias)
ENDIF 
*///////////////////////////////////////////////////////////////////////////