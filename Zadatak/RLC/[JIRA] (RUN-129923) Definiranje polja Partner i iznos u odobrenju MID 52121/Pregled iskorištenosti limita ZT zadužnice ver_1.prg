** 09.10.2024 g_tomislav MID 52121 

SELECT * FROM dokument_krovni WHERE id_obl_zav == "ZT" AND GF_NULLOREMPTY(id_cont) INTO CURSOR _dr_ZT_KrovniDokumenti

IF RECCOUNT("_dr_ZT_KrovniDokumenti") == 0
	POZOR("Na pregledu nema ZT krovnih dokumenta!")
	RETURN .F.
ENDIF 

LcList_condition = ""  && Mora biti 
lcListId_krov_dok = GF_CreateDelimitedList("_dr_ZT_KrovniDokumenti", "id_dokum", LcList_condition, ",", .F.) &&BEZ NAVODNIKA

TEXT TO lcSql NOSHOW
	declare @today datetime = convert(date, getdate())
	declare @listaId_krov_dok varchar(max) = {0}

	select id_dokum, id_kupca, ZT_vrednost, sum_ZE_vrednost, ZT_vrednost - sum_ZE_vrednost as razlika_ZT_ZE, ZT_id_val
	from 
		(	select zt.id_dokum, zt.id_kupca, zt.vrednost as ZT_vrednost, zt.id_tec as ZT_id_tec, t.id_val as ZT_id_val
				, sum(isnull(ze_x_vrednost.znesek, 0)) as sum_ZE_vrednost
			from dbo.dokument zt
				inner join dbo.gfn_split_ids(@listaId_krov_dok, ',') si on zt.id_dokum = si.id
				left join dbo.dokument ze on ze.id_krov_dok = zt.id_dokum and ze.id_obl_zav = 'ZE'
				outer apply dbo.gfn_xchange_table(zt.id_tec, ze.vrednost, ze.id_tec, @today) ze_x_vrednost
				left join dbo.tecajnic t on zt.id_tec = t.id_tec
			group by zt.id_dokum, zt.id_kupca, zt.vrednost, zt.id_tec, t.id_val
		) a
ENDTEXT 

lcSql = STRTRAN(lcSql, "{0}", GF_QUOTEDSTR(lcListId_krov_dok)) 
GF_SQLEXEC(lcSql, "_ef_dokument_ZE_ZT")

GF_DataPreview("_ef_dokument_ZE_ZT", "", "frmDodatna_rutina_52121", "Pregled iskorištenosti limita ZT zadužnice")




LOCAL lnId_krov_dok, lnId_dokum51690

lnId_krov_dok = dokument.id_krov_dok

IF !GF_NULLOREMPTY(lnId_krov_dok) AND dokument.id_obl_zav == "ZE"  && if not entered, then it is null

	lnId_dokum51690 = NVL(dokument.id_dokum, 0)

	
	
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