LOCAL loForm, lcPogoj
loForm = NULL
FOR lnI = 1 TO _Screen.FormCount
	IF UPPER(_Screen.Forms(lnI).Name) == UPPER("gl_razmejitve_maska") THEN
	loForm = _Screen.Forms(lnI)
EXIT
ENDIF
NEXT
IF ISNULL(loForm) THEN
	RETURN
ENDIF

*--PROVJERA
lcDuguje=loForm.opgpas_akt.optAktivne.Value
lcPotrazuje=loForm.opgpas_akt.optPasivne.Value
lcPas_akt=gl_razmej.pas_akt
obvesti ("A: "+trans(lcDuguje)+gcE+"P: "+trans(lcPotrazuje)+gcE+"Pas_akt: "+trans(lcPas_akt))

**Kod unosa su 0 ili 1, ovisno o odabranom. Kod pregleda je uvijek optPasivne=1, optAktivne=0 zato
IF gl_razmej.pas_akt = 2
	loForm.lblkonto.Caption="Konto"
	loForm.lblraz_pkonto.Caption="Konto razgn."
ELSE
	loForm.lblkonto.Caption="Konto razgn."
	loForm.lblraz_pkonto.Caption="Konto"

ENDIF€