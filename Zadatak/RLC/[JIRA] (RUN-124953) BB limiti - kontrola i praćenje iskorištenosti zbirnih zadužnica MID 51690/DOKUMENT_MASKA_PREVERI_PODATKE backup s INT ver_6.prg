
* Provjerava se po broju krovnog dokumenta i za ZT krovni i ZE vezani
* insert => treba zbrojiti vrednost , update => ne treba zbrojiti vrednost 
* mogu se dodati ostale kontrole da se Vrednost gleda samo za ZE, da dokument mora biti na ugovor id_cont is not null), za ZT Vrednost nije 0,   i sl.
* kod unosa je id_dokum null



***************************************************
** 19.08.2024. g_tomislav MID 51690 - check if sum of ZE documents exceeds value of frame document ZT

LOCAL lnId_krov_dok, lnId_dokum51690

lnId_krov_dok = dokument.id_krov_dok

IF !GF_NULLOREMPTY(lnId_krov_dok) AND dokument.id_obl_zav == "ZE"  && if not entered, then it is null

	lnId_dokum51690 = NVL(dokument.id_dokum, 0)

	TEXT TO lcSql NOSHOW
		declare @today datetime = dbo.gfn_GetDatePart(getdate())
		declare @id_krov_dok int = {0}
		declare @id_dokum int = {1}

		select zt.vrednost as ZT_vrednost
			, zt.id_tec as ZT_id_tec
			, ze.id_dokum
			, pog.id_pog 
			, isnull(ze_x_vrednost.znesek, 0) as ZE_vrednost
		from dbo.dokument zt
		left join dbo.dokument ze on ze.id_krov_dok = zt.id_dokum and ze.id_obl_zav = 'ZE' and ze.id_dokum != @id_dokum --exclude this document
		outer apply dbo.gfn_xchange_table(zt.id_tec, ze.vrednost, ze.id_tec, @today) ze_x_vrednost
		left join dbo.pogodba pog on ze.id_cont = pog.id_cont
		where zt.id_obl_zav = 'ZT'		
		and zt.id_dokum = @id_krov_dok
	ENDTEXT 

	lcSql = STRTRAN(lcSql, "{0}", ALLT(STR(lnId_krov_dok))) 
	lcSql = STRTRAN(lcSql, "{1}", ALLT(STR(lnId_dokum51690))) 
	GF_SQLEXEC(lcSql, "_ef_dokument_ZE_ZT")
	
	lnZT_Vrednost = NVL(_ef_dokument_ZE_ZT.ZT_vrednost, 0)
	lnZT_id_tec = NVL(_ef_dokument_ZE_ZT.ZT_id_tec, "000")
	
	SELECT _ef_dokument_ZE_ZT
	CALCULATE SUM(NVL(ZE_vrednost, 0)) TO lnZE_VrednostSum
	
	lnVrednost = GF_XCHANGE(lnZT_id_tec, dokument.vrednost, dokument.id_tec, DATE())
	
	lnZE_VrednostUkupno = lnZE_VrednostSum + lnVrednost

	*IF RECCOUNT("_ef_dokument_ZE_ZT") > 0 THEN &&* shows data used in calculation only if there is another ZE document
	lcId_pog = TRIM(GF_LOOKUP("pogodba.id_pog", dokument.id_cont, "pogodba.id_cont")) 
	SELECT ZT_vrednost AS ZT_Vrijednost, ZT_id_tec, id_dokum AS ZE_Br_dok, id_pog AS ZE_Ugovor, ZE_vrednost AS ZE_Vrijednost FROM _ef_dokument_ZE_ZT WHERE !GF_NULLOREMPTY(id_dokum) ;
	UNION ALL ;
	SELECT ZT_vrednost AS ZT_Vrijednost, ZT_id_tec, lnId_dokum51690 AS ZE_Br_dok, lcId_pog AS ZE_Ugovor, lnVrednost AS ZE_Vrijednost FROM _ef_dokument_ZE_ZT WHERE RECNO() = 1;
	UNION ALL ;
	SELECT ZT_vrednost AS ZT_Vrijednost, ZT_id_tec, 0 AS ZE_Br_dok, 'Suma' AS ZE_Ugovor, lnZE_VrednostUkupno AS ZE_Vrijednost FROM _ef_dokument_ZE_ZT WHERE RECNO() = 1
	_VFP.DATATOCLIP(,,3)
	*ENDIF
	
	IF lnZE_VrednostUkupno > lnZT_Vrednost
		POZOR("Iznos krovnog dokumenta " + ALLT(TRANS(lnZT_Vrednost, gccif)) +" je prekoračen. Suma svih povezanih dokumenata iznosi " +ALLT(TRANS(lnZE_VrednostUkupno, gccif)) +"." +gce ;
			+"Zapis se ne može spremiti!")
		RETURN .F.
	ENDIF
ENDIF
** KRAJ MID 51690***********************************