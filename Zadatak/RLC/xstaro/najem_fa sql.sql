DECLARE @datum datetime, @tip_leas char(2)
SET @datum = getdate()

set @tip_leas = (select dbo.gfn_Nacin_leas_HR(b.nacin_leas) 
	From dbo.rac_out a 
left join dbo.pogodba b on a.id_cont = b.id_cont
where a.ddv_id = @id)

SELECT a.*, c.obnaleto, 
(a.SNETO+a.SMARZA+a.SOBRESTI)*h.davek/100 as znesek_net_pdv,
a.SREGIST*h.davek/100 as sregist_pdv,
b.ddv_id as pogodba_ddv_id, 
CASE WHEN left(e.opis,3) = 'ZAK' THEN 'zakonsku' else 'ugovornu' end as obresti_opis, f.direktor,
g.saldo As g_saldo, g.kredit as g_kredit, g.id_val as g_id_val, @tip_leas AS tip_leas,
v.sif_terj,
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
CASE WHEN v.sif_terj = 'SFIN' THEN CONVERT(VARCHAR(25),ISNULL(inter_obr.dat_od,''),104) ELSE CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(a.datum_dok)-1),a.datum_dok),104) END AS Datum_od,
CASE WHEN v.sif_terj = 'SFIN' THEN CONVERT(VARCHAR(25),ISNULL(inter_obr.dat_do,''),104) ELSE CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,a.datum_dok))),DATEADD(mm,12/c.obnaleto,a.datum_dok)),104) END AS Datum_do,
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
--CASE WHEN (month(a.datum_dok) = 3 AND year(a.datum_dok) = 2016) AND v.sif_terj = 'LOBR'  AND a.nacin_leas != 'ZP' AND a.nacin_leas != 'NF' THEN 1 ELSE 0 END as PRINT_POSEBAN_TEKST,
--CASE WHEN (month(a.datum_dok) = 2 AND year(a.datum_dok) = 2018) AND v.sif_terj = 'LOBR'  AND a.nacin_leas NOT IN ('ZP','NO','NF','PF') 
--AND a.id_Cont NOT IN (Select ID_CONT From dbo.POGODBA Where ID_VRSTE IN ('0034','0035','0047','0060') AND STATUS_AKT <> 'Z' AND ANEKS <> 'T' AND dbo.gfn_Nacin_leas_HR(nacin_leas) = 'F1') 
--	THEN 1 ELSE 0 END as PRINT_POSEBAN_TEKST_II,
CASE WHEN (month(a.datum_dok) = 9 AND year(a.datum_dok) = 2018) AND v.sif_terj = 'LOBR'  AND a.nacin_leas NOT IN ('ZP','NO','NF','PF') THEN 1 ELSE 0 END as PRINT_POSEBAN_TEKST, 
CASE WHEN konXW.id_kupca IS NOT NULL THEN 1 ELSE 0 END AS PRINT_VLOGA_XW
FROM dbo.pft_Print_InvoiceForInstallments(@datum) a
--dbo.gft_Print_InvoiceForInstallments(@datum) a
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
INNER JOIN (SELECT MAX(id_dokum) AS id FROM dbo.dokument WHERE id_obl_zav = 'DU' GROUP BY id_cont) b ON a.id_dokum = b.id
			) dok on a.id_cont = dok.id_cont
LEFT JOIN (SELECT * FROM P_KONTAKT WHERE ID_VLOGA = 'IV' AND NEAKTIVEN = 0) kon on a.id_kupca = kon.id_kupca
LEFT JOIN (SELECT * FROM P_KONTAKT WHERE ID_VLOGA = 'DP' AND NEAKTIVEN = 0) konp on a.id_kupca = konp.id_kupca 
LEFT JOIN (SELECT * FROM P_KONTAKT WHERE ID_VLOGA = 'XW' AND NEAKTIVEN = 0) konXW on a.id_kupca = konXW.id_kupca 
LEFT JOIN dbo.custom_settings cust on cust.code = 'Nova.Reports.Print_R1'
LEFT JOIN dbo.GENERAL_REGISTER gr ON gr.ID_REGISTER = 'REPORT_SIGNATORY' and gr.id_key = CASE WHEN v.sif_terj = 'MSTR' THEN 'FAK_LOBRV_MSTR' 
																								WHEN v.sif_terj = 'SFIN' THEN 'FAK_LOBRV_SFIN'
																								WHEN v.sif_terj = 'POLO' THEN 'FAK_LOBRV_POLO'
																								ELSE 'FAK_LOBRV' END AND gr.neaktiven = 0
LEFT JOIN dbo.GENERAL_REGISTER grp ON grp.ID_REGISTER = 'REPORT_SIGNATORY' and grp.id_key = CASE WHEN v.sif_terj = 'MSTR' THEN 'FAK_LOBR_MSTR' 
																								WHEN v.sif_terj = 'SFIN' THEN 'FAK_LOBR_SFIN'
																								WHEN v.sif_terj = 'POLO' THEN 'FAK_LOBR_POLO'
																								ELSE 'FAK_LOBR' END AND gr.neaktiven = 0
LEFT JOIN dbo.GENERAL_REGISTER grPrim ON grPrim.ID_REGISTER = 'REPORT_SIGNATORY' and grPrim.id_key = a.ra_izdal
WHERE a.ddv_id = @id


/*
20120015996 - TROŠAK OBRADE F1
20110032305 - TROŠAK OBRADE OL
20110039746 - AKONTACIJA/UČEŠĆE
20110079028 - RATA FL + DU i DP
20110008762 - RATA OJ
20110084738 - INTERKALARNA KTA OL
20110084739 - INTERKALARNA KTA FL
20110012731 - IBM HRVATSKA

FISKALIZACIJA
20130009989 - TROŠAK OBRADE	F1
20130009987 - TROŠAK OBRADE OJ
20130010006 - AKONTACIJA/UČEŠĆE
20130008102 - RATA FL + DU i DP
20130009955 - RATA/OBROK OA
20130009918 - RATA/OBROK OJ
20130010010 - INTERKALARNA KTA OL
20130010002 - INTERKALARNA KTA FL
20130003288 - IBM HRVATSKA
*/