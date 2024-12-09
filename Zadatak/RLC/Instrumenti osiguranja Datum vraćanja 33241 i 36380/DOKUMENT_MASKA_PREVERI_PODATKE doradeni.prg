***************************************************
** 31.10.2016. g_tomislav MR 36380 - isto je podešeno i u DOKUMENT_MASKA_SET_CRL_MANDATORY 
* lista dokumenta RLC Reporting list, ključ RLC_DAT_VRACANJA
TEXT TO lcSQL36380_1 NOSHOW
	DECLARE @lista varchar(300)
	SET @lista = (Select value from dbo.GENERAL_REGISTER Where ID_REGISTER = 'RLC Reporting list' and id_key = 'RLC_DAT_VRACANJA' and neaktiven = 0) 

	Select count(*) AS id FROM dbo.gfn_GetTableFromList(@lista) Where LTRIM(RTRIM(id)) = '{0}'
ENDTEXT

lcSQL36380_1 = STRTRAN(lcSQL36380_1, "{0}", ALLT(dokument.id_obl_zav))
lnDokJeNaListi = GF_SQLExecScalarNull(lcSQL36380_1) && ako nema RLC_DAT_VRACANJA, rezultat će isto biti 0

IF loForm.tip_vnosne_maske = 2 AND lnDokJeNaListi > 0 THEN 
	IF !GF_NULLOREMPTY(dokument.id_cont) && provjera da li je dokument vezan na ugovor (ili na okvir ili na krovni okvir)
		TEXT TO lcSQL36380_2 NOSHOW 		
			--UGOVORI KOJI SU SALDIRANI
			Select count(*)
			From dbo.pogodba a
			--SALDO IZ PLANA OTPLATE
			Inner join (Select id_cont, CASE WHEN SUM(saldo)> 0 THEN 0 ELSE 1 END AS Saldiran
					From dbo.planp a
					Inner join dbo.vrst_ter b on a.id_terj = b.id_terj
					Where b.sif_terj <> 'OPC' Group by id_cont) b 
				ON a.id_cont = b.id_cont and b.Saldiran = 1
			Where (a.status_akt = 'A' OR (a.status_akt = 'Z' AND a.DAT_ZAKL > '20140530'))
			AND a.id_cont = 
		ENDTEXT
	
		IF GF_SQLExecScalarNull(lcSQL36380_2+gf_quotedstr(dokument.id_cont)) > 0 && za ugovor radi provjeru
			TEXT TO lcSQL36380_3 NOSHOW
				SELECT	max(pl.dat_pl) as max_datum_placanja --, l.id_cont, l.id_kupca,
				FROM dbo.lsk l 
				INNER JOIN dbo.placila pl on l.id_plac = pl.id_plac
				WHERE l.id_plac <> -1
				AND l.Kredit_DOM <> 0
				AND l.ID_Dogodka IN ('PLAC_IZ_AV','PLAC_ODPIS','PLAC_VRACI', 'PLAC_ZA_OD', 'PLACILO ', 'AV_VRACILO', 'AV_ODPIS', 'AV_ZAC_ODP')
				AND l.id_cont = 
			ENDTEXT
		
			&&lcSQL36380_3 = STRTRAN(lcSQL36380_3, "{0}", lcId_cont)
			lcSQL36380_3 = lcSQL36380_3 +gf_quotedstr(dokument.id_cont)+ " GROUP BY l.id_cont" 
			ldDatumZadnjegPlacanja = NVL(GF_SQLExecScalarNull(lcSQL36380_3),{01.01.1900})
			ldKontrolniDatum = TTOD(ldDatumZadnjegPlacanja) + 60 
			ldVrnjen36380 = dokument.vrnjen	 && definiran je na vrhu funkcije
			IF !GF_NULLOREMPTY(ldVrnjen36380) AND ldVrnjen36380 > ldKontrolniDatum 					
				IF !potrjeno ("Datum vraćanja je veći od zakonskog datuma vraćanja koji je "+gStr(ldKontrolniDatum)+". Da li želite nastaviti sa spremanjem?")
					RETURN .F.
				ENDIF
			ELSE
				pozor ("Datum vraćanja nije unesen, a obavezan je za ugovore koji su istekli!") && DOKUMENT_MASKA_SET_CRL_MANDATORY se okida i nakon ove fnkcije pa zato ovaj dio koda
				RETURN .F.
			ENDIF
		ENDIF
	ENDIF
ENDIF

