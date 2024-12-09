Local loForm, ldDatAkt, ldDatPot
loForm = GF_GetFormObject('frmPogodba_akt')

ldDatAkt = loForm.datumakt
ldDatPot = pogodba.DAT_PODPISA

IF GF_NULLOREMPTY(ldDatPot) OR ldDatAkt < ldDatPot
	IF !POTRJENO("Datum aktivacije je manji od datuma potpisa ugovora, da li želite aktivirati ugovor?")
		RETURN .F.
	ENDIF 
ENDIF