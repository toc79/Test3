
* Provjerava se po broju krovnog dokumenta 
* insert => treba zbrojiti vrednost , update => ne treba zbrojiti vrednost 
* mogu se dodati ostale kontrole da se Vrednost gleda samo za ZE, da dokument mora biti na ugovor id_cont is not null), za ZT Vrednost nije 0,   i sl.
* kod unosa je id_dokum null



***************************************************
** 25.01.2024. g_tomislav MID 51690 - check if sum of ZE documents exceeds value of frame document ZT

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
		left join dbo.dokument ze on ze.id_krov_dok = zt.id_dokum and ze.id_dokum != @id_dokum --exclude this document
		outer apply dbo.gfn_xchange_table(zt.id_tec, ze.vrednost, ze.id_tec, @today) ze_x_vrednost
		left join dbo.pogodba pog on ze.id_cont = pog.id_cont
		where zt.id_dokum = @id_krov_dok
	ENDTEXT 

	lcSql = STRTRAN(lcSql, "{0}", ALLT(STR(lnId_krov_dok))) 
	lcSql = STRTRAN(lcSql, "{1}", ALLT(STR(lnId_dokum51690))) 
	GF_SQLEXEC(lcSql, "_ef_dokument_ZE_ZT")
	
	lnZT_Vrednost = _ef_dokument_ZE_ZT.ZT_vrednost
	lnZT_id_tec = _ef_dokument_ZE_ZT.ZT_id_tec
	
	SELECT _ef_dokument_ZE_ZT
	CALCULATE SUM(ZE_vrednost) TO lnZE_VrednostSum
	
	lnVrednost = GF_XCHANGE(lnZT_id_tec, dokument.vrednost, dokument.id_tec, DATE())
	
	lnZE_Vrednost = lnZE_VrednostSum + lnVrednost
	
	IF lnZE_Vrednost > lnZT_Vrednost
		* radi testiranja
		select * from _ef_dokument_ZE_ZT  
		_VFP.DATATOCLIP(,,3)
		
		IF !POTRJENO("Iznos krovnog dokumenta " + ALLT(TRANS(lnZT_Vrednost, gccif)) +" je prekoračen. Suma svih povezanih dokumenata iznosi " +ALLT(TRANS(lnZE_Vrednost, gccif)) +"." +gce ;
			+"Da li želite nastaviti sa spremanjem?")
			RETURN .F.
		ENDIF
	ENDIF
ENDIF
** KRAJ MID 51690***********************************