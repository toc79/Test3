loForm = GF_GetFormObject("frmKategorije_entiteta_maska") 
IF ISNULL(loForm) THEN 
	RETURN
ENDIF

**--------------------------------------------
** Created g_vuradin MID ??? ** 23.12.2021 g_vuradin MID 47957 - Created
** 31.12.2021 g_tomislav MID 48051 i 48057 - bugfix, code optimization and support for dynamic Block_kategorije

IF loForm.txtEntiteta.Value = "PONUDBA"
	
	select * from kategorije where sifra = 'VRSTA_PLACANJA' into cursor _ef_kategorije_vrste_placanja	

	IF !GF_NULLOREMPTY(_ef_kategorije_vrste_placanja.id_kategorije_tip) && for active entity
		
		TEXT TO lcSQL01 NOSHOW
			select ks.id_kategorije_sifrant, ks.id_kategorije_tip, ks.vrednost, ks.neaktiven
			from dbo.kategorije_sifrant ks
			where ks.id_kategorije_tip = 
		ENDTEXT 
		GF_SQLEXEC(lcSQL01 +trans(_ef_kategorije_vrste_placanja.id_kategorije_tip), "_ef_vrsta_placanja")
		
		lcId_Pon = loform.txtId_entitete.Value
		
		IF GF_LOOKUP("ponudba.je_nk", lcId_Pon, "ponudba.id_pon")
			select vrednost from _ef_vrsta_placanja where vrednost != 'STANDARDNE RATE' and !neaktiven into cursor _ef_vrsta_placanja_nest
			LcList_condition = ""	
			POZOR('Vrsta plaćanja za nestandardnu kalkulaciju mora biti '+ GF_CreateDelimitedList("_ef_vrsta_placanja_nest", "vrednost", LcList_condition, ",")+'!' )
		ELSE 
			select id_kategorije_sifrant from _ef_vrsta_placanja where vrednost = 'STANDARDNE RATE' and !neaktiven into cursor _ef_vrsta_placanja_stand
			lcPostavljanje = "loForm.Block_kategorije." +allt(_ef_kategorije_vrste_placanja.obj_name) +".Value = "+trans(_ef_vrsta_placanja_stand.id_kategorije_sifrant)
			&lcPostavljanje
		ENDIF
	ENDIF
ENDIF 
** End VRSTA_PLACANJA 
**--------------------------------------------

**--------------------------------------------
** 27.09.2022 g_tomislav MID 49268 - seting mandatory fields for ESG

IF loForm.txtEntiteta.Value = "POGODBA"
	
	lcId_cont = loForm.txtId_entitete.Value
	lcPogodba_datum_odob = GF_LOOKUP("pogodba.datum_odob", lcId_cont, "pogodba.id_cont")
	
	IF lcPogodba_datum_odob < {01.07.2022}
	
		select * from kategorije where sifra = 'ESG_R' or sifra = 'ESG_M' into cursor _ef_kategorije_ESG  && kategorije contains only active categories
		
		IF reccount("_ef_kategorije_ESG") > 0
			SELE _ef_kategorije_ESG
			GO TOP
			SCAN 
				lcOnemogucavanje = "loForm.Block_kategorije." +allt(_ef_kategorije_ESG.obj_name) +".Obvezen = .F."
				&lcOnemogucavanje
			ENDSCAN
		ENDIF
	ENDIF
ENDIF
** End ESG
**--------------------------------------------