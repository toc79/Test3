declare @id varchar(100) = '20230028407'
set statistics time on
DECLARE @datum datetime, @tip_leas char(2), @id_cont int, @prvi_ugovor int, @id_kupca varchar(8)
SET @datum = getdate()

/*declare @id varchar(100)
set @id = '20240001031'*/

select @tip_leas = dbo.gfn_Nacin_leas_HR(b.nacin_leas), @id_cont = a.ID_CONT, @id_kupca = a.id_kupca
	From dbo.rac_out a 
inner join dbo.pogodba b on a.id_cont = b.id_cont
where a.ddv_id = @id

set @prvi_ugovor = (select count(*) From dbo.pogodba where ID_KUPCA = @id_kupca)

SELECT a.*, c.obnaleto, 
	(a.SNETO+a.SMARZA+a.SOBRESTI)*h.davek/100 as znesek_net_pdv,
	a.SREGIST*h.davek/100 as sregist_pdv,
	b.ddv_id as pogodba_ddv_id, 
	CASE WHEN left(e.opis,3) = 'ZAK' THEN 'zakonsku' else 'ugovornu' end as obresti_opis, f.direktor,
	g.saldo As g_saldo, g.kredit as g_kredit, g.id_val as g_id_val, @tip_leas AS tip_leas,
	v.sif_terj,
	dbo.pfn_gmc_hub3_BarCode(a.id_kupca, n.dom_valuta, a.sdebit, 'HR01', RTRIM(b.sklic), 'OTHR', CASE WHEN b.nacin_leas IN ('NF', 'NO') THEN 'Zakup/najam '+CASE WHEN v.sif_terj = 'SFIN' THEN CONVERT(VARCHAR(25),ISNULL(inter_obr.dat_od,''),104) ELSE CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(a.datum_dok)-1),a.datum_dok),104) END+'.-'+CASE WHEN v.sif_terj = 'SFIN' THEN CONVERT(VARCHAR(25),ISNULL(inter_obr.dat_do,''),104) ELSE CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,a.datum_dok))),DATEADD(mm,12/c.obnaleto,a.datum_dok)),104) END+'.)' ELSE LTRIM(RTRIM(ra.opisdok)) END) as barkod_value,
	CASE WHEN @tip_leas = 'OL' AND v.sif_terj = 'LOBR' THEN 1 ELSE 0 END AS OL_LOBR,
	CASE WHEN @tip_leas = 'OZ' AND v.sif_terj = 'LOBR' THEN 1 ELSE 0 END AS OZ_LOBR,
	CASE WHEN @tip_leas = 'F1' AND v.sif_terj = 'LOBR' THEN 1 ELSE 0 END AS F1_LOBR,
	CASE WHEN @tip_leas = 'ZP' AND v.sif_terj = 'LOBR' THEN 1 ELSE 0 END AS ZP_LOBR,
	CASE 
		 WHEN @tip_leas = 'OL' AND v.sif_terj = 'LOBR' THEN 'Obrok'
		 WHEN @tip_leas = 'F1' AND v.sif_terj = 'LOBR' THEN 'Glavnica'
		 WHEN @tip_leas = 'OL' AND v.sif_terj = 'SFIN' THEN 'Naknada za korištena sredstava'
		 WHEN @tip_leas = 'F1' AND v.sif_terj = 'SFIN' THEN 'Interkalarna kamata'
		 WHEN @tip_leas = 'F1' AND v.sif_terj = 'POLO' THEN v.naziv
		 WHEN @tip_leas = 'OL' AND v.sif_terj = 'POLO' THEN 'Posebna najamnina'
		 ELSE v.naziv
	END AS NAZ_TERJ1,
	CASE WHEN opr.se_regis= '*' THEN zap.opis ELSE nzap.opis END AS ZAP_OPIS, 
	ISNULL(zap.reg_stev,'') as zap_reg_stev, ISNULL(zap.st_sas,'') as zap_st_sas,
	CASE WHEN v.sif_terj = 'SFIN' THEN CONVERT(VARCHAR(25),ISNULL(inter_obr.dat_od,''),104) 
		ELSE case when ALTMOD_DOK.id_cont is null then CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(a.datum_dok)-1),a.datum_dok),104) 
			else convert(varchar(25), dbo.gfn_GetFirstDayOfMonth(DATEADD(mm, -12/c.obnaleto + 1, a.datum_dok)), 104) -- Dekurzivna naplata
			end
		END AS Datum_od,
	CASE WHEN v.sif_terj = 'SFIN' THEN CONVERT(VARCHAR(25),ISNULL(inter_obr.dat_do,''),104) 
		ELSE case when ALTMOD_DOK.id_cont is null then CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,a.datum_dok))),DATEADD(mm,12/c.obnaleto,a.datum_dok)),104) 
			else convert(varchar(25), a.datum_dok, 104) -- Dekurzivna naplata
			end
		END AS Datum_do,
	CASE WHEN @tip_leas = 'OL' AND v.sif_terj = 'POLO' THEN a.SNETO+a.SREGIST+a.SMARZA+a.SOBRESTI ELSE a.SNETO+a.SREGIST+a.SMARZA+a.SOBRESTI+a.SROBRESTI END AS NOT_LOBR_NETO,
	CASE WHEN @tip_leas = 'OL' AND v.sif_terj = 'POLO' THEN a.SNETO+a.SREGIST+a.SMARZA+a.SOBRESTI+a.SDAVEK ELSE a.SNETO+a.SREGIST+a.SMARZA+a.SOBRESTI+a.SROBRESTI+a.SDAVEK END AS NOT_LOBR_NETO1,
	CASE WHEN @tip_leas = 'OL' AND v.sif_terj = 'POLO' THEN a.SDEBIT-a.SROBRESTI ELSE a.SDEBIT END AS NOT_LOBR_DEBIT,
	CASE WHEN inter_obr.dat_od IS NULL OR inter_obr.dat_do IS NULL THEN 1 ELSE 0 END AS SFIN_NA_PLANP,
	CASE WHEN v.sif_terj <> 'LOBR' THEN 1 ELSE 0 END AS NOT_LOBR,
	CASE WHEN LEN(RTRIM(a.dav_stev)) = 11 THEN 0 ELSE 1 END AS OIB_NOT_OK,
	CASE WHEN a.vr_osebe = 'SP' AND LEN(a.stev_reg)>0 THEN 1 ELSE 0 END AS PRINT_MBO,
	CASE WHEN a.vr_osebe NOT IN ('SP','FO') AND LEN(a.emso)>0 AND LEN(a.emso)<13 THEN 1 ELSE 0 END AS PRINT_MB,
	CASE WHEN a.dat_zap <= @datum THEN CAST(a.dolg-a.debit AS DECIMAL(18,2)) ELSE a.dolg END AS PRINT_DOLG,
	CASE WHEN kon.id_kupca_k IS NOT NULL THEN 1 ELSE 0 END AS Print_Vloga,
	ISNULL(konp.opis,'') as Print_DP, dok.opis1 as Print_DU,
	COALESCE(grp.value, '') as Print_izdao,
	COALESCE(grPrim.value, gr.value, '') AS Print_veri,
	CASE WHEN a.id_klavzule is null or a.id_klavzule = '' THEN 0 ELSE 1 END AS PRINT_KLAVZULA,
	CASE WHEN a.datum_dok < '20130101' THEN 0 ELSE 1 END AS PRINT_DDV_HR,
	dbo.gfn_transformDDV_ID_HR(a.ddv_id,a.datum_dok) as Fis_BrRac,
	RTRIM(CONVERT(varchar(50), a.ra_dat_vnosa,104) + '. '+ CONVERT(VARCHAR(50), a.ra_dat_vnosa,108)) AS Dat_Izdavanja,
	CASE WHEN a.datum_dok < ISNULL(cust.val, '20500101') THEN 1 ELSE 0 END AS print_r1,
	CASE WHEN g.saldo=0 AND (v.sif_terj='MSTR' or v.sif_terj='POLO') THEN 1 ELSE 0 END AS PRINT_PODMIREN,
	CASE WHEN a.vr_osebe = 'FO' or a.vr_osebe = 'F1' THEN 1 ELSE 0 END as je_FO,
	CASE WHEN (month(a.datum_dok) = 3 AND year(a.datum_dok) = 2019) AND v.sif_terj = 'LOBR' AND a.nacin_leas NOT IN ('NO','NF','PF','PO') AND f.vr_osebe NOT IN ('F1','FO') THEN 1 ELSE 0 END as PRINT_POSEBAN_TEKST,
	CASE WHEN a.id_tec IN ('016', '017') THEN 1 ELSE 0 END AS hnb_txt,
	--potpis skrbnika za welcome letter
	CASE WHEN f.skrbnik_1 IS NOT NULL THEN skrbnik.naz_kr_kup ELSE ' ' END AS Skrbnik,
	case when @prvi_ugovor = 1 THEN 1 ELSE 0 END AS Prvi_ugovor,
	CASE WHEN g.id_terj = '21' and g.zap_obr = 1 THEN 1 ELSE 0 END AS Prva_rata,
	CASE WHEN b.nacin_leas = 'TP' THEN 0 ELSE 1 END AS Preuzeti_ugovor
	, datIzv.dat_izpisk as dat_izpisk
	, case when a.SROBRESTI != 0 and v.sif_terj = 'POLO' and @tip_leas = 'OL' then 1 else 0 end as PRINT_PPMV_POLO_OL
	, SDEBIT_EUR_MIG.res_print as SDEBIT_RES_PRINT
	, SDEBIT_EUR_MIG.res_amount as SDEBIT_RES_AMOUNT
	, SDEBIT_EUR_MIG.res_exch as SDEBIT_RES_EXCH
	, SDEBIT_EUR_MIG.res_id_val as SDEBIT_RES_ID_VAL
	, PRINT_DOLG_EUR_MIG.res_print as PRINT_DOLG_RES_PRINT
	, PRINT_DOLG_EUR_MIG.res_amount as PRINT_DOLG_RES_AMOUNT
	, PRINT_DOLG_EUR_MIG.res_exch as PRINT_DOLG_RES_EXCH
	, PRINT_DOLG_EUR_MIG.res_id_val as PRINT_DOLG_RES_ID_VAL
	, NOT_LOBR_DEBIT_EUR_MIG.res_print as NOT_LOBR_DEBIT_RES_PRINT
	, NOT_LOBR_DEBIT_EUR_MIG.res_amount as NOT_LOBR_DEBIT_RES_AMOUNT
	, NOT_LOBR_DEBIT_EUR_MIG.res_exch as NOT_LOBR_DEBIT_RES_EXCH
	, NOT_LOBR_DEBIT_EUR_MIG.res_id_val as NOT_LOBR_DEBIT_RES_ID_VAL
    , dok_SE.ID_OBL_ZAV
	, dok_SE.STEVILKA
    , trr.trr
	, case when rep_ind.id_rep_ind is not null and f.ident_stevilka is not null and f.ident_stevilka <> '' and v.sif_terj = 'LOBR' then 1 else 0 end as print_rep_ind		 
