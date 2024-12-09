***************************************************
** 22.11.2016. g_tomislav MR 36380 - OBAVEZNO PROVJERITI -> ova kontrola koristi kursore koji su kreirani u DOKUMENT_MASKA_SET_CRL_MANDATORY 
* lista dokumenta RLC Reporting list, ključ RLC_DAT_VRACANJA 
* obavezno vezano na ext_func DOKUMENT_MASKA_SET_CRL_MANDATORY
* 07.12.2016. g_tomislav - dodan dio koda  !USED("_ef_datum_plaćanja") u DOKUMENT_MASKA_SET_CRL_MANDATORY i dodan POTRJENO

LOCAL ldDatumZadnjegPlacanja, ldKontrolniDatum, ldVrnjen36380

IF USED ("_ef_datum_plaćanja") AND !GF_NULLOREMPTY(_ef_datum_plaćanja.max_datum_placanja)
	
	ldDatumZadnjegPlacanja = _ef_datum_plaćanja.max_datum_placanja
	ldKontrolniDatum = TTOD(ldDatumZadnjegPlacanja) + 60 
	ldVrnjen36380 = loForm.txtVrnjen.Value	 && dokument.vrnjen ne puni ispravno
	
	IF !GF_NULLOREMPTY(ldVrnjen36380) 					
		IF ldVrnjen36380 > ldKontrolniDatum  AND !potrjeno ("Datum vraćanja je veći od zakonskog datuma vraćanja koji je "+gStr(ldKontrolniDatum)+". Da li želite nastaviti sa spremanjem?")
			RETURN .F.
		ENDIF
	ELSE 		
		IF !potrjeno ("Datum vraćanja nije unesen, a obavezan je za ugovore koji su istekli! Da li želite nastaviti sa spremanjem?") && DOKUMENT_MASKA_SET_CRL_MANDATORY se okida i nakon ove funkcije pa zato ovaj dio koda potreban. Ili dodati kursor i oznaku da ne treba popunjavati (dio koda) loForm.txtVrnjen.Value = DATE() 
			RETURN .F.
		ENDIF
	ENDIF
ENDIF
** KRAJ MR 36380 ************************************