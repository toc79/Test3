-- 07.03.2023 g_majak MID 47851 - created based on select in grp_Int_intr_candidates
-- 08.03.2023 g_tomislav MID 49406 - excluded contracts with NI document 

DECLARE @dat_zak char(8), @zap_obr char(1)
SET @dat_zak = CONVERT(char(8), (SELECT TOP 1 datum_zak FROM dbo.nastavit), 112)  
SET @zap_obr = (SELECT CAST(pol_je_1ob AS char(1)) FROM dbo.nastavit) 

SELECT can.id_pog,  
	can.id_kupca,  
	can.naz_kr_kup,  
	can.vrsta_osebe_partner,  
	can.id_dob,  
	can.naziv_kr_dob,  
	can.dat_aktiv,  
	can.datum_dok,  
	can.dat_zap,  
	can.dat_aktiv AS dat_od,  
	case   
		when can.beg_end = 1 or dbo.gfn_GetCustomSettingsAsBool('IntercalaryInt_EndModeAsBeginMode') = 1 then can.datum_dok   
		else dbo.gfn_MonthAddLastDay(-(12/obnaleto), datum_dok)   
	end AS dat_do,  
	can.net_nal,  
	can.id_val,  
	can.obr_mera,  
	can.nacin_leas,  
	can.status_akt,  
	can.id_cont,  
	can.id_tec,  
	case when can.st_dni < 0 then 0 else can.st_dni end as st_dni,  
	can.aneks,  
	CAST(0 AS bit) AS oznacen,  
	CAST(CASE  
			WHEN (  
				can.datum_dok > @dat_zak  
				AND can.datum_dok <= can.dat_zap  
				AND can.st_dni > 0  
				AND can.obr_mera > 0  
			)  
			THEN 1  
			ELSE 0  
			END AS bit  
		) AS intk_candidat,  
	1 AS tip_izracuna  
FROM dbo.gfn_get_fin_intr_candidates1(@zap_obr, null, null) can  
LEFT JOIN dbo.pogodba pog on can.id_cont = pog.id_cont
WHERE pog.id_posrednik not in (select val_char from dbo.general_register where neaktiven = 0 and id_register = 'EXCL_POSREDNIK_INTERCALAR')
and not exists (select * from dbo.dokument where id_obl_zav = 'NI' and id_cont = can.id_cont)