FROM dbo.pfn_gmc_Print_InvoiceForInstallments(@datum) a
INNER JOIN dbo.pogodba b on a.id_cont = b.id_cont
LEFT JOIN dbo.obdobja c on b.id_obd = c.id_obd
LEFT JOIN dbo.gen_interkalarne_obr_child inter_obr ON a.st_dok = inter_obr.st_dok
LEFT JOIN dbo.obresti e on b.id_obrv = e.id_obr
LEFT JOIN dbo.partner f on b.id_kupca = f.id_kupca
LEFT JOIN dbo.planp g on a.id_cont = g.id_cont AND a.st_dok = g.st_dok
LEFT JOIN dbo.vrst_ter v on a.id_terj = v.id_terj
--correction in case of multiple zapisnika MR 40630 LEFT JOIN dbo.zap_reg zap on a.id_cont = zap.id_cont
--LEFT JOIN dbo.zap_ner nzap on a.id_cont = nzap.id_cont
outer apply (SELECT TOP 1 opis, reg_stev, st_sas FROM dbo.zap_reg WHERE zap_reg.id_cont = a.id_cont) zap
outer apply (SELECT TOP 1 opis FROM dbo.zap_ner WHERE zap_ner.id_cont = a.id_cont) nzap
LEFT JOIN dbo.vrst_opr opr on b.id_vrste = opr.id_vrste
INNER JOIN dbo.dav_stop h ON a.id_dav_st = h.id_dav_st
LEFT JOIN (SELECT a.id_cont, a.id_dokum, a.opis1
		FROM dbo.dokument a
		INNER JOIN (SELECT MAX(id_dokum) AS id FROM dbo.dokument /*with (Index(IX_DOKUMENT_ic), index(IX_DOKUMENT_IOZ))*/ WHERE id_obl_zav = 'DU' GROUP BY id_cont) b ON a.id_dokum = b.id
			) dok on a.id_cont = dok.id_cont
