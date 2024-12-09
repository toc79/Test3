LOCAL loForm, lcSql1, lcId_cont

lcId_cont = dokument.id_cont
loForm = NULL

FOR lnI = 1 TO _Screen.FormCount
	IF UPPER(_Screen.Forms(lnI).Name) == UPPER("frmdokument_maska") THEN
		loForm = _Screen.Forms(lnI)
		EXIT
	ENDIF
NEXT
IF ISNULL(loForm) THEN
	RETURN
ENDIF

TEXT TO lcSql1 NOSHOW
	Select id_cont, id_tec, id_val from dbo.pogodba where id_cont = {0}
ENDTEXT
lcSql1 = STRTRAN(lcSql1, '{0}', trans(lcId_cont))

if dokument.id_obl_zav = allt(GF_CustomSettings("ROL_DOCUMENT_DONT_SEND")) OR dokument.id_obl_zav = allt(GF_CustomSettings("ROL_REACTIVATE_DOCUMENT"))
	If _Screen.Forms(lnI).tip_vnosne_maske = 1
		loForm.chkPotrebno.Value = 0
		loForm.chkIma.Value = 1
	EndIf
endif

if dokument.id_obl_zav = allt(GF_CustomSettings("ROL_ADD_OBJECT_DOCUMENT"))
	loForm.txtVrednost.Obvezen = .t.
	loForm.lblVrednost.Caption = "Neto vrij. objekta"
	loForm.txtStevilka.Obvezen = .f.
	loForm.lblStevilka.Caption = "Ser.br./šas/trup"
	loForm.edtOpis1.Obvezen = .t.
	loForm.lblOpis1.Caption = "Marka"
	loForm.edtOpombe.Obvezen = .t.
	loForm.lblOpombe.Caption = "Model"
	loForm.txtId_tec.Enabled = .f.
	loForm.txtId_zapo.Enabled = .f.
	loForm.txtKategorija3.Obvezen = .t.
	loForm.lblKategorija3.Caption = "Vrsta objekta"
	loForm.chkIs_elligible.Caption = "Prodano"
	If _Screen.Forms(lnI).tip_vnosne_maske = 1
		GF_SQLEXEC(lcSQL1, "_pog_rol")
		loForm.chkPotrebno.Value = 0
		loForm.chkIma.Value = 1
		loForm.txtId_tec.Value = _pog_rol.id_tec
		loForm.txtId_Val.Value = _pog_rol.id_val
		use in _pog_rol
	EndIf
endif

if dokument.id_obl_zav = allt(GF_CustomSettings("ROL_CORRECTION_VALUE_DOCUMENT"))
	loForm.txtVrednost.Obvezen = .t.
	loForm.lblVrednost.Caption = "Neto vrij. objekta"
	loForm.txtId_tec.Enabled = .f.
	If _Screen.Forms(lnI).tip_vnosne_maske = 1
		GF_SQLEXEC(lcSQL1, "_pog_rol")
		loForm.chkPotrebno.Value = 0
		loForm.chkIma.Value = 1
		loForm.txtId_tec.Value = _pog_rol.id_tec
		loForm.txtId_Val.Value = _pog_rol.id_val
		use in _pog_rol
	EndIf
endif

**RLHR ticket ??
IF !(ISNULL(dokument.id_cont)) and dokument.id_obl_zav = 'TV'
	loForm.txtKategorija1.obvezen = .T.
ENDIF

**RLHR ticket 1575 
**02.10.2020, g_dejank, MR 44945 cast general_register.value as text zbog novog ODBC driver-a
TEXT TO lcSQL NOSHOW
	DECLARE @lista varchar(300)
	SET @lista = (Select cast(value as [text]) as value from dbo.GENERAL_REGISTER Where ID_REGISTER = 'RLC Reporting list' and id_key = 'RLC_OBV_HIPOT' and neaktiven = 0)

	IF EXISTS (Select LTRIM(RTRIM(id)) as id From dbo.gfn_GetTableFromList(@lista) Where  LTRIM(RTRIM(id)) = '{0}')
		BEGIN 
			Select CAST(1 as bit) as ima
		END
	ELSE
		BEGIN
			Select CAST(0 as bit) as ima
		END
