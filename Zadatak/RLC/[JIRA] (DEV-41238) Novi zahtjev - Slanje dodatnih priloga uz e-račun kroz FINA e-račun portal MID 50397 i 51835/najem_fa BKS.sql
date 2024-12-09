-- 17.01.2022 g_tomislav MID 48089 - promjena naziva rate za OL u obrok
-- 08.09.2022 g_branisl MID 49485 - popravak vrijednosti indeksa
-- 06.03.2023 g_tomislav MID 49835 - dorada logike print_rev_ind (za dekurzivnu naplatu mjesečne rate ne ide)
declare @datum DATETIME
set @datum = GETDATE()


SELECT rep_ind.id_cont, rep_ind.datum, rep_ind.nobrok, rep_ind.sobrok, p.id_pog, rep_ind.NDATUM, rep_ind.NINDEKS
INTO #REP_IND
FROM dbo.rep_ind
INNER JOIN dbo.pogodba p on rep_ind.id_cont = p.id_cont
WHERE id_rep_ind in (Select max(id_rep_ind) as id_rep_ind From rep_ind where izpisan = 0 group by id_cont)
	AND rep_ind.id_cont in (Select id_cont From dbo.rac_out where ddv_id =@id)
	
Select x.*,
CASE WHEN x.sif_terj <> 'LOBR' AND x.id_terj <> '36'
	THEN RTRIM(x.naziv_terj)
	ELSE
	Case when x.rata_type = 'Anticipative' Then 
				CASE 
					WHEN rata_poslije IS NOT NULL THEN 	
						REPLACE(REPLACE(razdoblje_osnova,'$[0]', CONVERT(VARCHAR(10), x.datum_dok, 104)), '$[1]', CONVERT(VARCHAR(10), x.rata_poslije-1, 104))
					WHEN x.obnaleto = 12 OR rata_poslije IS NULL THEN 
						REPLACE(REPLACE(razdoblje_osnova,'$[0]', CONVERT(VARCHAR(10), x.datum_dok, 104)),'$[1]', CONVERT(VARCHAR(10), DATEADD(mm,12/x.obnaleto,x.datum_dok)-1, 104))
				END
	     WHEN x.rata_type = 'Decursive' THEN 
				CASE 
					when x.obnaleto = 12 then REPLACE(REPLACE(razdoblje_osnova,'$[0]', CONVERT(VARCHAR(10), dbo.gfn_GetFirstDayOfMonth(x.datum_dok), 104)),'$[1]', CONVERT(VARCHAR(10), dbo.gfn_GetLastDayOfMonth(x.datum_dok), 104))
					WHEN x.rata_prije IS NOT NULL THEN
						REPLACE(REPLACE(razdoblje_osnova,'$[0]', CONVERT(VARCHAR(10), x.rata_prije + 1, 104)),'$[1]', CONVERT(VARCHAR(10), x.datum_dok, 104))
					WHEN rata_prije IS NULL THEN
						REPLACE(REPLACE(razdoblje_osnova,'$[0]', CONVERT(VARCHAR(10), DATEADD(mm,-12/x.obnaleto,x.datum_dok), 104)),'$[1]', CONVERT(VARCHAR(10), x.datum_dok, 104))
				END
	End 
END  as razdoblje,
CASE WHEN x.id_obdrep = '002' AND convert(varchar(5),x.rata_poslije,104) = '01.01' THEN 'od '+CONVERT(VARCHAR(10), x.rata_poslije, 104)+'. do 30.06.'+CAST(YEAR(x.rata_poslije) as VARCHAR(4))+'.'
	 WHEN x.id_obdrep = '002' AND convert(varchar(5),x.rata_poslije,104) = '01.04' THEN 'od '+CONVERT(VARCHAR(10), x.rata_poslije, 104)+'. do 30.09.'+CAST(YEAR(x.rata_poslije) as VARCHAR(4))+'.'
	 WHEN x.id_obdrep = '002' AND convert(varchar(5),x.rata_poslije,104) = '01.07' THEN 'od '+CONVERT(VARCHAR(10), x.rata_poslije, 104)+'. do 31.12.'+CAST(YEAR(x.rata_poslije) as VARCHAR(4))+'.'
	 WHEN x.id_obdrep = '002' AND convert(varchar(5),x.rata_poslije,104) = '01.10' THEN 'od '+CONVERT(VARCHAR(10), x.rata_poslije, 104)+'. do 31.03.'+CAST(YEAR(x.rata_poslije)+1 as VARCHAR(4))+'.' 
	 WHEN x.id_obdrep = '004' AND convert(varchar(5),x.rata_poslije,104) = '01.01' THEN 'od '+CONVERT(VARCHAR(10), x.rata_poslije, 104)+'. do 31.03.'+CAST(YEAR(x.rata_poslije) as VARCHAR(4))+'.'
	 WHEN x.id_obdrep = '004' AND convert(varchar(5),x.rata_poslije,104) = '01.04' THEN 'od '+CONVERT(VARCHAR(10), x.rata_poslije, 104)+'. do 30.06.'+CAST(YEAR(x.rata_poslije) as VARCHAR(4))+'.'
	 WHEN x.id_obdrep = '004' AND convert(varchar(5),x.rata_poslije,104) = '01.07' THEN 'od '+CONVERT(VARCHAR(10), x.rata_poslije, 104)+'. do 30.09.'+CAST(YEAR(x.rata_poslije) as VARCHAR(4))+'.'
	 WHEN x.id_obdrep = '004' AND convert(varchar(5),x.rata_poslije,104) = '01.10' THEN 'od '+CONVERT(VARCHAR(10), x.rata_poslije, 104)+'. do 31.12.'+CAST(YEAR(x.rata_poslije) as VARCHAR(4))+'.'
 END as razd_indeks

