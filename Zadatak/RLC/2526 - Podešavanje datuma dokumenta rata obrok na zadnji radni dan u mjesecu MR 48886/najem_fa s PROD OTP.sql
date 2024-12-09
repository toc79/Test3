{najem_fa.razdoblje.Trim()} {Format("{0:N2}", najem_fa.SNETO+najem_fa.SMARZA+najem_fa.SOBRESTI)}
{najem_fa.razdoblje_regist_ispis.Trim()} {Format("{0:N2}", najem_fa.SREGIST)}

--07.04.2020 Tomislav MID 44543 - changeing logic for razdoblje_osnova; added new sentenance for lpi COVID19 in obresti_opis

DECLARE @DN_kategorija1 varchar(50)
SET @DN_kategorija1 = (SELECT TOP 1 id_key FROM dbo.gfn_g_register('DOK_KATEGORIJA1') WHERE val_char = 'DN' AND neaktiven = 0) --Kategorija 1 za DN dokument

Select x.*,

CASE WHEN x.sif_terj <> 'LOBR' 
	THEN RTRIM(x.naziv_terj)
ELSE 
CASE WHEN x.razdoblje_DN_dok != '' THEN x.razdoblje_DN_dok
	ELSE	
	Case when x.rata_type = 'Anticipative' Then 
				CASE 
					When x.obnaleto = 12 Then 
						-- MID:42602, g_barbarak - promjena izračuna razdoblja za obnaleto = 12
						--Replace(Replace(razdoblje_osnova,'$[0].', LTRIM(RTRIM(CONVERT(CHAR, REPLICATE('0', 2 - LEN(MONTH(DATEADD(mm,12/x.obnaleto,x.datum_dok)-1)))))) + LTRIM(RTRIM(CONVERT(CHAR, MONTH(DATEADD(mm,12/x.obnaleto,x.datum_dok)-1)))) + '/' + LTRIM(RTRIM(CONVERT(CHAR,YEAR(DATEADD(mm,12/x.obnaleto,x.datum_dok)-1))))),'$[1].','')
						  REPLACE(REPLACE(razdoblje_osnova,'$[0].', LTRIM(RTRIM(CONVERT(CHAR, REPLICATE('0', 2 - LEN(MONTH(x.datum_dok)))))) + LTRIM(RTRIM(CONVERT(CHAR, MONTH(x.datum_dok))))+'/'+LTRIM(RTRIM(CONVERT(CHAR, YEAR(x.datum_dok))))),'$[1].','')
					When rata_poslije is null Then
						Replace(Replace(razdoblje_osnova,'$[0].', LTRIM(RTRIM(CONVERT(CHAR, REPLICATE('0', 2 - LEN(MONTH(x.datum_dok)))))) + LTRIM(RTRIM(CONVERT(CHAR, MONTH(x.datum_dok))))+'/'+ LTRIM(RTRIM(CONVERT(CHAR,YEAR(x.datum_dok))))), '$[1].', CASE WHEN x.obnaleto = 12 THEN '' ELSE ' - ' + LTRIM(RTRIM(CONVERT(CHAR, REPLICATE('0', 2 - LEN(MONTH(DATEADD(mm,12/x.obnaleto,x.datum_dok)-1)))))) + LTRIM(RTRIM(CONVERT(CHAR, MONTH(DATEADD(mm,12/x.obnaleto,x.datum_dok)-1)))) + '/' + LTRIM(RTRIM(CONVERT(CHAR,YEAR(DATEADD(mm,12/x.obnaleto,x.datum_dok)-1)))) END)
					When rata_poslije is not null Then 	
						Replace(Replace(razdoblje_osnova,'$[0].', LTRIM(RTRIM(CONVERT(CHAR, REPLICATE('0', 2 - LEN(MONTH(x.datum_dok)))))) + LTRIM(RTRIM(CONVERT(CHAR, MONTH(x.datum_dok))))+'/'+LTRIM(RTRIM(CONVERT(CHAR,YEAR(x.datum_dok))))), '$[1].', CASE WHEN x.obnaleto = 12 THEN '' ELSE ' - ' +LTRIM(RTRIM(CONVERT(CHAR, REPLICATE('0', 2 - LEN(MONTH(x.rata_poslije-1)))))) + LTRIM(RTRIM(CONVERT(CHAR, MONTH(x.rata_poslije-1)))) + '/' + LTRIM(RTRIM(CONVERT(CHAR, YEAR(x.rata_poslije-1))))END)
				End
	     when x.rata_type = 'Decursive' Then 
				Case 
					When x.obnaleto = 12 Then
						REPLACE(REPLACE(razdoblje_osnova,'$[0].', LTRIM(RTRIM(CONVERT(CHAR, REPLICATE('0', 2 - LEN(MONTH(x.datum_dok)))))) + LTRIM(RTRIM(CONVERT(CHAR, MONTH(x.datum_dok))))+'/'+LTRIM(RTRIM(CONVERT(CHAR, YEAR(x.datum_dok))))),'$[1].','')

					
					When rata_prije is null Then
						Replace(Replace(razdoblje_osnova,'$[0].', LTRIM(RTRIM(CONVERT(CHAR, REPLICATE('0', 2 - LEN(MONTH(DATEADD(mm,-12/x.obnaleto,x.datum_dok))))))) + LTRIM(RTRIM(CONVERT(CHAR, MONTH(DATEADD(mm,-12/x.obnaleto,x.datum_dok)))))+'/'+LTRIM(RTRIM(CONVERT(CHAR, YEAR(DATEADD(mm,-12/x.obnaleto,x.datum_dok)))))),'$[1].', CASE WHEN x.obnaleto = 12 THEN '' ELSE ' - ' + LTRIM(RTRIM(CONVERT(CHAR, REPLICATE('0', 2 - LEN(MONTH(x.datum_dok - 1)))))) + LTRIM(RTRIM(CONVERT(CHAR, MONTH(x.datum_dok - 1))))+'/'+LTRIM(RTRIM(CONVERT(CHAR,YEAR(x.datum_dok - 1))))END)
					When x.rata_prije is not null Then
						Replace(Replace(razdoblje_osnova,'$[0].', LTRIM(RTRIM(CONVERT(CHAR, REPLICATE('0', 2 - LEN(MONTH(x.rata_prije)))))) + LTRIM(RTRIM(CONVERT(CHAR, MONTH(x.rata_prije))))+'/'+LTRIM(RTRIM(CONVERT(CHAR, YEAR(DATEADD(mm,-12/x.obnaleto,x.datum_dok)))))),'$[1].', CASE WHEN x.obnaleto = 12 THEN '' ELSE ' - ' + LTRIM(RTRIM(CONVERT(CHAR, REPLICATE('0', 2 - LEN(MONTH(x.datum_dok - 1)))))) + LTRIM(RTRIM(CONVERT(CHAR, MONTH(x.datum_dok - 1))))+'/'+LTRIM(RTRIM(CONVERT(CHAR,YEAR(x.datum_dok - 1))))END)
				End
	End 