ENDTEXT

lcSQL = STRTRAN(lcSQL, "{0}", ALLT(dokument.id_obl_zav))
lcDOK = GF_SQLExecScalarNull(lcSQL)

IF !GF_NULLOREMPTY(lcDOK) AND lcDOK = .T. THEN
	loForm.txtid_hipot.obvezen = .T.
ENDIF

***********************************************************************************************************
**23.08.2016 - g_dejank - dodavanje kontrola, obavezna polja po vrsti dokumenta po MR 36186
**INLIST prihvača najviše 24 argumenta zato je stavljeno u 2 dijela

IF INLIST(dokument.id_obl_zav,'AK','BG','BK','D1','E1','E2','ED','EG','EL','EN','EO','EP','EZ') OR INLIST(dokument.id_obl_zav,'G1','G2','GL','GO','H1','H2','HL','IE','OP','OZ','PW','PZ','PŽ','RA','RE')
	loForm.txtvelja_do.Obvezen = .t.
	loForm.txtvelja_do.BackColor = 8454143
	loForm.txtzacetek.Obvezen = .t.
	loForm.txtzacetek.BackColor = 8454143
	loForm.txtid_tec.Obvezen = .t.
	loForm.txtid_tec.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'AK','BG','BK','D1','E1','E2','ED','EG','EL','EN','EO','EP','EZ') OR INLIST(dokument.id_obl_zav,'G1','G2','GL','GO','H1','H2','HL','IE','OP','OZ','PW','PZ','PŽ','RA')
	loForm.txtOcen_vred.Obvezen = .t.
	loForm.txtOcen_vred.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'BG','D1','E1','E2','ED','EG','EL','EN','EO','EP') OR INLIST(dokument.id_obl_zav,'G1','G2','GL','GO','H1','H2','HL','IE','RA','RE')
	loForm.txtvrednost.Obvezen = .t.
	loForm.txtvrednost.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'BG','D1','E1','E2','ED','EG','EL','EN','EO','EP','EZ') OR INLIST(dokument.id_obl_zav,'G1','G2','GL','GO','H1','H2','HL','IE','OZ','RA')
	loForm.txtTip_cen.Obvezen = .t.
	loForm.txtTip_cen.BackColor = 8454143
	loForm.txtDat_ocene.Obvezen = .t.
	loForm.txtDat_ocene.BackColor = 8454143
	loForm.txtid_hipot.Obvezen = .t.
	loForm.txtid_hipot.BackColor = 8454143
	loForm.txtDat_vred.Obvezen = .t.
	loForm.txtDat_vred.BackColor = 8454143
	loForm.txtKategorija1.Obvezen = .t.
	loForm.txtKategorija1.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'BG','D1','E1','E2','ED','EG','EL','EN','EO','EP','EZ') OR INLIST(dokument.id_obl_zav,'G1','G2','GL','GO','H1','H2','OZ')
	loForm.txtExtid.Obvezen = .t.
	loForm.txtExtid.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'D1','E1','E2','ED','EL','EO','EZ','EP','H2') OR INLIST(dokument.id_obl_zav,'G1','G2','GL','GO','OZ')
	loForm.txtId_kupca.Obvezen = .t.
	loForm.txtId_kupca.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'E1','E2','ED','EG','EL','EN','EO','EP','EZ') 
	loForm.txtKategorija4.Obvezen = .t.
	loForm.txtKategorija4.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'BG','E1','E2','EG','EL','EO','G1','G2','GO','RA','RE')
	loForm.txtKategorija2.Obvezen = .t.
	loForm.txtKategorija2.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'EZ','PW','PZ','PŽ')
	loForm.txtId_pov_dok.Obvezen = .t.
	loForm.txtId_pov_dok.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'RA')
	loForm.txtDat_korig_vred.Obvezen = .t.
	loForm.txtDat_korig_vred.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'RA')
	loForm.txtdatum.Obvezen = .t.
	loForm.txtdatum.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'AK','BK','D1','ED','EZ','OP','OZ','PW','PZ','PŽ')
	loForm.txtstevilka.Obvezen = .t.
	loForm.txtstevilka.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'AK','BK','EZ','OP','OZ','PW','PZ','PŽ')
	loForm.txtid_zav.Obvezen = .t.
	loForm.txtid_zav.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'BG','D1','E1','ED','EG')
	loForm.txtid_sdk.Obvezen = .t.
	loForm.txtid_sdk.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'EN','H1','HL')
	loForm.txtStatus_zk.Obvezen = .t.
	loForm.txtStatus_zk.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'EN','H1','HL')
	loForm.txtid_npr_enote.Obvezen = .t.
	loForm.txtid_npr_enote.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'EN','EP','H1','H2')
	loForm.txtRang_hipo.Obvezen = .t.
	loForm.txtRang_hipo.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'EN','EP','H1','H2')
	loForm.txtZn_prednos.Obvezen = .t.
	loForm.txtZn_prednos.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'EN','H1','HL','RE')
	loForm.txtKategorija3.Obvezen = .t.
	loForm.txtKategorija3.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'BG','E1','E2','EG','EO','G1','G2','GO')
	loForm.txtKategorija6.Obvezen = .t.
	loForm.txtKategorija6.BackColor = 8454143
