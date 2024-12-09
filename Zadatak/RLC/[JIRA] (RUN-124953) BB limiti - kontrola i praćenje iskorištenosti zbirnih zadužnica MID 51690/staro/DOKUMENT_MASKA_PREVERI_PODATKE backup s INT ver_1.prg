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
*!* 10.07.2020 g_tomislav MID 44927 - u slučaju greške kod izvođenja GF_ProcessXml se promjena napravila na dokumentu (bio je samo RETURN bez .F.) dok po dokumentima ugovora ZO nije. Dodana obavijest korisniku oko broja promjena i upit oko nastavaka spremanja. Podešeno da se poruka prikazuje samo kad se radi promjena tj. pokreće GF_ProcessXml. U slučaju okvira koji imaju krovnu dokumentaciju, izmjena se sada pokreće samo u slučaju popravka krovnog dokumenta vezanog na okvir (do sada se pokretala kod svih vrsta dokumenta, između ostalih uvjeta)
** 02.10.2020 g_dejank, MR 44945, general_register.value je cast-an kao text zbog novog ODBC driver-a
** 12.07.2023 g_tomislav MID 50889 - ZO dokument okvira se sada nalazi u posebnom šifrantu RLC_DOKUMENTI_OKVIRA te je kreiran #dokumenti_okvira. Kod brisanja datuma vrnjen sada se također pokreće funkcionalnost  

LOCAL lnId_dokum, lnId_cont, lnId_frame, lcId_obl_zav, ldVrnjen, ldVrnjen_baza, lcOpomba
LOCAL lcXML, lcE

ldVrnjen = dokument.vrnjen
ldVrnjen01011901 = IIF(GF_NULLOREMPTY(ldVrnjen), {01.01.1901}, ldVrnjen)

