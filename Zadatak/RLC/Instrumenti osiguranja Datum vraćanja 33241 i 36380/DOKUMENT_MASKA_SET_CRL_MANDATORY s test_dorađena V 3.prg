***************************************************
** 02.11.2016. g_tomislav MR 36380 - isto je podešeno na DOKUMENT_MASKA_PREVERI_PODATKE
** 17.11.2016  g_tomislav MR 36380 - dodatna dorada
* lista dokumenta RLC Reporting list, ključ RLC_DAT_VRACANJA
* funkcija se okida i nakon snimanja podataka što baš i nije OK?
TEXT TO lcSQL36380_1 NOSHOW
	DECLARE @lista varchar(300)
	SET @lista = (Select value from dbo.GENERAL_REGISTER Where ID_REGISTER = 'RLC Reporting list' and id_key = 'RLC_DAT_VRACANJA' and neaktiven = 0) 

	Select count(*) AS id FROM dbo.gfn_GetTableFromList(@lista) Where LTRIM(RTRIM(id)) = '{0}'
ENDTEXT

lcSQL36380_1 = STRTRAN(lcSQL36380_1, "{0}", ALLT(dokument.id_obl_zav))
lnDokJeNaListi = GF_SQLExecScalarNull(lcSQL36380_1) && ako nema RLC_DAT_VRACANJA, rezultat će isto biti 0