ENDIF
IF INLIST(dokument.id_obl_zav,'HP','PU')
	loForm.txtDat_ocene.Obvezen = .t.
	loForm.txtDat_ocene.BackColor = 8454143
	loForm.txtTip_cen.Obvezen = .t.
	loForm.txtTip_cen.BackColor = 8454143
	loForm.txtvrednost.Obvezen = .t.
	loForm.txtvrednost.BackColor = 8454143
	loForm.txtid_tec.Obvezen = .t.
	loForm.txtid_tec.BackColor = 8454143
ENDIF
***********************************************************************************************************
***************************************************
* 22.11.2016. g_tomislav MR 36380 - OBAVEZNO PROVJERITI -> kursori kreirani kod ove kontrole se koriste i u provjeri u DOKUMENT_MASKA_PREVERI_PODATKE
* lista dokumenta RLC Reporting list, ključ RLC_DAT_VRACANJA
* funkcija se okida i nakon snimanja podataka što baš i nije OK?
* 07.12.2016. g_tomislav MR 36958 - dodan dio koda  !USED("_ef_datum_plaćanja")
**02.10.2020, g_dejank, MR 44945 cast general_register.value as text zbog novog ODBC driver-a
**25.1.2021 g_vuradin,MR 46180 dodavanje saldiranih krovnih ugovora i okvira
 