LEFT JOIN dbo.P_KONTAKT kon on a.id_kupca = kon.id_kupca and kon.ID_VLOGA = 'IV' AND kon.NEAKTIVEN = 0
LEFT JOIN dbo.P_KONTAKT konp on a.id_kupca = konp.id_kupca and konp.ID_VLOGA = 'DP' AND konp.NEAKTIVEN = 0
LEFT JOIN dbo.P_KONTAKT konXW on a.id_kupca = konXW.id_kupca and konXW.ID_VLOGA = 'XW' AND konXW.NEAKTIVEN = 0
INNER JOIN dbo.rac_out ra on a.ddv_id = ra.ddv_id
LEFT JOIN dbo.custom_settings cust on cust.code = 'Nova.Reports.Print_R1'
LEFT JOIN dbo.GENERAL_REGISTER gr ON gr.ID_REGISTER = 'REPORT_SIGNATORY' and gr.id_key = 
	CASE WHEN v.sif_terj = 'MSTR' THEN 'FAK_LOBRV_MSTR' 
		WHEN v.sif_terj = 'SFIN' THEN 'FAK_LOBRV_SFIN'
		WHEN v.sif_terj = 'POLO' THEN 'FAK_LOBRV_POLO'
		ELSE 'FAK_LOBRV' END AND gr.neaktiven = 0
