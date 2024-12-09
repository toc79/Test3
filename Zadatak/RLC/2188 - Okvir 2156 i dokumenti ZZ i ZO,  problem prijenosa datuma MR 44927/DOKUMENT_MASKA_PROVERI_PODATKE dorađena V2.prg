LOCAL loForm
loForm = GF_GetFormObject("frmdokument_maska")
IF ISNULL(loForm) THEN 
	RETURN
ENDIF

***************************************************
** 22.11.2016. g_tomislav MR 36380 - OBAVEZNO PROVJERITI -> ova kontrola koristi kursore koji su kreirani u DOKUMENT_MASKA_SET_CRL_MANDATORY 
* lista dokumenta RLC Reporting list, ključ RLC_DAT_VRACANJA 
* obavezno vezano na ext_func DOKUMENT_MASKA_SET_CRL_MANDATORY
* 07.12.2016. g_tomislav MR 36958 - dodan dio koda  !USED("_ef_datum_plaćanja") u DOKUMENT_MASKA_SET_CRL_MANDATORY i dodan POTRJENO

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

***************************************************
*!* 24.09.2015 Omar; MID 31711 - izrada
*!* 15.10.2015 Omar; MID 33028 - dorada
*!* 27.10.2015 Omar; MID 33028 - dorada
*!* 24.07.2018 g_tomislav MID 40834 - dorada za kandidate krovne dokumentacije za okvir, sada se gledaju samo oni iz posebnog šifranta
*!* 19.06.2020 g_tomislav MID 44927 - u slučaju greške kod izvođenja GF_ProcessXml se promjena napravila na krovnom (bio je samo RETURN bez .F.) dok po dokumentima ugovora ZO nije. Dodana obavijest korisniku oko broja promjena i zaustavljen nastavak spremanja
*!* 26.06.2020 g_tomislav MID 44927 - podešeno da se poruka prikazuje samo kad se radi promjena tj. pokreće GF_ProcessXml

LOCAL lnId_dokum, lnId_cont, lnId_frame, lcId_obl_zav, ldVrnjen, ldVrnjen_baza, lcOpomba
LOCAL lcXML, lcE