IF !USED("_ef_datum_plaćanja") && DOKUMENT_MASKA_SET_CRL_MANDATORY se okida i nakon DOKUMENT_MASKA_PREVERI_PODATKE funkcije pa zato ovaj dio koda potreban. Ili dodati novi kursor i oznaku da ne treba izvršavati
	 
	TEXT TO lcSQL36380_1 NOSHOW
		DECLARE @lista varchar(300)
		SET @lista = (Select cast(value as [text]) as value from dbo.GENERAL_REGISTER Where ID_REGISTER = 'RLC Reporting list' and id_key = 'RLC_DAT_VRACANJA' and neaktiven = 0)

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
					inner join (Select fr.ID_KROV_POG, CASE WHEN SUM(saldo)> 0 THEN 0 ELSE 1 END AS Saldiran
										From dbo.planp a
									inner join dbo.krov_pog_pogodba fr on fr.id_cont=a.ID_CONT		
									inner join dbo.pogodba	pog on a.id_cont=pog.ID_CONT	
									Inner join dbo.vrst_ter b on a.id_terj = b.id_terj
									Where b.sif_terj <> 'OPC' 
									and (pog.status_akt = 'A' OR (pog.status_akt = 'Z' AND pog.DAT_ZAKL > '20140530'))
								Group by fr.ID_KROV_POG
					) c	ON b.ID_KROV_POG = c.ID_KROV_POG and c.Saldiran = 1		
					WHERE a.ID_KROV_POG = {0}  				
					OR a.ID_KROV_POG in (SELECT id_krov_pog FROM dbo.krov_pog_pogodba WHERE id_cont = {1})
					group by b.id_cont

			ENDTEXT
			
			lcSQL36380_3 = STRTRAN(lcSQL36380_3, '{0}', gf_quotedstr(dokument.id_krov_pog))
			lcSQL36380_3 = STRTRAN(lcSQL36380_3, '{1}', gf_quotedstr(dokument.id_cont))
			
			GF_SQLEXEC(lcSQL36380_3, "_ef_krov_pog_pogodba")
			lcList = GF_CreateDelimitedList("_ef_krov_pog_pogodba", "id_cont ", LcList_condition, ",") 
		ENDIF
		
		IF EMPTY(lcList) AND (!GF_NULLOREMPTY(dokument.id_frame) OR !GF_NULLOREMPTY(dokument.id_cont)) && da li se radi o krovnom dokumentu ili ugovoru vezanom na okvir
			TEXT TO lcSQL36380_4 NOSHOW
				select a.id_cont
from
					(select fr.id_cont,isnull (broj_zad.br_zaduznica,0) br_zaduznica
					from dbo.frame_pogodba fr
						left join (select a.id_cont, fr.id_frame, count(*) br_zaduznica
											from DOKUMENT a
											join frame_pogodba fr on fr.id_cont=a.ID_CONT
											where a.id_cont in 
															(select a.id_cont from frame_pogodba a
															join dbo.pogodba p on p.id_cont = a.id_cont
															join dbo.partner part on part.id_kupca=p.id_kupca)					
												and a.ID_OBL_ZAV = 'ZO' 				
					group by a.id_cont,fr.id_frame) broj_zad on broj_zad.ID_CONT=fr.id_cont and fr.id_frame=broj_zad.id_frame ) a
where a.br_zaduznica=0 and a.id_cont = {3}	 --OKVIR NEMA GRUPNU ZADUŽNICU 
group by a.id_cont
					