LEFT JOIN dbo.GENERAL_REGISTER grp ON grp.ID_REGISTER = 'REPORT_SIGNATORY' and grp.id_key =
	CASE WHEN v.sif_terj = 'MSTR' THEN 'FAK_LOBR_MSTR' 
	WHEN v.sif_terj = 'SFIN' THEN 'FAK_LOBR_SFIN'
	WHEN v.sif_terj = 'POLO' THEN 'FAK_LOBR_POLO'
	ELSE 'FAK_LOBR' END AND gr.neaktiven = 0
LEFT JOIN dbo.GENERAL_REGISTER grPrim ON grPrim.ID_REGISTER = 'REPORT_SIGNATORY' and grPrim.id_key = a.ra_izdal and grPrim.neaktiven = 0
JOIN dbo.nastavit n ON 1 = 1
LEFT JOIN dbo.PARTNER skrbnik on f.skrbnik_1 = skrbnik.id_kupca --potpis skrbnika za welcome letter
left join dbo.custom_settings cs1 on cs1.code = 'BOOKING_CRO_ACC_ALTMOD_DOK'
Left Join dbo.dokument ALTMOD_DOK on a.id_cont = ALTMOD_DOK.id_cont and CHARINDEX(ALTMOD_DOK.id_obl_zav, cs1.val) > 0
outer apply dbo.pfn_gmc_xchangeEurMigration(a.id_tec, a.sdebit, a.datum_dok, a.vr_osebe, a.ddv_id) as SDEBIT_EUR_MIG
outer apply dbo.pfn_gmc_xchangeEurMigrationPrintouts(a.id_tec, CASE WHEN a.dat_zap <= @datum THEN CAST(a.dolg-a.debit AS DECIMAL(18,2)) ELSE a.dolg END, a.datum_dok, a.vr_osebe, a.id_cont) as PRINT_DOLG_EUR_MIG
outer apply dbo.pfn_gmc_xchangeEurMigration(a.id_tec, CASE WHEN @tip_leas = 'OL' AND v.sif_terj = 'POLO' THEN a.SDEBIT-a.SROBRESTI ELSE a.SDEBIT END, a.datum_dok, a.vr_osebe, a.ddv_id) as NOT_LOBR_DEBIT_EUR_MIG
LEFT JOIN dbo.dokument dok_SE on dok_SE.id_cont=b.id_cont and dok_SE.ID_OBL_ZAV='SE' and dok_SE.STATUS_AKT='A'
LEFT JOIN dbo.PARTNER_TRR trr on trr.id_kupca=ra.ID_KUPCA and trr.prioriteta = 1
OUTER APPLY (select max(dat_izpisk) as dat_izpisk from dbo.placila where id_app_pren is not null) datIzv
outer apply (Select max(id_rep_ind) as id_rep_ind From dbo.rep_ind where izpisan = 0 and ddv_date > '20230630' and id_cont = a.id_cont) as rep_ind -- ili top 1 order by ili LIMIT 1
WHERE a.ddv_id = @id


