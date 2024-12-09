local lcNacinLeas, lcTipLeas
lcNacinLeas = GF_LOOKUP('pogodba.nacin_leas',fakture.id_cont,'pogodba.id_cont')
lcTipLeas = RF_TIP_POG(lcNacinLeas)

IF lcNacinLeas # 'OP' and fakture.id_terj = '27'
	POZOR("Samo za Ugovore tipa OP izdaje se potraživanja 27!")
		SELECT cur_extfunc_error
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
ENDIF

IF lcNacinLeas # 'OJ' and fakture.id_terj = '28'
	POZOR("Samo za Ugovore tipa OJ izdaje se potraživanja 28!")
		SELECT cur_extfunc_error
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
ENDIF

IF lcTipLeas = 'OL' And fakture.id_terj = '1L' THEN
	POZOR("Za OL tip leasinga nije dozvoljeno korištenje potraživanja POSEBAN POREZ NA MV!")

	IF !POTRJENO("Da li unatoč upozorenju želite ispostaviti račun ?")
	  SELECT cur_extfunc_error
	  REPLACE ni_napaka WITH .F. IN cur_extfunc_error
	ENDIF
ENDIF

IF at(lcNacinLeas, 'NF, NO, PF, PO')=0 and fakture.id_terj = '62'
	POZOR("Samo za Ugovore tipa NF, NO, PF, PO izdaje se potraživanja 62!")
		SELECT cur_extfunc_error
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
ENDIF

IF !fakture.is_third_party and fakture.id_terj = '31'
	POZOR("Samo za fiktivne ugovore (TP) izdaje se potraživanje 31!")
		SELECT cur_extfunc_error
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
ENDIF

*///////////////////////////////
* 25.09.2018 g_tomislav MR 41159
IF fakture.id_terj == "2D" AND ! INLIST(lcNacinLeas, "F1", "F2", "F2", "F4", "F5")
	POZOR("Potraživanje 2D se izdaje samo za ugovore tipa: F1, F2, F2, F4 i F5!")
	SELECT cur_extfunc_error
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error
ENDIF

IF fakture.id_terj == "2E" AND ! INLIST(lcNacinLeas, "OA", "OJ", "OG", "OR", "OF")
	POZOR("Potraživanje 2E se izdaje samo za ugovore tipa: OA, OJ, OG, OR i OF!")
	SELECT cur_extfunc_error
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error
ENDIF
* KRAJ MR 41159
*///////////////////////////////

**27.04.2021 g_barbarak MID 46769
IF fakture.id_terj == "2M" AND ! INLIST(lcNacinLeas, "F1", "F2", "F3", "F4", "F5")
	POZOR("Potraživanje 2M se izdaje samo za financijski tip leasinga")
	SELECT cur_extfunc_error
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error
ENDIF
****************