UNION
select fr.id_cont
					from dbo.frame_pogodba fr
						inner join (select distinct a.id_cont, fr.id_frame, count(*) br_zaduznica
								 from DOKUMENT a
								 join frame_pogodba fr on fr.id_cont=a.ID_CONT
								 where a.id_cont in 
								(select a.id_cont from frame_pogodba a
								join dbo.pogodba p on p.id_cont = a.id_cont
								join dbo.partner part on part.id_kupca=p.id_kupca)					
								and ID_OBL_ZAV = 'ZO' 
					group by a.id_cont,fr.id_frame) broj_zad on broj_zad.ID_CONT=fr.id_cont and fr.id_frame=broj_zad.id_frame   --OKVIR IMA GRUPNU ZADUŽNICU 
					inner join (Select fr.id_frame, CASE WHEN SUM(saldo)> 0 THEN 0 ELSE 1 END AS Saldiran
								From dbo.planp a
								inner join dbo.frame_pogodba fr on fr.id_cont=a.ID_CONT		
								inner join dbo.pogodba	pog on a.id_cont=pog.ID_CONT	
								Inner join dbo.vrst_ter b on a.id_terj = b.id_terj
								Where b.sif_terj <> 'OPC' 
								AND (fr.id_frame = {2} OR fr.id_frame in (SELECT id_frame FROM dbo.frame_pogodba WHERE id_cont = {3}))	
								and (pog.status_akt = 'A' OR (pog.status_akt = 'Z' AND pog.DAT_ZAKL > '20140530'))
								Group by fr.id_frame
								) b	ON b.id_frame = fr.id_frame and b.Saldiran = 1		
						WHERE fr.id_frame in (select id_frame from dbo.frame_list where status_akt='Z')	
				group by fr.id_cont
			ENDTEXT
			
			lcSQL36380_4 = STRTRAN(lcSQL36380_4, '{2}', gf_quotedstr(dokument.id_frame))
			lcSQL36380_4 = STRTRAN(lcSQL36380_4, '{3}', gf_quotedstr(dokument.id_cont))
			
			GF_SQLEXEC(lcSQL36380_4, "_ef_frame_pogodba")
			lcList = GF_CreateDelimitedList("_ef_frame_pogodba", "id_cont ", LcList_condition, ",") 
		ENDIF
		
		TEXT TO lcSQLS46180_1 NOSHOW
				Select a.id_cont
				from dbo.pogodba a
				left join dbo.frame_pogodba fr ON fr.id_cont=a.ID_CONT
				left join dbo.krov_pog_pogodba b ON a.id_cont=b.ID_CONT
				where (fr.id_cont is not null or b.ID_CONT is not null) and a.id_cont={1}
		ENDTEXT

		lcSQLS46180_1 = STRTRAN(lcSQLS46180_1, '{1}', gf_quotedstr(dokument.id_cont))

		lnJeNaListiokvkrov = GF_SQLExecScalarNull(lcSQLS46180_1) && id_cont je dio okvira ili krovnog ugovora

		IF EMPTY(lcList) AND GF_NULLOREMPTY(lnJeNaListiokvkrov) and !GF_NULLOREMPTY(dokument.id_cont) 
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
ENDIF
** KRAJ MR 36380*************************************************
***************************************************
* 19.05.2017 g_tomislav MR 38009
**02.10.2020, g_dejank, MR 44945 cast general_register.value as text zbog novog ODBC driver-a
IF loForm.tip_vnosne_maske == 1
	LOCAL lcSQL38009, lnDokJeNaListi38009
	TEXT TO lcSQL38009 NOSHOW
		DECLARE @lista varchar(1000)
		SET @lista = (Select cast(val_char as [text]) as val_char from dbo.GENERAL_REGISTER Where ID_REGISTER = 'DOK_KATEGORIJA4' AND ID_KEY = 'A' AND neaktiven = 0) 
		Select count(*) AS id FROM dbo.gfn_GetTableFromList(@lista) Where LTRIM(RTRIM(id)) = '{0}'
	ENDTEXT
	lcSQL38009 = STRTRAN(lcSQL38009, "{0}", ALLT(dokument.id_obl_zav))
	lnDokJeNaListi38009 = GF_SQLExecScalarNull(lcSQL38009) && ako nema kategorije 4, rezultat će isto biti 0

	IF lnDokJeNaListi38009 > 0 THEN
		loForm.txtKategorija4.Value = "A"
	ENDIF
ENDIF
** KRAJ MR 38009*************************************************

***************************************************
**13.10.2022 g_nenadm, MR 48015 obavezan identifikator suglasnosti
***************************************************
if dokument.id_obl_zav = "SE" then
	loForm.txtStevilka.Obvezen = .T.
	loForm.lblStevilka.Caption = "Identifikator su."
	loForm.txtStevilka.BackColor = 8454143
endif
**KRAJ MR 48015************************************

***************************************************
**13.10.2022 g_nenadm, MR 48015 obavezan identifikator suglasnosti
***************************************************
if dokument.id_obl_zav = "SE" then
	loForm.txtStevilka.Obvezen = .T.
	loForm.lblStevilka.Caption = "Identifikator su."
	loForm.txtStevilka.BackColor = 8454143
endif
**KRAJ MR 48015*************************************************