print char(10)+char(10)+'TESTNI SELECT ' +char(10)

SELECT a.*, c.obnaleto, 
	(a.SNETO+a.SMARZA+a.SOBRESTI)*h.davek/100 as znesek_net_pdv,
	a.SREGIST*h.davek/100 as sregist_pdv,
	b.ddv_id as pogodba_ddv_id, 
	CASE WHEN left(e.opis,3) = 'ZAK' THEN 'zakonsku' else 'ugovornu' end as obresti_opis, f.direktor,
	g.saldo As g_saldo, g.kredit as g_kredit, g.id_val as g_id_val, @tip_leas AS tip_leas,
	v.sif_terj,
	dbo.pfn_gmc_hub3_BarCode(a.id_kupca, n.dom_valuta, a.sdebit, 'HR01', RTRIM(b.sklic), 'OTHR', CASE WHEN b.nacin_leas IN ('NF', 'NO') THEN 'Zakup/najam '+CASE WHEN v.sif_terj = 'SFIN' THEN CONVERT(VARCHAR(25),ISNULL(inter_obr.dat_od,''),104) ELSE CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(a.datum_dok)-1),a.datum_dok),104) END+'.-'+CASE WHEN v.sif_terj = 'SFIN' THEN CONVERT(VARCHAR(25),ISNULL(inter_obr.dat_do,''),104) ELSE CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,a.datum_dok))),DATEADD(mm,12/c.obnaleto,a.datum_dok)),104) END+'.)' ELSE LTRIM(RTRIM(ra.opisdok)) END) as barkod_value,
	CASE WHEN @tip_leas = 'OL' AND v.sif_terj = 'LOBR' THEN 1 ELSE 0 END AS OL_LOBR,
	CASE WHEN @tip_leas = 'OZ' AND v.sif_terj = 'LOBR' THEN 1 ELSE 0 END AS OZ_LOBR,
	CASE WHEN @tip_leas = 'F1' AND v.sif_terj = 'LOBR' THEN 1 ELSE 0 END AS F1_LOBR,
	CASE WHEN @tip_leas = 'ZP' AND v.sif_terj = 'LOBR' THEN 1 ELSE 0 END AS ZP_LOBR,
	CASE 
		 WHEN @tip_leas = 'OL' AND v.sif_terj = 'LOBR' THEN 'Obrok'
		 WHEN @tip_leas = 'F1' AND v.sif_terj = 'LOBR' THEN 'Glavnica'
		 WHEN @tip_leas = 'OL' AND v.sif_terj = 'SFIN' THEN 'Naknada za korištena sredstava'
		 WHEN @tip_leas = 'F1' AND v.sif_terj = 'SFIN' THEN 'Interkalarna kamata'
		 WHEN @tip_leas = 'F1' AND v.sif_terj = 'POLO' THEN v.naziv
		 WHEN @tip_leas = 'OL' AND v.sif_terj = 'POLO' THEN 'Posebna najamnina'
		 ELSE v.naziv
	END AS NAZ_TERJ1,
	CASE WHEN opr.se_regis= '*' THEN zap.opis ELSE nzap.opis END AS ZAP_OPIS, 
	ISNULL(zap.reg_stev,'') as zap_reg_stev, ISNULL(zap.st_sas,'') as zap_st_sas,
	CASE WHEN v.sif_terj = 'SFIN' THEN CONVERT(VARCHAR(25),ISNULL(inter_obr.dat_od,''),104) 
		ELSE case when ALTMOD_DOK.id_cont is null then CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(a.datum_dok)-1),a.datum_dok),104) 
			else convert(varchar(25), dbo.gfn_GetFirstDayOfMonth(DATEADD(mm, -12/c.obnaleto + 1, a.datum_dok)), 104) -- Dekurzivna naplata
			end
		END AS Datum_od,
	CASE WHEN v.sif_terj = 'SFIN' THEN CONVERT(VARCHAR(25),ISNULL(inter_obr.dat_do,''),104) 
		ELSE case when ALTMOD_DOK.id_cont is null then CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,a.datum_dok))),DATEADD(mm,12/c.obnaleto,a.datum_dok)),104) 
			else convert(varchar(25), a.datum_dok, 104) -- Dekurzivna naplata
			end
		END AS Datum_do,
	CASE WHEN @tip_leas = 'OL' AND v.sif_terj = 'POLO' THEN a.SNETO+a.SREGIST+a.SMARZA+a.SOBRESTI ELSE a.SNETO+a.SREGIST+a.SMARZA+a.SOBRESTI+a.SROBRESTI END AS NOT_LOBR_NETO,
	CASE WHEN @tip_leas = 'OL' AND v.sif_terj = 'POLO' THEN a.SNETO+a.SREGIST+a.SMARZA+a.SOBRESTI+a.SDAVEK ELSE a.SNETO+a.SREGIST+a.SMARZA+a.SOBRESTI+a.SROBRESTI+a.SDAVEK END AS NOT_LOBR_NETO1,
	CASE WHEN @tip_leas = 'OL' AND v.sif_terj = 'POLO' THEN a.SDEBIT-a.SROBRESTI ELSE a.SDEBIT END AS NOT_LOBR_DEBIT,
	CASE WHEN inter_obr.dat_od IS NULL OR inter_obr.dat_do IS NULL THEN 1 ELSE 0 END AS SFIN_NA_PLANP,
	CASE WHEN v.sif_terj <> 'LOBR' THEN 1 ELSE 0 END AS NOT_LOBR,
	CASE WHEN LEN(RTRIM(a.dav_stev)) = 11 THEN 0 ELSE 1 END AS OIB_NOT_OK,
	CASE WHEN a.vr_osebe = 'SP' AND LEN(a.stev_reg)>0 THEN 1 ELSE 0 END AS PRINT_MBO,
	CASE WHEN a.vr_osebe NOT IN ('SP','FO') AND LEN(a.emso)>0 AND LEN(a.emso)<13 THEN 1 ELSE 0 END AS PRINT_MB,
	CASE WHEN a.dat_zap <= @datum THEN CAST(a.dolg-a.debit AS DECIMAL(18,2)) ELSE a.dolg END AS PRINT_DOLG,
	CASE WHEN kon.id_kupca_k IS NOT NULL THEN 1 ELSE 0 END AS Print_Vloga,
	ISNULL(konp.opis,'') as Print_DP, dok.opis1 as Print_DU,
	COALESCE(grp.value, '') as Print_izdao,
	COALESCE(grPrim.value, gr.value, '') AS Print_veri,
	CASE WHEN a.id_klavzule is null or a.id_klavzule = '' THEN 0 ELSE 1 END AS PRINT_KLAVZULA,
	CASE WHEN a.datum_dok < '20130101' THEN 0 ELSE 1 END AS PRINT_DDV_HR,
	dbo.gfn_transformDDV_ID_HR(a.ddv_id,a.datum_dok) as Fis_BrRac,
	RTRIM(CONVERT(varchar(50), a.ra_dat_vnosa,104) + '. '+ CONVERT(VARCHAR(50), a.ra_dat_vnosa,108)) AS Dat_Izdavanja,
	CASE WHEN a.datum_dok < ISNULL(cust.val, '20500101') THEN 1 ELSE 0 END AS print_r1,
	CASE WHEN g.saldo=0 AND (v.sif_terj='MSTR' or v.sif_terj='POLO') THEN 1 ELSE 0 END AS PRINT_PODMIREN,
	CASE WHEN a.vr_osebe = 'FO' or a.vr_osebe = 'F1' THEN 1 ELSE 0 END as je_FO,
	CASE WHEN (month(a.datum_dok) = 3 AND year(a.datum_dok) = 2019) AND v.sif_terj = 'LOBR' AND a.nacin_leas NOT IN ('NO','NF','PF','PO') AND f.vr_osebe NOT IN ('F1','FO') THEN 1 ELSE 0 END as PRINT_POSEBAN_TEKST,
	CASE WHEN a.id_tec IN ('016', '017') THEN 1 ELSE 0 END AS hnb_txt,
	--potpis skrbnika za welcome letter
	CASE WHEN f.skrbnik_1 IS NOT NULL THEN skrbnik.naz_kr_kup ELSE ' ' END AS Skrbnik,
	case when @prvi_ugovor = 1 THEN 1 ELSE 0 END AS Prvi_ugovor,
	CASE WHEN g.id_terj = '21' and g.zap_obr = 1 THEN 1 ELSE 0 END AS Prva_rata,
	CASE WHEN b.nacin_leas = 'TP' THEN 0 ELSE 1 END AS Preuzeti_ugovor
	, datIzv.dat_izpisk as dat_izpisk
	, case when a.SROBRESTI != 0 and v.sif_terj = 'POLO' and @tip_leas = 'OL' then 1 else 0 end as PRINT_PPMV_POLO_OL
	, SDEBIT_EUR_MIG.res_print as SDEBIT_RES_PRINT
	, SDEBIT_EUR_MIG.res_amount as SDEBIT_RES_AMOUNT
	, SDEBIT_EUR_MIG.res_exch as SDEBIT_RES_EXCH
	, SDEBIT_EUR_MIG.res_id_val as SDEBIT_RES_ID_VAL
	, PRINT_DOLG_EUR_MIG.res_print as PRINT_DOLG_RES_PRINT
	, PRINT_DOLG_EUR_MIG.res_amount as PRINT_DOLG_RES_AMOUNT
	, PRINT_DOLG_EUR_MIG.res_exch as PRINT_DOLG_RES_EXCH
	, PRINT_DOLG_EUR_MIG.res_id_val as PRINT_DOLG_RES_ID_VAL
	, NOT_LOBR_DEBIT_EUR_MIG.res_print as NOT_LOBR_DEBIT_RES_PRINT
	, NOT_LOBR_DEBIT_EUR_MIG.res_amount as NOT_LOBR_DEBIT_RES_AMOUNT
	, NOT_LOBR_DEBIT_EUR_MIG.res_exch as NOT_LOBR_DEBIT_RES_EXCH
	, NOT_LOBR_DEBIT_EUR_MIG.res_id_val as NOT_LOBR_DEBIT_RES_ID_VAL
    , dok_SE.ID_OBL_ZAV
	, dok_SE.STEVILKA
    , trr.trr
	, case when rep_ind.id_rep_ind is not null and f.ident_stevilka is not null and f.ident_stevilka <> '' and v.sif_terj = 'LOBR' then 1 else 0 end as print_rep_ind		 