ldVrnjen = dokument.vrnjen
*opcija radi samo kada izmjenjeni podatak vrnjen nije null
IF !GF_NULLOREMPTY(ldVrnjen) THEN
	*provjera da li je na masci trenutnog dokumenta mjenjan podatak dokument.vrnjen 
	lnId_dokum = dokument.id_dokum
	* cursor iz kojeeg će se raditi izmjene
	create cursor _dokumenti_za_promjenu ;
	( ;
    id_cont number(10,0) NOT NULL, cast_sys_ts character(19) NOT NULL, id_dokum number(10,0) NOT NULL, vrnjen_new datetime NOT NULL, popravil character(10) NOT NULL ;
	)
	ldVrnjen_baza = gf_lookup("dokument.vrnjen", lnId_dokum, "dokument.id_dokum")
	IF ldVrnjen != NVL(ldVrnjen_baza, {01.01.1900}) THEN 
		*provjera da li je ugovor sa dokumenta vezan za okvir ili je dokument vezan izravno za okvir
		lnId_cont = dokument.id_cont
		lcId_obl_zav = dokument.id_obl_zav
		lnId_frame = iif(GF_NULLOREMPTY(dokument.id_frame), gf_lookup("frame_pogodba.id_frame", lnId_cont, "frame_pogodba.id_cont"), dokument.id_frame)
		GF_SqlExec("SELECT * FROM dbo.frame_pogodba WHERE id_frame = " + GF_QuotedStr(lnId_frame), "_okvir_ugovor")
		local lcSql, lcPopravil
		lcPopravil = GOBJ_Comm.GetUserName()
		*ugovor je vezan za okvir
		IF RECCOUNT("_okvir_ugovor") > 0 THEN
			* 24.07.2018 g_tomislav MR 40834 - dorada za kandidate krovne dokumentacije za okvir, sada se gledaju samo oni iz posebnog šifranta 
				TEXT TO lcSQL40834 NOSHOW
					DECLARE @lista varchar(max)
					SET @lista = (Select value from dbo.GENERAL_REGISTER Where ID_REGISTER = 'RLC Reporting list' and id_key = 'RLC_KROV_INST_OSIG' and neaktiven = 0) 
		
					SELECT * FROM dbo.dokument WHERE id_frame = {0} AND id_obl_zav IN (SELECT id FROM dbo.gfn_GetTableFromList(@lista))
				ENDTEXT
	
			lcSQL40834 = STRTRAN(lcSQL40834, "{0}", trans(lnId_frame))
			GF_SQLEXEC(lcSQL40834, "_okvir_krovni_dokument")		
			
			*provjera da li okvir ima unešenu krovnu dokumentaciju jer to određuje način ažuriranja
			IF RECCOUNT("_okvir_krovni_dokument") = 0 THEN 
				*stari okviri koji nemaju krovnu dokumentaciju
				IF lcId_obl_zav = "ZO" THEN
					*promjena se radi samo na dokumentima vrste ZO koji nemaju unešen datum vraćanja i koji su vezani za zaključene ugovor
					*MID 33028 dokumenti koji već imaju unešen datum vraćanja se ne uzimaju u obzir
					TEXT TO lcSql NOSHOW 
						SELECT fp.id_frame, d.*, CAST(d.sys_ts as bigint) as cast_sys_ts
						FROM dbo.frame_pogodba fp 
						INNER JOIN dbo.pogodba p ON fp.id_cont = p.id_cont
						INNER JOIN dbo.dokument d ON fp.id_cont = d.id_cont 
						WHERE fp.id_frame = {0}
						AND d.id_obl_zav = 'ZO'
						AND d.id_dokum <> {2}
						AND d.vrnjen IS NULL
						AND p.status_akt = 'Z'
					ENDTEXT 
					lcSql = STRTRAN(lcSql,'{0}', GF_QuotedStr(lnId_frame))
					lcSql = STRTRAN(lcSql,'{2}', GF_QuotedStr(lnId_dokum))
					GF_SqlExec(lcSql, "_stari_okvir_dokument")
					sele _stari_okvir_dokument 
					go top
					scan				
						insert into _dokumenti_za_promjenu (id_cont, cast_sys_ts, id_dokum, vrnjen_new, popravil) ;
						VALUES (_stari_okvir_dokument.id_cont, _stari_okvir_dokument.cast_sys_ts, _stari_okvir_dokument.id_dokum, ldVrnjen, lcPopravil)
					endscan
					use in _stari_okvir_dokument
				ENDIF
			ELSE
				*okviri koji imaju krovnu dokumentaciju
				*da li je popunjen datum vraćanja na zadnjem krovnom dokumentu ili ako su svi krovni dokumenti popunjeni ali se mjenja unešeni podatak
				select * from _okvir_krovni_dokument where !GF_NULLOREMPTY(vrnjen) into cursor _okvir_krovni_dokument_sa_popunjenim_vrnjen
				IF RECCOUNT("_okvir_krovni_dokument") - iif(GF_NULLOREMPTY(ldVrnjen_baza), 1, 0) == RECCOUNT("_okvir_krovni_dokument_sa_popunjenim_vrnjen") and ldVrnjen != NVL(ldVrnjen_baza, {01.01.1900}) THEN
					*trebamo sve dokumente ZO sa ugovora (na krovnim dokumentima je već popunjen taj podatak) koji su vezani za zaključene ugovore koji su vezani za okvir
					*MID 33028 dokumenti koji već imaju unešen datum vraćanja se ne uzimaju u obzir
					TEXT TO lcSql NOSHOW 
						SELECT fp.id_frame, d.*, CAST(d.sys_ts as bigint) as cast_sys_ts
						FROM dbo.frame_pogodba fp 
						INNER JOIN dbo.pogodba p ON fp.id_cont = p.id_cont
						INNER JOIN dbo.dokument d ON fp.id_cont = d.id_cont 
						WHERE fp.id_frame = {0}
						AND d.id_obl_zav = 'ZO'
						AND d.id_dokum <> {2}
						AND d.id_frame IS NULL
						AND d.vrnjen IS NULL
						AND p.status_akt = 'Z'
					ENDTEXT 
					lcSql = STRTRAN(lcSql,'{0}', GF_QuotedStr(lnId_frame))
					lcSql = STRTRAN(lcSql,'{2}', GF_QuotedStr(lnId_dokum))
					GF_SqlExec(lcSql, "_novi_okvir_dokument")
					sele _novi_okvir_dokument 
					go top
					scan				
						insert into _dokumenti_za_promjenu (id_cont, cast_sys_ts, id_dokum, vrnjen_new, popravil) ;
						VALUES (_novi_okvir_dokument.id_cont, _novi_okvir_dokument.cast_sys_ts, _novi_okvir_dokument.id_dokum, ldVrnjen, lcPopravil)
					endscan
					use in _novi_okvir_dokument
				ENDIF
			use in _okvir_krovni_dokument_sa_popunjenim_vrnjen
			ENDIF
			
			IF RECCOUNT("_dokumenti_za_promjenu") > 0 THEN && izvrši samo ako ima dokumenata za promjenu
			
				sele _dokumenti_za_promjenu
			
				lnUkupno=RECCOUNT()
				lnErrorCount=0
				lnUspjesno=0
				lcUgovoriUGresci=""
				lcPoruka=""	   
				
				go top
				scan
					LOCAL lcXML

					lcXML = ""
					lcXML = lcXML + "<?xml version='1.0' encoding='utf-8' ?>" + gcE
					lcXML = lcXML + '<rpg_documentation_update_delete xmlns="urn:gmi:nova:leasing">' + gcE
					lcXML = lcXML + '<common_parameters>'+ gcE
					lcXML = lcXML + GF_CreateNode("id_cont", _dokumenti_za_promjenu.id_cont, "N", 1)+ gcE
					lcXML = lcXML + GF_CreateNode("comment", "Automatsko popunjavanje datuma vraćanja na dokumetima okvira", "C", 1)+ gcE
					lcXML = lcXML + GF_CreateNode("sys_ts", _dokumenti_za_promjenu.cast_sys_ts, "C", 1)+ gcE
					lcXML = lcXML + GF_CreateNode("id_dokum", _dokumenti_za_promjenu.id_dokum, "N", 1)+ gcE
					lcXML = lcXML + '</common_parameters>'+ gcE
					lcXML = lcXML + GF_CreateNode("is_update", .T., "L", 1)+ gcE	
					lcXML = lcXML + '<updated_values>'+ gcE
					lcXML = lcXML + GF_CreateNode("table_name", "DOKUMENT", "C", 1)+ gcE
					lcXML = lcXML + GF_CreateNode("name", "VRNJEN", "C", 1)+ gcE
					lcXML = lcXML + GF_CreateNode("updated_value", _dokumenti_za_promjenu.vrnjen_new, "D", 1)+ gcE
					lcXML = lcXML + '</updated_values>'+ gcE
					lcXML = lcXML + '<updated_values>'+ gcE
					lcXML = lcXML + GF_CreateNode("table_name", "DOKUMENT", "C", 1)+ gcE
					lcXML = lcXML + GF_CreateNode("name", "POPRAVIL", "C", 1)+ gcE
					lcXML = lcXML + GF_CreateNode("updated_value", _dokumenti_za_promjenu.popravil, "C", 1)+ gcE
					lcXML = lcXML + '</updated_values>'+ gcE
					lcXML = lcXML + '<updated_values>'+ gcE
					lcXML = lcXML + GF_CreateNode("table_name", "DOKUMENT", "C", 1)+ gcE
					lcXML = lcXML + GF_CreateNode("name", "dat_poprave", "C", 1)+ gcE
					lcXML = lcXML + GF_CreateNode("updated_value", datetime(), "D", 1)+ gcE
					lcXML = lcXML + '</updated_values>'+ gcE
					lcXML = lcXML + '</rpg_documentation_update_delete>'

					WAIT WIND "Pripremam podatke (br. dok.: "+allt(trans(_dokumenti_za_promjenu.id_dokum))+")" NOWAIT
					IF !GF_ProcessXml(lcXml) THEN
						*19.06.2020 g_tomislav MID 44927 - u slučaju greške se promjena napravila na krovnom dok po dokumentima ugovora ZO nije. Dodana obavijest korisniku oko broja promjena i zaustavljen nastavak spremanja
						pozor("Greška u izvođenju promjene ZO dokumenata za ugovor "+allt(GF_LOOKUP("pogodba.id_pog", _dokumenti_za_promjenu.id_cont, "pogodba.id_cont"))+" br. dok.: "+allt(trans(_dokumenti_za_promjenu.id_dokum))+"!")
						lnErrorCount = lnErrorCount + 1
						lcUgovoriUGresci = lcUgovoriUGresci + allt(GF_LOOKUP("pogodba.id_pog", _dokumenti_za_promjenu.id_cont, "pogodba.id_cont"))+" br. dok.: "+allt(trans(_dokumenti_za_promjenu.id_dokum)) +gce
					ELSE 
						lnUspjesno = lnUspjesno + 1
					ENDIF
				endscan
				
				lcPoruka = "Rezultat promjena na ZO dokumentima"+gce ;
							+"ukupno za promjenu: "+allt(trans(lnUkupno))+gce ;
							+"uspješno promijenjeno: "+allt(trans(lnUspjesno))+gce ;
							+"greške: "+allt(trans(lnErrorCount)) ;
				
				IF lnErrorCount > 0
					Pozor(lcPoruka +gce +"Greška u izvođenju je bila kod ugovora " +gce +lcUgovoriUGresci +gce +"Molimo da kliknete na gumb za spremanje kako bi se izvođenje ponovilo za ugovore u grešci!" +gce +"Spremanje dokumenta je zaustavljeno!")
					RETURN .F.
				ELSE
					obvesti(lcPoruka)
				ENDIF
			ENDIF
			
			use in _okvir_ugovor
			use in _okvir_krovni_dokument
		ENDIF 
	ENDIF 
	use in _dokumenti_za_promjenu
