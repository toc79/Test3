ODOBRIT_MASKA_CUSTOM_CHECK	Funkcija je namenjena poljubnemu dodatnemu preverjanju partnerja na odobritvi financiranja. Kliče se na gumbu za shranjevanje tako na maski za vnos kot na maski za popravo odobritve financiranja, poleg tega pa tudi pri izdelavi ene ali večih odobritev financiranja na podlagi obstoječe odobritve financiranja in tudi pri izdelavi nove odobritve financiranja iz obstoječe odobritve financiranja na osnovi nove ponudbe.	LE - Pogodba | Odobritev financiranja - maska za vnos/popravo odobritve
ODOBRIT_MASKA_ID_KUPCA_VALID	Funkcija je namenjena poljubni predizpolnitvi polj na maski za vnos/popravo odobritve financiranja. Klic funkcije je dodan na zavihku 'Odobritev' na vnosnem polju 'Partner' v validacijo. Funkcija se sproži, ko zapustimo omenjeno polje 'Partner' (ne glede na to, ali vrednost v njem spremenimo ali ne).	LE - Pogodba | Odobritev financiranja - maska za vnos/popravo odobritve

ODOBRIT_PONUDBA_VALID		LE - Pogodba | Odobritev financiranja

LE_ODOBRIT_PUSH_PREVERI_MULTIPLE_PODATKE_CUSTOM	Funkcija je namenjena dodatnemu preverjanju na maski za spremembo statusa večih označenih odobritev financiranja. Kliče se po kliku na gumb 'Potrdi' na omenjeni maski.	LE - Pogodba | Odobritev financiranja - maska za spremembo statusa večih označenih odobritev
LE_ODOBRIT_PUSH_PREVERI_PODATKE_CUSTOM	Funkcija je namenjena dodatnemu preverjanju na maski za spremembo statusa izbrane odobritve financiranja. Kliče se po kliku na gumb 'Potrdi' na omenjeni maski.	LE - Pogodba | Odobritev financiranja - maska za spremembo statusa izbrane odobritve



ne može se zaustaviti na  ODOBRIT_MASKA_CUSTOM_CHECK


PROCEDURE preveri_podatke_custom
		GF_EXT_FUNC("ODOBRIT_MASKA_CUSTOM_CHECK", "")
		
		RETURN .T.
ENDPROC



	IF !Thisform.preveri_podatke(Thisform) OR !Thisform.preveri_podatke_custom() THEN
			RETURN .F.
		ENDIF