FROM dbo.pfn_gmc_Print_InvoiceForInstallments(@datum) a
INNER JOIN dbo.pogodba b on a.id_cont = b.id_cont
LEFT JOIN dbo.obdobja c on b.id_obd = c.id_obd
LEFT JOIN dbo.gen_interkalarne_obr_child inter_obr ON a.st_dok = inter_obr.st_dok
LEFT JOIN dbo.obresti e on b.id_obrv = e.id_obr
LEFT JOIN dbo.partner f on b.id_kupca = f.id_kupca
LEFT JOIN dbo.planp g on a.id_cont = g.id_cont AND a.st_dok = g.st_dok
LEFT JOIN dbo.vrst_ter v on a.id_terj = v.id_terj
--correction in case of multiple zapisnika MR 40630 LEFT JOIN dbo.zap_reg zap on a.id_cont = zap.id_cont
--LEFT JOIN dbo.zap_ner nzap on a.id_cont = nzap.id_cont
outer apply (SELECT TOP 1 opis, reg_stev, st_sas FROM dbo.zap_reg WHERE zap_reg.id_cont = a.id_cont) zap
outer apply (SELECT TOP 1 opis FROM dbo.zap_ner WHERE zap_ner.id_cont = a.id_cont) nzap
LEFT JOIN dbo.vrst_opr opr on b.id_vrste = opr.id_vrste
INNER JOIN dbo.dav_stop h ON a.id_dav_st = h.id_dav_st
--LEFT JOIN (SELECT a.id_cont, /*a.id_dokum,*/ a.opis1
--		FROM dbo.dokument a
--		INNER JOIN (SELECT MAX(id_dokum) AS id FROM dbo.dokument /*with (Index(IX_DOKUMENT_ic), index(IX_DOKUMENT_IOZ))*/ WHERE id_obl_zav = 'DU' GROUP BY id_cont) b ON a.id_dokum = b.id
--			) dok on a.id_cont = dok.id_cont
outer apply (select top 1 opis1 from dbo.dokument where id_cont = a.id_cont and id_obl_zav = 'DU' order by id_dokum desc) dok --on a.id_cont = dok.id_cont RADI SPORIJE OD LEFT JOINA, EXECUTIN PLAN JA 49% 
LEFT JOIN dbo.P_KONTAKT kon on a.id_kupca = kon.id_kupca and kon.ID_VLOGA = 'IV' AND kon.NEAKTIVEN = 0
LEFT JOIN dbo.P_KONTAKT konp on a.id_kupca = konp.id_kupca and konp.ID_VLOGA = 'DP' AND konp.NEAKTIVEN = 0
LEFT JOIN dbo.P_KONTAKT konXW on a.id_kupca = konXW.id_kupca and konXW.ID_VLOGA = 'XW' AND konXW.NEAKTIVEN = 0
INNER JOIN dbo.rac_out ra on a.ddv_id = ra.ddv_id
LEFT JOIN dbo.custom_settings cust on cust.code = 'Nova.Reports.Print_R1'
LEFT JOIN dbo.GENERAL_REGISTER gr ON gr.ID_REGISTER = 'REPORT_SIGNATORY' and gr.id_key = 
	CASE WHEN v.sif_terj = 'MSTR' THEN 'FAK_LOBRV_MSTR' 
		WHEN v.sif_terj = 'SFIN' THEN 'FAK_LOBRV_SFIN'
		WHEN v.sif_terj = 'POLO' THEN 'FAK_LOBRV_POLO'
		ELSE 'FAK_LOBRV' END AND gr.neaktiven = 0
