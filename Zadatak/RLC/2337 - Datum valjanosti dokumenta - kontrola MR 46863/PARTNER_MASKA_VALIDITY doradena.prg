** 14.05.2021 g_tomislav MID 46863
IF 	!GF_NULLOREMPTY(partner.d_velj_os_izk) AND partner.d_velj_os_izk < DATE() THEN
	IF loForm.tip_vnosne_maske = 1
		POZOR("Datum valjanosti osobnog dokumenta ne može biti u prošlosti!")
		REPLACE ni_napaka WITH .f. IN cur_extfunc_error
	ELSE
		IF !POTRJENO("Datum valjanosti osobnog dokumenta je u prošlosti. Da li želite nastaviti sa spremanjem?")
			REPLACE ni_napaka WITH .f. IN cur_extfunc_error
		ENDIF
	ENDIF
ENDIF