ENDIF 

**RLHR ticket 1536 
IF dokument.id_obl_zav == 'KL' AND !GF_NULLOREMPTY(dokument.vrnjen) THEN
	TEXT TO lcSQL NOSHOW
		Select DATEADD(dd, CAST(val_num as INT), {0})
		From dbo.GENERAL_REGISTER
		Where ID_REGISTER = 'RLC Reporting list' AND id_key = 'RLC_KO_DNI_ODMIK'
	ENDTEXT

	lcSQL = STRTRAN(lcSQL, "{0}", GF_QUOTEDSTR(DTOS(dokument.vrnjen)))
	ldDostave = GF_SQLExecScalarNull(lcSQL)

	IF ldDostave != loForm.txtdatum.Value AND POTRJENO("Datum vraćanja dokumenta "+IIF(GF_NULLOREMPTY(dokument.vrnjen), "je prazan", DTOC(dokument.vrnjen))+CHR(10)+"Želite li promjeniti do kojega datuma mora dostaviti na "+DTOC(ldDostave)+IIF(GF_NULLOREMPTY(dokument.datum),"?", " (trenutno upisan datum "+DTOC(dokument.datum)+")?")) THEN
			loForm.txtdatum.Value = ldDostave
	ENDIF
ENDIF
***************************************************