LEFT JOIN dbo.GENERAL_REGISTER grp ON grp.ID_REGISTER = 'REPORT_SIGNATORY' and grp.id_key =
	CASE WHEN v.sif_terj = 'MSTR' THEN 'FAK_LOBR_MSTR' 
	WHEN v.sif_terj = 'SFIN' THEN 'FAK_LOBR_SFIN'
	WHEN v.sif_terj = 'POLO' THEN 'FAK_LOBR_POLO'
	ELSE 'FAK_LOBR' END AND gr.neaktiven = 0
LEFT JOIN dbo.GENERAL_REGISTER grPrim ON grPrim.ID_REGISTER = 'REPORT_SIGNATORY' and grPrim.id_key = a.ra_izdal and grPrim.neaktiven = 0
JOIN dbo.nastavit n ON 1 = 1
LEFT JOIN dbo.PARTNER skrbnik on f.skrbnik_1 = skrbnik.id_kupca --potpis skrbnika za welcome letter
left join dbo.custom_settings cs1 on cs1.code = 'BOOKING_CRO_ACC_ALTMOD_DOK'
Left Join dbo.dokument ALTMOD_DOK on a.id_cont = ALTMOD_DOK.id_cont and CHARINDEX(ALTMOD_DOK.id_obl_zav, cs1.val) > 0
outer apply dbo.pfn_gmc_xchangeEurMigration(a.id_tec, a.sdebit, a.datum_dok, a.vr_osebe, a.ddv_id) as SDEBIT_EUR_MIG
outer apply dbo.pfn_gmc_xchangeEurMigrationPrintouts(a.id_tec, CASE WHEN a.dat_zap <= @datum THEN CAST(a.dolg-a.debit AS DECIMAL(18,2)) ELSE a.dolg END, a.datum_dok, a.vr_osebe, a.id_cont) as PRINT_DOLG_EUR_MIG
outer apply dbo.pfn_gmc_xchangeEurMigration(a.id_tec, CASE WHEN @tip_leas = 'OL' AND v.sif_terj = 'POLO' THEN a.SDEBIT-a.SROBRESTI ELSE a.SDEBIT END, a.datum_dok, a.vr_osebe, a.ddv_id) as NOT_LOBR_DEBIT_EUR_MIG
LEFT JOIN dbo.dokument dok_SE on dok_SE.id_cont=b.id_cont and dok_SE.ID_OBL_ZAV='SE' and dok_SE.STATUS_AKT='A'
LEFT JOIN dbo.PARTNER_TRR trr on trr.id_kupca=ra.ID_KUPCA and trr.prioriteta = 1
OUTER APPLY (select max(dat_izpisk) as dat_izpisk from dbo.placila where id_app_pren is not null) datIzv
outer apply (Select max(id_rep_ind) as id_rep_ind From dbo.rep_ind where izpisan = 0 and ddv_date > '20230630' and id_cont = a.id_cont) as rep_ind -- ili top 1 order by ili LIMIT 1
WHERE a.ddv_id = @id

set statistics time off