END
END  as razdoblje,

CASE WHEN x.tip_leas = 'OL' AND x.sif_terj = 'LOBR' and x.SREGIST > 0
	THEN 
	Case when x.rata_type = 'Anticipative' Then 
				CASE 
					When x.obnaleto = 12 Then 
						Replace(Replace(razdoblje_regist,'$[0].', LTRIM(RTRIM(CONVERT(CHAR, REPLICATE('0', 2 - LEN(MONTH(DATEADD(mm,12/x.obnaleto,x.datum_dok)-1)))))) + LTRIM(RTRIM(CONVERT(CHAR, MONTH(DATEADD(mm,12/x.obnaleto,x.datum_dok)-1)))) + '/' + LTRIM(RTRIM(CONVERT(CHAR,YEAR(DATEADD(mm,12/x.obnaleto,x.datum_dok)-1))))),'$[1].','')
					When rata_poslije is null Then
						Replace(Replace(razdoblje_regist,'$[0].', LTRIM(RTRIM(CONVERT(CHAR, REPLICATE('0', 2 - LEN(MONTH(x.datum_dok)))))) + LTRIM(RTRIM(CONVERT(CHAR, MONTH(x.datum_dok))))+'/'+ LTRIM(RTRIM(CONVERT(CHAR,YEAR(x.datum_dok))))), '$[1].', CASE WHEN x.obnaleto = 12 THEN '' ELSE ' - ' + LTRIM(RTRIM(CONVERT(CHAR, REPLICATE('0', 2 - LEN(MONTH(DATEADD(mm,12/x.obnaleto,x.datum_dok)-1)))))) + LTRIM(RTRIM(CONVERT(CHAR, MONTH(DATEADD(mm,12/x.obnaleto,x.datum_dok)-1)))) + '/' + LTRIM(RTRIM(CONVERT(CHAR,YEAR(DATEADD(mm,12/x.obnaleto,x.datum_dok)-1)))) END)
					When rata_poslije is not null Then 	
						Replace(Replace(razdoblje_regist,'$[0].', LTRIM(RTRIM(CONVERT(CHAR, REPLICATE('0', 2 - LEN(MONTH(x.datum_dok)))))) + LTRIM(RTRIM(CONVERT(CHAR, MONTH(x.datum_dok))))+'/'+LTRIM(RTRIM(CONVERT(CHAR,YEAR(x.datum_dok))))), '$[1].', CASE WHEN x.obnaleto = 12 THEN '' ELSE ' - ' +LTRIM(RTRIM(CONVERT(CHAR, REPLICATE('0', 2 - LEN(MONTH(x.rata_poslije-1)))))) + LTRIM(RTRIM(CONVERT(CHAR, MONTH(x.rata_poslije-1)))) + '/' + LTRIM(RTRIM(CONVERT(CHAR, YEAR(x.rata_poslije-1))))END)
				End
	     when x.rata_type = 'Decursive' Then 
				Case 
					When x.obnaleto = 12 Then
						REPLACE(REPLACE(razdoblje_regist,'$[0].', LTRIM(RTRIM(CONVERT(CHAR, REPLICATE('0', 2 - LEN(MONTH(x.datum_dok)))))) + LTRIM(RTRIM(CONVERT(CHAR, MONTH(x.datum_dok))))+'/'+LTRIM(RTRIM(CONVERT(CHAR, YEAR(x.datum_dok))))),'$[1].','')

					
					When rata_prije is null Then
						Replace(Replace(razdoblje_regist,'$[0].', LTRIM(RTRIM(CONVERT(CHAR, REPLICATE('0', 2 - LEN(MONTH(DATEADD(mm,-12/x.obnaleto,x.datum_dok))))))) + LTRIM(RTRIM(CONVERT(CHAR, MONTH(DATEADD(mm,-12/x.obnaleto,x.datum_dok)))))+'/'+LTRIM(RTRIM(CONVERT(CHAR, YEAR(DATEADD(mm,-12/x.obnaleto,x.datum_dok)))))),'$[1].', CASE WHEN x.obnaleto = 12 THEN '' ELSE ' - ' + LTRIM(RTRIM(CONVERT(CHAR, REPLICATE('0', 2 - LEN(MONTH(x.datum_dok - 1)))))) + LTRIM(RTRIM(CONVERT(CHAR, MONTH(x.datum_dok - 1))))+'/'+LTRIM(RTRIM(CONVERT(CHAR,YEAR(x.datum_dok - 1))))END)
					When x.rata_prije is not null Then
						Replace(Replace(razdoblje_regist,'$[0].', LTRIM(RTRIM(CONVERT(CHAR, REPLICATE('0', 2 - LEN(MONTH(x.rata_prije)))))) + LTRIM(RTRIM(CONVERT(CHAR, MONTH(x.rata_prije))))+'/'+LTRIM(RTRIM(CONVERT(CHAR, YEAR(DATEADD(mm,-12/x.obnaleto,x.datum_dok)))))),'$[1].', CASE WHEN x.obnaleto = 12 THEN '' ELSE ' - ' + LTRIM(RTRIM(CONVERT(CHAR, REPLICATE('0', 2 - LEN(MONTH(x.datum_dok - 1)))))) + LTRIM(RTRIM(CONVERT(CHAR, MONTH(x.datum_dok - 1))))+'/'+LTRIM(RTRIM(CONVERT(CHAR,YEAR(x.datum_dok - 1))))END)
				End
	ELSE ''
	END