*opcija radi samo kada izmjenjeni podatak vrnjen nije null => to je promijenjeno u MID 50889
*IF !GF_NULLOREMPTY(ldVrnjen) THEN
	*provjera da li je na masci trenutnog dokumenta mijenjan podatak dokument.vrnjen 
	lnId_dokum = dokument.id_dokum
	ldVrnjen_baza = gf_lookup("dokument.vrnjen", lnId_dokum, "dokument.id_dokum")
	* cursor iz kojeeg će se raditi izmjene
	create cursor _dokumenti_za_promjenu ;
	( ;
    id_cont number(10,0) NOT NULL, cast_sys_ts character(19) NOT NULL, id_dokum number(10,0) NOT NULL, vrnjen_new datetime NOT NULL, popravil character(10) NOT NULL ;
	)
	* da li je došlo do promjene podatka vrnjen (datum vraćanja)
	IF ldVrnjen01011901 != NVL(ldVrnjen_baza, {01.01.1901}) THEN 
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
					SET @lista = (Select cast(value as [text]) as value from dbo.GENERAL_REGISTER Where ID_REGISTER = 'RLC Reporting list' and id_key = 'RLC_KROV_INST_OSIG' and neaktiven = 0) 
		
					SELECT * FROM dbo.dokument WHERE id_frame = {0} AND id_obl_zav IN (SELECT id FROM dbo.gfn_GetTableFromList(@lista))
				ENDTEXT
	
			lcSQL40834 = STRTRAN(lcSQL40834, "{0}", trans(lnId_frame))
			GF_SQLEXEC(lcSQL40834, "_okvir_krovni_dokument")		
			
			lcRLC_Dokumenti_okvira = NVL(GF_SQLExecScalarNull("Select cast(value as [text]) as value from dbo.GENERAL_REGISTER Where ID_REGISTER = 'RLC Reporting list' and id_key = 'RLC_DOKUMENTI_OKVIRA' and neaktiven = 0"), "ZO")
			
			*provjera da li okvir ima unešenu krovnu dokumentaciju jer to određuje način ažuriranja
			IF RECCOUNT("_okvir_krovni_dokument") = 0 THEN 				
				*stari okviri koji nemaju krovnu dokumentaciju
				*IF lcId_obl_zav = "ZO" THEN
				IF ATC(lcId_obl_zav, lcRLC_Dokumenti_okvira) > 0 THEN
					*promjena se radi samo na dokumentima vrste RLC_DOKUMENTI_OKVIRA (ZO) koji nemaju unešen datum vraćanja i koji su vezani za zaključene ugovor => sada se promjena radi na svim dokumentima koji imaju uneseni datum MID 50889
					*MID 33028 dokumenti koji već imaju unešen datum vraćanja se ne uzimaju u obzir
					TEXT TO lcSql NOSHOW 
						select id 
						into #dokumenti_okvira 
						from dbo.gfn_GetTableFromList({3})
					
						SELECT fp.id_frame, d.*, CAST(d.sys_ts as bigint) as cast_sys_ts
						FROM dbo.frame_pogodba fp 
						INNER JOIN dbo.pogodba p ON fp.id_cont = p.id_cont
						INNER JOIN dbo.dokument d ON fp.id_cont = d.id_cont 
						WHERE fp.id_frame = {0}
						--AND d.id_obl_zav = 'ZO'
						and exists (select * from #dokumenti_okvira where id = d.id_obl_zav)
						AND d.id_dokum <> {2}
						--AND d.vrnjen IS NULL
						AND ({4} != '19010101' and d.vrnjen IS NULL -- kada je promijenjen vrnjen (nije obrisan/null), radi kao i do sada 
								or {4} = '19010101' and d.vrnjen = {5}) -- kada je obrisan vrnjen, kandidati su dokumenti koji su imali is
						AND p.status_akt = 'Z'
						
						drop table #dokumenti_okvira
					ENDTEXT 
					lcSql = STRTRAN(lcSql,'{0}', GF_QuotedStr(lnId_frame))
					lcSql = STRTRAN(lcSql,'{2}', GF_QuotedStr(lnId_dokum))
					lcSql = STRTRAN(lcSql,'{3}', GF_QuotedStr(lcRLC_Dokumenti_okvira))
					lcSql = STRTRAN(lcSql,'{4}', GF_QuotedStr(DTOS(ldVrnjen01011901)))
					lcSql = STRTRAN(lcSql,'{5}', GF_QuotedStr(DTOS(NVL(ldVrnjen_baza, {01.01.1901}))))
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
				* novi okviri s krovnim dokumentom, samo kod popravaka krovnog dokumenta MR 44927
				IF ! GF_NULLOREMPTY(dokument.id_frame) 
					*okviri koji imaju krovnu dokumentaciju
					*da li je popunjen datum vraćanja na zadnjem krovnom dokumentu ili ako su svi krovni dokumenti popunjeni ali se mjenja unešeni podatak
					select * from _okvir_krovni_dokument where !GF_NULLOREMPTY(vrnjen) into cursor _okvir_krovni_dokument_sa_popunjenim_vrnjen
					IF RECCOUNT("_okvir_krovni_dokument") - iif(GF_NULLOREMPTY(ldVrnjen_baza), 1, 0) == RECCOUNT("_okvir_krovni_dokument_sa_popunjenim_vrnjen") THEN  && izbačen ovaj uvjet jer isti postoji na početku  and ldVrnjen != NVL(ldVrnjen_baza, {01.01.1901})
						*trebamo sve dokumente vrste RLC_DOKUMENTI_OKVIRA (ZO) sa ugovora (na krovnim dokumentima je već popunjen taj podatak) koji su vezani za zaključene ugovore koji su vezani za okvir
						*MID 33028 dokumenti koji već imaju unešen datum vraćanja se ne uzimaju u obzir
						TEXT TO lcSql NOSHOW 
							select id 
							into #dokumenti_okvira 
							from dbo.gfn_GetTableFromList({3})
							
							SELECT fp.id_frame, d.*, CAST(d.sys_ts as bigint) as cast_sys_ts
							FROM dbo.frame_pogodba fp 
							INNER JOIN dbo.pogodba p ON fp.id_cont = p.id_cont
							INNER JOIN dbo.dokument d ON fp.id_cont = d.id_cont 
							WHERE fp.id_frame = {0}
							--AND d.id_obl_zav = 'ZO'
							and exists (select * from #dokumenti_okvira where id = d.id_obl_zav)
							AND d.id_dokum <> {2}
							AND d.id_frame IS NULL
							--AND d.vrnjen IS NULL
							AND ({4} != '19010101' and d.vrnjen IS NULL -- kada je promijenjen vrnjen (nije obrisan/null), radi kao i do sada 
									or {4} = '19010101' and d.vrnjen = {5}) -- kada je obrisan vrnjen, kandidati su dokumenti koji su imali isti vrnjen
							AND p.status_akt = 'Z'
							
							drop table #dokumenti_okvira
						ENDTEXT 
						lcSql = STRTRAN(lcSql,'{0}', GF_QuotedStr(lnId_frame))
						lcSql = STRTRAN(lcSql,'{2}', GF_QuotedStr(lnId_dokum))
						lcSql = STRTRAN(lcSql,'{3}', GF_QuotedStr(lcRLC_Dokumenti_okvira))
						lcSql = STRTRAN(lcSql,'{4}', GF_QuotedStr(DTOS(ldVrnjen01011901)))
						lcSql = STRTRAN(lcSql,'{5}', GF_QuotedStr(DTOS(NVL(ldVrnjen_baza, {01.01.1901}))))
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
					IF !GF_NULLOREMPTY(ldVrnjen)				 
						lcXML = lcXML + GF_CreateNode("updated_value", _dokumenti_za_promjenu.vrnjen_new, "D", 1)+ gcE  && kao i do sada
					ELSE
						lcXML = lcXML + GF_CreateNode("is_null", "true", "C", 1)
					ENDIF
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
						pozor("Greška u izvođenju promjene RLC_DOKUMENTI_OKVIRA dokumenata za ugovor "+allt(GF_LOOKUP("pogodba.id_pog", _dokumenti_za_promjenu.id_cont, "pogodba.id_cont"))+" br. dok.: "+allt(trans(_dokumenti_za_promjenu.id_dokum))+"!")
						lnErrorCount = lnErrorCount + 1
						lcUgovoriUGresci = lcUgovoriUGresci + allt(GF_LOOKUP("pogodba.id_pog", _dokumenti_za_promjenu.id_cont, "pogodba.id_cont"))+" br. dok.: "+allt(trans(_dokumenti_za_promjenu.id_dokum)) +gce
					ELSE 
						lnUspjesno = lnUspjesno + 1
					ENDIF
				endscan
				
				lcPoruka = "Rezultat promjena na RLC_DOKUMENTI_OKVIRA dokumentima"+gce ;
							+"ukupno za promjenu: "+allt(trans(lnUkupno))+gce ;
							+"uspješno promijenjeno: "+allt(trans(lnUspjesno))+gce ;
							+"greške: "+allt(trans(lnErrorCount)) ;
				
				IF lnErrorCount > 0
					IF !POTRJENO (lcPoruka +gce +"Greška u izvođenju je bila kod ugovora " +gce +lcUgovoriUGresci +gce +"Da li želite nastaviti sa spremanjem ovog dokumenta (ako želite ponoviti izvođenje za ugovore u grešci odaberite NE te ponovno kliknite na 'Snimi')!")
						RETURN .F.
					ENDIF
				ELSE
					obvesti(lcPoruka)
				ENDIF
			ENDIF
			
			use in _okvir_ugovor
			use in _okvir_krovni_dokument
		ENDIF 
	ENDIF 
	use in _dokumenti_za_promjenu
*ENDIF 

***************************************************
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
**g_andrijap 22.11.2022. 49867 obavezan unos datuma vraćanja
IF dokument.id_obl_zav == '5R' AND GF_NULLOREMPTY(dokument.vrnjen) THEN
	pozor("Obavezno polje datum vraćanja dokumenta je prazano. Molim vas popunite kako bi spremili dokument!")
	RETURN .F.
ENDIF
***************************************************


**g_igorp 04.05.2023. MR 50719 zabrana unosa AK dokumenta za FO kod financijskog leasinga
**g_andrijap 08.05.2023. MR50288 dorada zbog dokumentacije na okvirima, dodan IF provjere id_conta
IF!(GF_NULLOREMPTY(dokument.id_cont))

lcIdKupca = GF_SQLEXECSCALARNULL("SELECT id_kupca FROM dbo.pogodba WHERE id_cont ="+ALLT(STR(dokument.id_cont)))
lcVrOsebe = GF_SQLEXECSCALARNULL("SELECT dbo.gfn_GetVrOsebeSIFRA("+GF_QUOTEDSTR(lcIdKupca)+")")
lcTipLeas = GF_SQLEXECSCALARNULL("SELECT dbo.gfn_Nacin_leas_HR(nacin_leas) FROM dbo.pogodba where id_cont = "+ALLT(STR(dokument.id_cont)))

IF dokument.id_obl_zav == 'AK' AND (ALLT(lcTipLeas) == "F1" OR ALLT(lcTipLeas) == "FF") AND ALLT(lcVrOsebe) == "FO"
	POZOR("Kod financijskog leasinga gdje je primatelj leasinga fizička osoba nije moguće ručno unijeti dokument AK")
	RETURN .F.
ENDIF
ENDIF

* insert => treba zbrojiti vrednost , update => ne treba zbrojiti vrednost 
* mogu se dodati ostale kontrole da se Vrednost gleda samo za ZE, da dokument mora biti na ugovor id_cont is not null), za ZT Vrednost nije 0,   i sl.
* kod unosa je id_dokum null



***************************************************
** 25.01.2024. g_tomislav MID 51690 - check if sum of ZE documents exceeds value of ZT frame document 

LOCAL lnId_krov_dok, lnId_dokum51690

lnId_krov_dok = document.id_krov_dok

IF document.id_obl_zav == "ZE" and !GF_NULLOREMPTY(lnId_krov_dok)  && if not entered, then it is null
	
	GF_SQLEXEC("select vrednost as ZT_vrijednost, id_tec as ZT_id_tec from dbo.document where id_dokum = "+ALLT(STR(lnId_krov_dok)), "_ef_krov_dok")
	lnZT_Vrijednost = _ef_krov_dok.ZT_vrijednost
	lnZT_id_tec = _ef_krov_dok.ZT_id_tec
	lnId_dokum51690 = NVL(dokument.id_dokum, 0)

	TEXT TO lcSql NOSHOW
		declare @today datetime = dbo.gfn_GetDatePart(getdate())
		declare @id_krov_dok int = {0}
		declare @id_dokum int = {1}

		select ze.id_dokum
			, pog.id_pog as Ugovor
			, ze_x_vrednost.znesek as ZE_Vrijednost
			--, zt.vrednost as ZT_vrijednost 
		from dbo.dokument ze
		inner join dbo.pogodba pog on ze.id_cont = pog.id_cont
		inner join dbo.dokument zt on ze.id_krov_dok = zt.id_dokum 
		outer apply dbo.gfn_xchange_table(zt.id_tec, ze.vrednost, ze.id_tec, @today) ze_x_vrednost
		where ze.id_krov_dok = @id_krov_dok 
		and ze.id_dokum != @id_dokum  --exclude this document
	ENDTEXT 

	lcSql = STRTRAN(lcSql, "{0}", ALLT(STR(lnId_krov_dok))) 
	lcSql = STRTRAN(lcSql, "{1}", ALLT(STR(lnId_dokum51690))) 
	GF_SQLEXEC(lcSql, "_ef_dokumenti_ZE")
	
	SELECT _ef_dokumenti_ZE
	CALCULATE SUM(ZE_Vrijednost) TO lnZE_VrijednostFromCursor
	
	lnVrednost = GF_XCHANGE(lnZT_id_tec, dokument.vrednost, dokument.id_tec, DATE())
	
	lnZE_Vrijednost = lnZE_VrijednostFromCursor + lnVrednost
	
	IF lnZE_Vrijednost > lnZT_Vrijednost
		
		IF !POTRJENO("Iznos krovnog dokumenta " + ALLT(TRANS(lnZT_Vrijednost, gccif)) +" je prekoračen. Suma svih povezanih dokumenata iznosi " +ALLT(TRANS(lnZE_Vrijednost)) +"." +gce ;
			"Da li želite nastaviti sa spremanjem?")
			RETURN .F.
		ENDIF
	ENDIF
ENDIF
** KRAJ MID 51690***********************************