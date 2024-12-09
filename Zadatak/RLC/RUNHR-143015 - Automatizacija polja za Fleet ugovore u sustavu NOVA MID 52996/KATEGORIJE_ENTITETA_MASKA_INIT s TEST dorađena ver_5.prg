****************
* 22.08.2024 g_tomislav MID 52996 - created 
****************
IF loForm.txtEntiteta.Value == "POGODBA" THEN
	
	lcMessage = ""
	
	* TKU Tip kalkulacije: Otvorena or Zatvorena
	select * from kategorije where sifra = 'TKU' into cursor _ef_kategorije_TKU  

	IF !GF_NULLOREMPTY(_ef_kategorije_TKU.id_kategorije_tip) AND GF_NULLOREMPTY(_ef_kategorije_TKU.id_kategorije_sifrant) && for active entity only when it is empty 
		
		lcId_cont = loForm.txtId_entitete.Value
		lcIdPosrednik = ALLT(NVL(GF_SQLEXECScalarNull("select id_posrednik from dbo.pogodba where id_cont = "+GF_Quotedstr(lcId_cont )), ""))
		
		IF lcIdPosrednik == "FLT" 
			
			TEXT TO lcSQL01 NOSHOW
				select ks.id_kategorije_sifrant, ks.id_kategorije_tip, ks.vrednost, ks.neaktiven
				from dbo.kategorije_sifrant ks
				where ks.neaktiven = 0
				and ks.vrednost = 'Zatvorena'
				and ks.id_kategorije_tip = 
			ENDTEXT 
			lcId_kategorije_tip = NVL(_ef_kategorije_TKU.id_kategorije_tip_p, _ef_kategorije_TKU.id_kategorije_tip)  && If a category is connected with ponudba, then list of values from registry is from id_kategorije_tip_p, and not from id_kategorije_tip. Ako se kategorija preuzima iz ponude, onda je i lista šifranta iz ponude id_kategorije_tip_p, a ne iz id_kategorije_tip
			GF_SQLEXEC(lcSQL01 +trans(lcId_kategorije_tip), "_ef_sifrant_TKU_zatvorena")
			
			IF RECCOUNT("_ef_sifrant_TKU_zatvorena") == 0
				POZOR("Šifrant TKU Tip kalkulacije nema definiran šifrant s vrijednošću 'Zatvorena' pa se vrijednost ne može postaviti!")
			ELSE
				lcPostavljanje = "loForm.Block_kategorije." +allt(_ef_kategorije_TKU.obj_name) +".Value = "+trans(_ef_sifrant_TKU_zatvorena.id_kategorije_sifrant)
				&lcPostavljanje
				
				lcPosrednikNaziv = ALLT(NVL(GF_SQLEXECScalarNull("select dbo.gfn_StringToFox(value) from dbo.general_register where id_register = 'P_POSREDNIK' and id_key = '" +lcIdPosrednik +"'"), ""))
				lcMessage = lcMessage +"Za TKU Tip kalkulacije se automatski postavila vrijednost 'Zatvorena' jer ugovor ima unesenog Posrednika = " +lcIdPosrednik +" " +lcPosrednikNaziv +"." +gce
			ENDIF
		ENDIF
		
		IF lcIdPosrednik == "DOBF" 
			
			TEXT TO lcSQL01 NOSHOW
				select ks.id_kategorije_sifrant, ks.id_kategorije_tip, ks.vrednost, ks.neaktiven
				from dbo.kategorije_sifrant ks
				where ks.neaktiven = 0
				and ks.vrednost = 'Otvorena'
				and ks.id_kategorije_tip = 
			ENDTEXT 
			lcId_kategorije_tip = NVL(_ef_kategorije_TKU.id_kategorije_tip_p, _ef_kategorije_TKU.id_kategorije_tip)  && If a category is connected with ponudba, then list of values from registry is from id_kategorije_tip_p, and not from id_kategorije_tip. Ako se kategorija preuzima iz ponude, onda je i lista šifranta iz ponude id_kategorije_tip_p, a ne iz id_kategorije_tip
			GF_SQLEXEC(lcSQL01 +trans(lcId_kategorije_tip), "_ef_sifrant_TKU_Otvorena")
			
			IF RECCOUNT("_ef_sifrant_TKU_Otvorena") == 0
				POZOR("Šifrant TKU Tip kalkulacije nema definiran šifrant s vrijednošću 'Otvorena' pa se vrijednost ne može postaviti!")
			ELSE
				lcPostavljanje = "loForm.Block_kategorije." +allt(_ef_kategorije_TKU.obj_name) +".Value = "+trans(_ef_sifrant_TKU_Otvorena.id_kategorije_sifrant)
				&lcPostavljanje
				
				lcPosrednikNaziv = ALLT(NVL(GF_SQLEXECScalarNull("select dbo.gfn_StringToFox(value) from dbo.general_register where id_register = 'P_POSREDNIK' and id_key = '" +lcIdPosrednik +"'"), ""))
				lcMessage = lcMessage +"Za TKU Tip kalkulacije se automatski postavila vrijednost 'Otvorena' jer ugovor ima unesenog Posrednika = " +lcIdPosrednik +" " +lcPosrednikNaziv +"." +gce

			ENDIF
		ENDIF
		
	ENDIF
	
	
	* TKGU Tip kalkulacije guma: Otvorena or Zatvorena
	select * from kategorije where sifra = 'TKGU' into cursor _ef_kategorije_TKGU  

	IF !GF_NULLOREMPTY(_ef_kategorije_TKGU.id_kategorije_tip) AND GF_NULLOREMPTY(_ef_kategorije_TKGU.id_kategorije_sifrant) && for active entity only when it is empty 
		
		lcId_cont = loForm.txtId_entitete.Value
		lcIdPosrednik = ALLT(NVL(GF_SQLEXECScalarNull("select id_posrednik from dbo.pogodba where id_cont = "+GF_Quotedstr(lcId_cont )), ""))
		
		IF lcIdPosrednik == "FLT" 
			
			TEXT TO lcSQL01 NOSHOW
				select ks.id_kategorije_sifrant, ks.id_kategorije_tip, ks.vrednost, ks.neaktiven
				from dbo.kategorije_sifrant ks
				where ks.neaktiven = 0
				and ks.vrednost = 'Limitirana'
				and ks.id_kategorije_tip = 
			ENDTEXT 
			lcId_kategorije_tip = NVL(_ef_kategorije_TKGU.id_kategorije_tip_p, _ef_kategorije_TKGU.id_kategorije_tip)  && If a category is connected with ponudba, then list of values from registry is from id_kategorije_tip_p, and not from id_kategorije_tip. Ako se kategorija preuzima iz ponude, onda je i lista šifranta iz ponude id_kategorije_tip_p, a ne iz id_kategorije_tip
			GF_SQLEXEC(lcSQL01 +trans(lcId_kategorije_tip), "_ef_sifrant_TKGU_Limitirana")
			
			IF RECCOUNT("_ef_sifrant_TKGU_Limitirana") == 0
				POZOR("Šifrant TKGU Tip kalkulacije guma nema definiran šifrant s vrijednošću 'Limitirana' pa se vrijednost ne može postaviti!")
			ELSE
				lcPostavljanje = "loForm.Block_kategorije." +allt(_ef_kategorije_TKGU.obj_name) +".Value = "+trans(_ef_sifrant_TKGU_Limitirana.id_kategorije_sifrant)
				&lcPostavljanje
				
				lcPosrednikNaziv = ALLT(NVL(GF_SQLEXECScalarNull("select dbo.gfn_StringToFox(value) from dbo.general_register where id_register = 'P_POSREDNIK' and id_key = '" +lcIdPosrednik +"'"), ""))
				lcMessage = lcMessage +"Za TKGU Tip kalkulacije guma se automatski postavila vrijednost 'Limitirana' jer ugovor ima unesenog Posrednika = " +lcIdPosrednik +" " +lcPosrednikNaziv +"." +gce
			ENDIF
		ENDIF
	ENDIF
	
	IF !EMPTY(lcMessage)
		OBVESTI(lcMessage)
	ENDIF
ENDIF 
**** KRAJ MID 52996
****************