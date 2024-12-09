lcStariAlias = ALIAS()
loForm = GF_GetFormObject('frmPogodba_akt')

IF ISNULL(loForm) THEN 
	RETURN
ENDIF

*///////////////////////////////////////////////////////////////////////////
* README before adding new control
* all new controls should be placed inside SCAN loop in more/less exact code like in POGODBA_AKT_CONTRACT_ACTIVATE
* for controls that do not stop activation use lcMassage
* for controls that stop activation use lcMassageActivationStopped
* similar control and comment should be placed in POGODBA_AKT_CONTRACT_ACTIVATE
* 12.04.2024 g_tomislav MID 49740 - created

LOCAL lcMassage

lcMassage = "" 
lcMassageActivationStopped = ""

SELECT pogodba 
SCAN
* first control
	*/////////////////////////////////////////////////
	** 12.04.2024 - g_tomislav MID 49740 - provjera na maksimalnu zakonsku dozvoljenu kamatnu stopu

	lnDej_obr = pogodba.dej_obr
	lcVr_osebe = GF_SqlExecScalar("select vr_osebe from dbo.partner where id_kupca = " +GF_QUOTEDSTR(pogodba.id_kupca))
	llJeFOseba = IIF(GF_LOOKUP("vrst_ose.sifra", lcVr_osebe, "vrst_ose.vr_osebe") = "FO", .T., .F.)

	LOCAL  laPar[1] &&, lnInterestRate, llReturn   && lcSQL,lcCursor,
	TEXT TO lcSql NOSHOW
		declare @id_cont int = ?p1
		
		select pog.id_pog, pog.dej_obr, x.max_ir_used , x.max_allowedIR
		from dbo.pogodba pog
		inner join dbo.PARTNER par on pog.id_kupca = par.id_kupca
		inner join dbo.vrst_ose vo on par.vr_osebe = vo.vr_osebe
		cross join dbo.NASTAVIT n
		cross apply dbo.gfn_CalculateMaxAllowedIR(pog.dej_obr
					, pog.vr_val_zac
					, case when vo.sifra = 'FO' then 1 else 0 end
					, pog.nacin_leas, 
					cast(cast(getdate() as date) as datetime)
				) x
		where n.check_max_ir = 1
		and pog.id_cont = @id_cont
		
	ENDTEXT
	laPar[1] = pogodba.id_cont

	GF_SqlExec_P(lcSql, @laPar, "_ef_CalculatedMaxAllowedIR")

	IF _ef_CalculatedMaxAllowedIR.max_ir_used 
		lcMassageActivationStopped = lcMassageActivationStopped +"Kamatna stopa (" +ALLT(TRANS(_ef_CalculatedMaxAllowedIR.dej_obr, gcOM)) +") je viša od maksimalno dozvoljene kamatne stope (" +ALLT(TRANS(_ef_CalculatedMaxAllowedIR.max_allowedIR, gcOM)) +")." +gce +"Ugovor " +ALLT(_ef_CalculatedMaxAllowedIR.id_pog) +" se ne može aktivirati!" +gce
	ENDIF 
	** KRAJ MID 49740//////////////////////////////////


** new control should be placed here 


ENDSCAN

** displaying one massage for all controls

** for controls that do not stop activation use lcMassage
IF !EMPTY(lcMassage) AND !POTRJENO(lcMassage+gcE+"Da li želite nastaviti s aktivacijom ugovora?")
	RETURN .F. 
ENDIF

** for controls that stop activation use lcMassageActivationStopped
IF !EMPTY(lcMassageActivationStopped) 
	POZOR(lcMassageActivationStopped +gcE +"Aktivacija je zaustavljena!")
	RETURN .F. 
ENDIF

IF !EMPTY(lcStariAlias) THEN
   Select (lcStariAlias)
ENDIF 
*///////////////////////////////////////////////////////////////////////////