IF loForm.tip_vnosne_maske = 2 AND lnDokJeNaListi > 0 THEN 
	lcLIst = ""
	LcList_condition = ""  && Mora biti 
	* Lista ugovora
	IF !GF_NULLOREMPTY(dokument.id_krov_pog) OR !GF_NULLOREMPTY(dokument.id_cont) && da li se radi o krovnom dokumentu ili ugovoru vezanom na krovnom
		TEXT TO lcSQL36380_3 NOSHOW
				SELECT b.id_cont FROM dbo.krov_pog a 
				LEFT JOIN dbo.krov_pog_pogodba b ON a.id_krov_pog = b.id_krov_pog 
				WHERE a.ID_KROV_POG = {0} 
				OR a.ID_KROV_POG in (SELECT id_krov_pog FROM dbo.krov_pog_pogodba WHERE id_cont = {1})
		ENDTEXT
		
		lcSQL36380_3 = STRTRAN(lcSQL36380_3, '{0}', gf_quotedstr(dokument.id_krov_pog))
		lcSQL36380_3 = STRTRAN(lcSQL36380_3, '{1}', gf_quotedstr(dokument.id_cont))
		
		GF_SQLEXEC(lcSQL36380_3, "_ef_krov_pog_pogodba")
		lcList = GF_CreateDelimitedList("_ef_krov_pog_pogodba", "id_cont ", LcList_condition, ",") 
	ENDIF
	
	IF EMPTY(lcList) AND (!GF_NULLOREMPTY(dokument.id_frame) OR !GF_NULLOREMPTY(dokument.id_cont)) && da li se radi o krovnom dokumentu ili ugovoru vezanom na okvir
		TEXT TO lcSQL36380_4 NOSHOW
			SELECT b.id_cont FROM dbo.frame_list a 
			LEFT JOIN dbo.frame_pogodba b ON a.id_frame = b.id_frame 
			WHERE a.status_akt='Z' 
			AND (a.id_frame = {2} OR a.id_frame in (SELECT id_frame FROM dbo.frame_pogodba WHERE id_cont = {3}))
		ENDTEXT
		
		lcSQL36380_4 = STRTRAN(lcSQL36380_4, '{2}', gf_quotedstr(dokument.id_frame))
		lcSQL36380_4 = STRTRAN(lcSQL36380_4, '{3}', gf_quotedstr(dokument.id_cont))
		
		GF_SQLEXEC(lcSQL36380_4, "_ef_frame_pogodba")
		lcList = GF_CreateDelimitedList("_ef_frame_pogodba", "id_cont ", LcList_condition, ",") 
	ENDIF
	
	IF EMPTY(lcList) AND !GF_NULLOREMPTY(dokument.id_cont) 
		lcLIst = trans(dokument.id_cont)
	ENDIF
	
	**
	IF !GF_NULLOREMPTY(lcLIst) && provjera da li je dokument vezan na ugovor ili na okvir ili na krovni okvir
		&& main logic - dobivanje datuma zadnjeg plaćanja
		TEXT TO lcSQL36380_2 NOSHOW 		
			--UGOVORI KOJI SU SALDIRANI ILI ZAKLJUČENI PREMA IZVJEŠTAJU (CA) Praćenje povrata instrumenata po saldiranim ugovorima
			SELECT MAX(c.max_datum_placanja) as max_datum_placanja
			FROM dbo.pogodba a
			--SALDO IZ PLANA OTPLATE
			INNER JOIN (Select id_cont, CASE WHEN SUM(saldo)> 0 THEN 0 ELSE 1 END AS Saldiran
				From dbo.planp a
				Inner join dbo.vrst_ter b on a.id_terj = b.id_terj
				Where b.sif_terj <> 'OPC' Group by id_cont
				) b	ON a.id_cont = b.id_cont and b.Saldiran = 1
			LEFT JOIN (SELECT max(pl.dat_pl) as max_datum_placanja , l.id_cont --, l.id_kupca,
				FROM dbo.lsk l 
				INNER JOIN dbo.placila pl on l.id_plac = pl.id_plac
				WHERE l.id_plac <> -1
				AND l.Kredit_DOM <> 0
				AND l.ID_Dogodka IN ('PLAC_IZ_AV','PLAC_ODPIS','PLAC_VRACI', 'PLAC_ZA_OD', 'PLACILO ', 'AV_VRACILO', 'AV_ODPIS', 'AV_ZAC_ODP')
				GROUP BY l.id_cont
				) c ON a.id_cont = c.id_cont
			Where (a.status_akt = 'A' OR (a.status_akt = 'Z' AND a.DAT_ZAKL > '20140530'))
			AND a.id_cont in ( 
		ENDTEXT
	
		GF_SQLExec(lcSQL36380_2+iif(len(alltrim(lcList))=0,"0",lcList)+")","_ef_datum_plaćanja")
		ldDatumZadnjegPlacanja = _ef_datum_plaćanja.max_datum_placanja
		
		IF !GF_NULLOREMPTY(ldDatumZadnjegPlacanja)
			
			ldKontrolniDatum = TTOD(ldDatumZadnjegPlacanja) + 60 
					
			IF GF_NULLOREMPTY(loForm.txtVrnjen.Value) 
				loForm.txtVrnjen.Value = DATE()
				
				IF loForm.txtVrnjen.Value > ldKontrolniDatum					
					pozor ("Datum vraćanja je popunjen s današnjim datumom! Isti je veći od zakonskog datuma vraćanja koji je "+gStr(ldKontrolniDatum)+".")
				ELSE
					obvesti ("Datum vraćanja je popunjen s današnjim datumom! Isti je manji zakonskog datuma vraćanja koji je "+gStr(ldKontrolniDatum)+".")
				ENDIF
			
			ELSE
			&& kad je popunjen netreba poruka sada, već kod spremanja podataka -> Ipak treba jer se kontrola okida nakon preveri podatke
				IF loForm.txtVrnjen.Value > ldKontrolniDatum
					pozor ("Datum vraćanja je veći od zakonskog datuma vraćanja koji je "+gStr(ldKontrolniDatum)+".")
				ELSE
					*obvesti ("Datum vraćanja je manji zakonskog datuma vraćanja koji je "+gStr(ldKontrolniDatum)+".") && treba i netreba pa sam maknuo
				ENDIF
			ENDIF
		ENDIF	
	ENDIF
ENDIF
