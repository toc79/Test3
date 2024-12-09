*!* 24.09.2015 Omar; MID 31711 - izrada
*!* 15.10.2015 Omar; MID 33028 - dorada
*!* 27.10.2015 Omar; MID 33028 - dorada

LOCAL loForm
LOCAL lnId_dokum, lnId_cont, lnId_frame, lcId_obl_zav, ldVrnjen, ldVrnjen_baza, lcOpomba
LOCAL lcXML, lcE

loForm = GF_GetFormObject("frmdokument_maska")
IF ISNULL(loForm) THEN 
	RETURN
ENDIF

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
			GF_SqlExec("SELECT * FROM dbo.dokument WHERE id_frame = " + GF_QuotedStr(lnId_frame), "_okvir_krovni_dokument")
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
			sele _dokumenti_za_promjenu
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

				WAIT WIND 'Pripremam podatke' NOWAIT
				IF !GF_ProcessXml(lcXml) THEN
					obvesti("Greška u izvođenju!")
					RETURN
				ENDIF
			endscan
			use in _okvir_ugovor
			use in _okvir_krovni_dokument
		ENDIF
	ENDIF
	use in _dokumenti_za_promjenu
ENDIF