From (	SELECT a.*
	, b.naziv_tuje, c.obnaleto
			, dbo.gfn_Nacin_leas_HR(a.nacin_leas) as tip_leas
			, DATEADD(mm, 12/c.obnaleto, a.datum_dok) as datum_do
			, dbo.gfn_TransformDDV_ID_HR(a.ddv_id, h.ddv_date) as Fis_BrRac
			, dbo.pfn_gmc_hub3_BarCode(a.id_kupca, n.dom_valuta, a.sdebit, 'HR01', RTRIM(a.sklic), 'OTHR', 'Plaćanje računa '+LTRIM(RTRIM(a.ddv_id))) as barkod_value
			, CASE WHEN dbo.gfn_Nacin_leas_HR(a.nacin_leas) = 'OL' AND v.sif_terj = 'LOBR' THEN 1 ELSE 0 END AS OL_LOBR,
			CASE WHEN charindex(dbo.gfn_Nacin_leas_HR(a.nacin_leas),'F1,ZP') != 0 AND v.sif_terj = 'LOBR' THEN 1 ELSE 0 END AS F1_LOBR,
			CASE WHEN v.sif_terj <> 'LOBR' THEN 1 ELSE 0 END AS NOT_LOBR
			, v.sif_terj
			, i.naziv_tuj2 as naziv_tecaja2
			, REPLACE(REPLACE(a.tip, CHAR(10), ''), CHAR(13), '') AS tip_procisceni
			, RTRIM(CONVERT(VARCHAR(50), a.ra_dat_vnosa,104) + '. ' + CONVERT(VARCHAR(50), a.ra_dat_vnosa,108)) as Dat_Izdavanja
			, CASE WHEN LEN(LTRIM(RTRIM(a.dav_stev)))=11 THEN a.dav_stev ELSE '' END as dav_stev_11
			, CASE WHEN( v.sif_terj = 'LOBR' OR v.id_terj = '36') AND (cs.val = 'Anticipative' AND dok.id_dokum IS NULL) OR (cs.val = 'Decursive' AND dok.id_dokum IS NOT NULL) THEN 'Anticipative'
				 WHEN (v.sif_terj = 'LOBR' OR v.id_terj = '36') AND (cs.val = 'Decursive' AND dok.id_dokum IS NULL) OR (cs.val = 'Anticipative' AND dok.id_dokum IS NOT NULL) THEN 'Decursive' 
				 ELSE '' END AS rata_type
, CASE WHEN v.sif_terj = 'LOBR' or v.id_terj = '36' THEN (Select MAX(datum_dok) From dbo.planp Where id_cont = a.id_cont And id_terj = a.id_terj And datum_dok < a.datum_dok) ELSE NULL END AS rata_prije
, CASE WHEN v.sif_terj = 'LOBR' or v.id_terj = '36' THEN (Select MIN(datum_dok) From dbo.planp Where id_cont = a.id_cont And id_terj = a.id_terj And datum_dok > a.datum_dok) ELSE NULL END AS rata_poslije
			, 
			CASE WHEN a.obresti > 0 and (a.neto+a.marza+a.robresti+a.regist) = 0 AND dbo.gfn_Nacin_leas_HR(a.nacin_leas) = 'F1' THEN 'Umanjena rata'
				WHEN a.obresti > 0 and (a.neto+a.marza+a.robresti+a.regist) = 0 AND dbo.gfn_Nacin_leas_HR(a.nacin_leas) <> 'F1' THEN 'Umanjen obrok'
				WHEN v.sif_terj = 'LOBR' AND dbo.gfn_Nacin_leas_HR(a.nacin_leas) = 'F1' THEN 'RATA'
				WHEN v.sif_terj = 'LOBR' AND dbo.gfn_Nacin_leas_HR(a.nacin_leas) <> 'F1' THEN 'OBROK'
				WHEN v.id_terj = 36 THEN 'Polica osiguranja'
				ELSE NULL END + ' za razdoblje $[0]. - $[1].' AS razdoblje_osnova,
			CASE WHEN a.obresti > 0 and (a.neto+a.marza+a.robresti+a.regist) = 0 THEN ' uslijed posebnih okolnosti (Covid -19) i u skladu sa Aneksom Ugovora o leasingu' ELSE '' END as txt_rata,
		dbo.gfn_Xchange('000', a.dolg, a.id_tec, a.dat_prip) as ln_dolgkn,
		r.id_rtip, r.naziv as naz_rev_ind, 
		rind.ndatum as dat_ind, rind.nindeks as vr_ind,
		CASE WHEN IsNULL(rind.id_cont,'') <> '' THEN 1 ELSE 0 END print_RInd,
		COALESCE(rind.nobrok, CAST(0.00 AS DECIMAL(18,2))) as nova_rata,
		COALESCE(rind.sobrok, CAST(0.00 AS DECIMAL(18,2))) as stara_rata,
		IsNULL(rind.datum,'') as datum_reprograma,
		r.id_obdrep, b.ID_RIND_STRATEGIJE,
		CASE WHEN b.ID_RIND_STRATEGIJE = 1 AND ISNULL(rind.id_cont,'') <> '' and 1 = (case when dok.id_dokum IS NOT NULL and c.obnaleto = 12 then 0 else 1 end) THEN 1 ELSE 0 END as print_rev_ind, -- za dekurzivnu naplatu mjesečne rate ne ide
		CASE WHEN dbo.gfn_Nacin_leas_HR(a.nacin_leas) = 'OL' THEN 'Plan plaćanja obroka' ELSE 'Otplatna tablica' END AS txt_planp,
		i.naziv as naziv_tecaja,
		CASE WHEN b.ID_RIND_STRATEGIJE = 1 AND ISNULL(rind.id_cont,'') <> '' AND dbo.gfn_Nacin_leas_HR(a.nacin_leas) = 'F1' AND p.vr_osebe= 'FO' THEN 1 ELSE 0 END as print_planp,
		CASE WHEN r.id_obdrep = '004' THEN '3-mjesečnog EURIBOR-a'
			WHEN r.id_obdrep = '002' THEN '6-mjesečnog EURIBOR-a'
			ELSE '' END AS txt_rev_indeks,
		CASE WHEN v.sif_terj = 'SFIN' THEN ' za razdoblje ' + CONVERT(VARCHAR(25),inter_obr.dat_od,104)+' - '+CONVERT(VARCHAR(25),DATEADD(dd,-1,inter_obr.dat_do),104) ELSE '' END AS inter_obr_obd
		FROM dbo.pfn_gmc_Print_InvoiceForInstallments(@datum) a
		INNER JOIN dbo.rac_out h on a.ddv_id = h.ddv_id
		INNER JOIN dbo.pogodba b on a.id_cont = b.id_cont
		INNER JOIN dbo.partner p on a.id_kupca = p.id_kupca
		LEFT JOIN dbo.obdobja c on b.id_obd = c.id_obd
		LEFT JOIN dbo.vrst_ter v on a.id_terj = v.id_terj
		LEFT JOIN dbo.tecajnic i ON a.id_tec = i.id_tec
		LEFT JOIN dbo.custom_settings cs ON cs.code = 'BOOKING_CRO_INT_ACCR_TYPE'
		LEFT JOIN dbo.custom_settings cs1 ON cs1.code = 'BOOKING_CRO_ACC_ALTMOD_DOK'
		LEFT JOIN dbo.dokument dok ON a.id_cont = dok.id_cont AND CHARINDEX(dok.id_obl_zav, cs1.val) > 0
		LEFT JOIN dbo.nastavit n ON 1 = 1
		LEFT JOIN dbo.rtip r on b.id_rtip = r.id_rtip
		LEFT JOIN dbo.gen_interkalarne_obr_child inter_obr ON a.st_dok = inter_obr.st_dok
		LEFT JOIN #REP_IND rind on a.id_cont = rind.id_cont

		WHERE a.ddv_id = @id
	) x

DROP TABLE #REP_IND