END  as razdoblje_regist_ispis

From (SELECT a.*, c.obnaleto, 
			b.ddv_id as pogodba_ddv_id, 
			CASE WHEN b.kategorija1 = '102' AND a.neto = 0 --COVID19
				THEN 'Kod zakašnjenja plaćanja za period u kojem se zaračunava smanjena naknada zbog COVID 19, ne zaračunavamo zateznu kamatu. Za plaćanja iza tog razdoblja '
					+ CASE WHEN left(e.opis,3) = 'ZAK' THEN 'zakonska' else 'ugovorna' end +' zatezna kamata biti će zaračunata.'
				ELSE 'Kod zakašnjenja plaćanja zaračunavamo '+CASE WHEN left(e.opis,3) = 'ZAK' THEN 'zakonsku' else 'ugovornu' end +' zateznu kamatu.'
			END as obresti_opis, 
			f.direktor,
			g.saldo As g_saldo, g.kredit as g_kredit, g.id_val as g_id_val, d.tip_leas,
			DATEADD(mm,12/c.obnaleto,a.datum_dok)-1 as datum_do,
			SUBSTRING(CONVERT(VARCHAR(25),DATEADD(mm, DATEDIFF(mm, 0, a.datum_dok), 0),103),4,7) +CASE WHEN (12/c.obnaleto)<> 1 THEN ' do '+ SUBSTRING(CONVERT(VARCHAR(25),DATEADD(mm,12/c.obnaleto,DATEADD(mm, DATEDIFF(mm, 0, a.datum_dok), 0)-1),103),4,7) ELSE '' END as razdoblje_OL_LOBR,
			dbo.gfn_TransformDDV_ID_HR(a.ddv_id, h.ddv_date) as Fis_BrRac,
			CASE WHEN d.tip_leas = 'OL' AND v.sif_terj = 'LOBR' THEN 1 ELSE 0 END AS OL_LOBR,
			CASE WHEN d.tip_leas = 'F1' AND v.sif_terj = 'LOBR' THEN 1 ELSE 0 END AS F1_LOBR,
			CASE WHEN h.ddv_date < '20130101' THEN 0 ELSE 1 END As print_fiskal,
			CASE WHEN v.sif_terj <> 'LOBR' THEN 1 ELSE 0 END AS NOT_LOBR,
			CASE WHEN a.datum_dok < ISNULL(i.val, '20130701') THEN 1 ELSE 0 END as print_r1,
			CASE WHEN a.datum_dok > ISNULL(j.val, '20130630') THEN 1 ELSE 0 END as print_PIB,
			ltrim(rtrim(a.id_pog))+ltrim(rtrim(a.id_kupca))+ltrim(rtrim(f.ext_id))+CASE WHEN v.sif_terj = 'SFIN' THEN '1325' WHEN v.sif_terj = 'LOBR' THEN '1321' ELSE '132' END as id_barcode,
			b.naziv_tuje, ks.klavzula as klavzula_sifrant,
			CAST(CASE WHEN b.naziv_tuje is null or b.naziv_tuje = '' THEN 0 ELSE 1 END As Int) As ispisi_naziv_tuje,
			CASE WHEN v.sif_terj = 'SFIN' and d.tip_leas = 'OL' THEN 'NAKNADA ZA KORIŠTENJE SREDSTVA OD '+CONVERT(VARCHAR(25),inter_obr.dat_od,104)+' DO '+CONVERT(VARCHAR(25),DATEADD(dd,-1,inter_obr.dat_do),104)
				WHEN v.sif_terj = 'SFIN' and (d.tip_leas = 'F1' or d.tip_leas = 'FF') THEN 'INTERKALARNE KAMATE ZA RAZDOBLJE OD '+CONVERT(VARCHAR(25),inter_obr.dat_od,104) +' DO '+CONVERT(VARCHAR(25),DATEADD(dd,-1,inter_obr.dat_do),104)
				WHEN v.sif_terj = 'NAPO' and d.tip_leas = 'OL' THEN 'NAKNADA ZA KORIŠTENJE SREDSTVA OD '+CONVERT(VARCHAR(25),dbo.gfn_GetFirstDayOfMonth(a.datum_dok),104) +' DO '+CONVERT(VARCHAR(25),dbo.gfn_GetLastDayOfMonth(a.datum_dok),104)
				WHEN v.sif_terj = 'NAPO' and (d.tip_leas = 'F1' or d.tip_leas = 'FF') THEN 'INTERKALARNA KAMATA OD '+CONVERT(VARCHAR(25),dbo.gfn_GetFirstDayOfMonth(a.datum_dok),104) +' DO '+CONVERT(VARCHAR(25),dbo.gfn_GetLastDayOfMonth(a.datum_dok),104)
				WHEN v.sif_terj = 'POLO' and d.tip_leas = 'OL' THEN 'POSEBNA NAJAMNINA'
				ELSE v.naziv
			END AS NAZIV_TERJ1,
			v.sif_terj, 
			CASE WHEN v.sif_terj = 'SFIN' and a.dav_vred = 0 THEN 'Oslobođeno:'
				 WHEN v.sif_terj = 'SFIN' and a.dav_vred > 0 THEN 'Porez na dodanu vrijednost: '+cast(a.dav_vred as varchar(10))+'%'
				 WHEN v.sif_terj <> 'SFIN' and a.dav_vred > 0 THEN 'Porez na dodanu vrijednost: '+cast(a.dav_vred as varchar(10))+'%'
				 ELSE ''
			END AS NAZIV_DAVEK1,
			CASE WHEN v.sif_terj = 'SFIN' and a.dav_vred = 0 THEN a.rac_out_brez_davka
				 WHEN v.sif_terj = 'SFIN' and a.dav_vred > 0 THEN a.sdavek
				 WHEN v.sif_terj <> 'SFIN' and a.dav_vred > 0 THEN a.sdavek
			END AS DAVEK1, ISNULL(kon.opis,'') as Print_VlogaTXT,
			CASE WHEN a.srobresti > 0 THEN '1' 
				ELSE '0' END as print_PPMV,
CASE WHEN v.sif_terj = 'LOBR' THEN (Select MAX(datum_dok) From dbo.planp Where id_cont = a.id_cont And id_terj = a.id_terj And datum_dok < a.datum_dok) ELSE NULL END AS rata_prije, 
CASE WHEN v.sif_terj = 'LOBR' THEN (Select MIN(datum_dok) From dbo.planp Where id_cont = a.id_cont And id_terj = a.id_terj And datum_dok > a.datum_dok) ELSE NULL END AS rata_poslije,
			CASE WHEN v.sif_terj = 'LOBR' THEN 
				CASE WHEN b.kategorija1 = '102' AND a.neto = 0 AND dok_HR.opis1 is not null THEN dok_HR.opis1 
					ELSE CASE WHEN d.tip_leas = 'F1' THEN 'Kamata za razdoblje $[0]. $[1].'
							ELSE RTRIM(a.naziv_terj) + ' za razdoblje $[0]. $[1].' END --d.tip_leas <> 'F1'
				END
			  ELSE NULL END  AS razdoblje_osnova,
			CASE WHEN d.tip_leas = 'OL' AND v.sif_terj = 'LOBR' and a.SREGIST > 0 THEN 'Dodatne usluge za razdoblje $[0]. $[1].' ELSE NULL END AS razdoblje_regist,
			CASE WHEN v.sif_terj = 'LOBR' AND (cs.val = 'Anticipative' AND dok.id_dokum IS NULL) OR (cs.val = 'Decursive' AND dok.id_dokum IS NOT NULL) THEN 'Anticipative'
					WHEN v.sif_terj = 'LOBR' AND (cs.val = 'Decursive' AND dok.id_dokum IS NULL) OR (cs.val = 'Anticipative' AND dok.id_dokum IS NOT NULL) THEN 'Decursive' ELSE '' END AS rata_type,
			CASE WHEN v.sif_terj = 'SFIN' OR v.sif_terj = 'NAPO' OR v.sif_terj = 'LOBR' THEN 1 ELSE 0 END AS PRINT_ODLOMAK2,
			a.dolg - CASE WHEN a.dat_zap > GETDATE() THEN 0.00 ELSE a.debit END AS dolg_dat_zap, 
			CASE WHEN (a.dolg - CASE WHEN a.dat_zap > GETDATE() THEN 0.00 ELSE a.debit END) > dbo.gfn_xchange(a.id_tec, .10, '000', GETDATE()) THEN 1 ELSE 0 END AS PRINT_DOLG
			, CASE WHEN v.sif_terj = 'LOBR' AND ISNULL(ltrim(rtrim(dok.kategorija1)), '') = @DN_kategorija1 AND ISNULL(ltrim(rtrim(dok.ext_id)), '') = a.st_dok THEN dok.opis1 ELSE '' END AS razdoblje_DN_dok
			, datIzv.dat_izpisk as dat_izpisk,
			dbo.pfn_gmc_hub3_BarCode(a.id_kupca, 'HRK', a.sdebit, 'HR01', RTRIM(b.sklic), 'OTHR', LTRIM(RTRIM(CASE WHEN v.sif_terj = 'SFIN' and d.tip_leas = 'OL' THEN 'NAKNADA ZA KORIŠTENJE SREDSTVA OD '+CONVERT(VARCHAR(25),inter_obr.dat_od,104)+' DO '+CONVERT(VARCHAR(25),DATEADD(dd,-1,inter_obr.dat_do),104)
				WHEN v.sif_terj = 'SFIN' and (d.tip_leas = 'F1' or d.tip_leas = 'FF') THEN 'INTERKALARNE KAMATE ZA RAZDOBLJE OD '+CONVERT(VARCHAR(25),inter_obr.dat_od,104) +' DO '+CONVERT(VARCHAR(25),DATEADD(dd,-1,inter_obr.dat_do),104)
				WHEN v.sif_terj = 'NAPO' and d.tip_leas = 'OL' THEN 'NAKNADA ZA KORIŠTENJE SREDSTVA OD '+CONVERT(VARCHAR(25),dbo.gfn_GetFirstDayOfMonth(a.datum_dok),104) +' DO '+CONVERT(VARCHAR(25),dbo.gfn_GetLastDayOfMonth(a.datum_dok),104)
				WHEN v.sif_terj = 'NAPO' and (d.tip_leas = 'F1' or d.tip_leas = 'FF') THEN 'INTERKALARNA KAMATA OD '+CONVERT(VARCHAR(25),dbo.gfn_GetFirstDayOfMonth(a.datum_dok),104) +' DO '+CONVERT(VARCHAR(25),dbo.gfn_GetLastDayOfMonth(a.datum_dok),104)
				WHEN v.sif_terj = 'POLO' and d.tip_leas = 'OL' THEN 'POSEBNA NAJAMNINA'
				ELSE v.naziv
			END))) as barkod_value,
			h.ddv_date,
		CASE WHEN ISNULL(zr.st_sas,'') = '' THEN 0 ELSE 1 END AS print_stSas,
		ke.val_string as br_jn,
		zr.st_sas as zr_st_sas, zr.reg_stev as zr_reg_stev
		
		FROM dbo.pfn_gmc_Print_InvoiceForInstallments(getdate()) a
		INNER JOIN dbo.rac_out h on a.ddv_id = h.ddv_id
		INNER JOIN dbo.pogodba b on a.id_cont = b.id_cont
		LEFT JOIN dbo.obdobja c on b.id_obd = c.id_obd
LEFT JOIN (Select nacin_leas, dbo.gfn_Nacin_leas_HR(nacin_leas) as tip_leas	From dbo.nacini_l)d on b.nacin_leas = d.nacin_leas
		LEFT JOIN dbo.obresti e on b.id_obrv = e.id_obr
		LEFT JOIN dbo.partner f on b.id_kupca = f.id_kupca
		LEFT JOIN dbo.planp g on a.id_cont = g.id_cont AND a.id_terj = g.id_terj AND g.saldo <> 0 AND g.id_terj = '12'
		LEFT JOIN dbo.vrst_ter v on a.id_terj = v.id_terj
		LEFT JOIN dbo.gen_interkalarne_obr_child inter_obr ON a.st_dok = inter_obr.st_dok
		LEFT JOIN dbo.klavzule_sifr ks ON ks.id_klavzule = h.id_klavzule
		left join dbo.custom_settings i on i.code='Nova.Reports.Print_R1'
		left join dbo.custom_settings j on j.code = 'Nova.Reports.Print_PIB'
		LEFT JOIN dbo.zap_reg zr ON a.id_cont = zr.id_cont
		LEFT JOIN (SELECT id_entiteta, val_string FROM kategorije_entiteta WHERE id_kategorije_tip = 8) ke on b.id_cont = ke.id_entiteta
LEFT JOIN (SELECT a.id_kupca, a.opis
	FROM P_KONTAKT a
INNER JOIN (Select MAX(id_p_kontakt) as id, id_kupca From dbo.P_KONTAKT Where ID_VLOGA = 'TX' AND NEAKTIVEN = 0 Group by id_kupca) b on a.id_p_kontakt = b.id
					WHERE ID_VLOGA = 'TX' AND NEAKTIVEN = 0) kon on a.id_kupca = kon.id_kupca
		Left Join dbo.custom_settings cs on cs.code = 'BOOKING_CRO_INT_ACCR_TYPE'
		Left Join dbo.custom_settings cs1 on cs1.code = 'BOOKING_CRO_ACC_ALTMOD_DOK'
		Left Join dbo.dokument dok on a.id_cont = dok.id_cont and CHARINDEX(dok.id_obl_zav, cs1.val) > 0
OUTER APPLY (select max(dat_izpisk) as dat_izpisk from dbo.placila where id_app_pren is not null ) datIzv
OUTER APPLY (select top 1 opis1 from dbo.dokument where id_obl_zav = 'HR' and status_akt = 'A' and id_cont = a.id_cont order by id_dokum desc) dok_HR
		WHERE a.ddv_id = @id
) x 