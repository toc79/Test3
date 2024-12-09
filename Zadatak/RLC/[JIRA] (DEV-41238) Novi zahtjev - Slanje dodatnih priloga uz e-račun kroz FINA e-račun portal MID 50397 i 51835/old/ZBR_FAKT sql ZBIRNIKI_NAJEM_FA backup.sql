DECLARE @datum datetime, @tip_leas char(2)
SET @datum = getdate()

set @tip_leas = (select dbo.gfn_Nacin_leas_HR(nf.nacin_leas) 
	From dbo.ZBIRNIKI z
inner join dbo.ZBIRNIKI_NAJEM_FA zf on z.ID_ZBIRNIK = zf.ID_ZBIRNIK
inner join dbo.NAJEM_FA nf on zf.st_dok = nf.st_dok
where z.ID_ZBIRNIK = @id
group by dbo.gfn_Nacin_leas_HR(nf.nacin_leas))

SELECT 
	a.SNETO, a.SMARZA, a.SOBRESTI, a.DAV_VRED, a.SREGIST, a.SROBRESTI, a.SDEBIT, a.SDAVEK,
	c.obnaleto,
	CASE WHEN a.SREGIST > 0 THEN ROUND((a.SNETO+a.SMARZA+a.SOBRESTI)*h.davek/100,2) ELSE a.SDAVEK END as znesek_net_pdv,
	ROUND(a.SREGIST*h.davek/100,2) as sregist_pdv,
	a.zap_obr,
	CASE WHEN v.sif_terj = 'SFIN' THEN CONVERT(VARCHAR(25),ISNULL(inter_obr.dat_od,''),104) ELSE CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(a.datum_dok)-1),a.datum_dok),104) END AS Datum_od,
CASE WHEN v.sif_terj = 'SFIN' THEN CONVERT(VARCHAR(25),ISNULL(inter_obr.dat_do,''),104) ELSE CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,a.datum_dok))),DATEADD(mm,12/c.obnaleto,a.datum_dok)),104) END AS Datum_do,
b.id_pog,
b.pred_naj,
z.ID_ZBIRNIK,
dbo.pfn_gmc_hub3_BarCode(ra.id_kupca, n.dom_valuta, bcode.bcode_sum, 'HR01', RTRIM(z.sklic), 'OTHR', LTRIM(RTRIM(ra.opisdok))) as barkod_value,
CASE 
	 WHEN @tip_leas = 'OL' AND v.sif_terj = 'LOBR' THEN 'Obrok'
	 WHEN @tip_leas = 'F1' AND v.sif_terj = 'LOBR' THEN 'Glavnica'
	 WHEN @tip_leas = 'OL' AND v.sif_terj = 'SFIN' THEN 'Naknada za korištena sredstava'
	 WHEN @tip_leas = 'F1' AND v.sif_terj = 'SFIN' THEN 'Interkalarna kamata'
	 WHEN @tip_leas = 'F1' AND v.sif_terj = 'POLO' THEN v.naziv
	 WHEN @tip_leas = 'OL' AND v.sif_terj = 'POLO' THEN 'Posebna najamnina'
	 ELSE v.naziv
END AS NAZ_TERJ1,
CASE WHEN inter_obr.dat_od IS NULL OR inter_obr.dat_do IS NULL THEN 1 ELSE 0 END AS SFIN_NA_PLANP,
a.id_terj,
CASE WHEN @tip_leas = 'OL' AND v.sif_terj = 'POLO' THEN a.SNETO+a.SREGIST+a.SMARZA+a.SOBRESTI ELSE a.SNETO+a.SREGIST+a.SMARZA+a.SOBRESTI+a.SROBRESTI END AS NOT_LOBR_NETO,
CASE WHEN @tip_leas = 'OL' AND v.sif_terj = 'POLO' THEN a.SNETO+a.SREGIST+a.SMARZA+a.SOBRESTI+a.SDAVEK ELSE a.SNETO+a.SREGIST+a.SMARZA+a.SOBRESTI+a.SROBRESTI+a.SDAVEK END AS NOT_LOBR_NETO1,
CASE WHEN @tip_leas = 'OL' AND v.sif_terj = 'POLO' THEN a.SDEBIT-a.SROBRESTI ELSE a.SDEBIT END AS NOT_LOBR_DEBIT,
@tip_leas as tip_leas,
v.sif_terj,
CASE WHEN opr.se_regis= '*' THEN zap.opis ELSE nzap.opis END AS ZAP_OPIS, 
CASE WHEN opr.se_regis= '*' THEN ', '+ISNULL(zap.reg_stev,'') ELSE '' END AS zap_reg_stev, 
CASE WHEN opr.se_regis= '*' THEN ', '+ISNULL(zap.st_sas,'') ELSE '' END AS zap_st_sas
FROM dbo.ZBIRNIKI_NAJEM_FA zn
INNER JOIN dbo.ZBIRNIKI z on zn.ID_ZBIRNIK = z.ID_ZBIRNIK
INNER JOIN dbo.pfn_gmc_Print_InvoiceForInstallments(@datum) a on zn.ST_DOK = a.ST_DOK
INNER JOIN dbo.pogodba b on a.id_cont = b.id_cont
LEFT JOIN dbo.vrst_opr opr on b.id_vrste = opr.id_vrste
outer apply (SELECT TOP 1 opis, reg_stev, st_sas FROM dbo.zap_reg WHERE zap_reg.id_cont = a.id_cont) zap
outer apply (SELECT TOP 1 opis FROM dbo.zap_ner WHERE zap_ner.id_cont = a.id_cont) nzap
LEFT JOIN dbo.obdobja c on b.id_obd = c.id_obd
LEFT JOIN dbo.gen_interkalarne_obr_child inter_obr ON a.st_dok = inter_obr.st_dok
LEFT JOIN dbo.vrst_ter v on a.id_terj = v.id_terj
INNER JOIN dbo.dav_stop h ON a.rac_out_id_dav_st = h.id_dav_st
INNER JOIN dbo.rac_out ra on z.ddv_id = ra.ddv_id
JOIN dbo.nastavit n ON 1 = 1
OUTER APPLY (SELECT sum(a.SDEBIT) as bcode_sum
	FROM dbo.ZBIRNIKI_NAJEM_FA zn
INNER JOIN dbo.ZBIRNIKI z on zn.ID_ZBIRNIK = z.ID_ZBIRNIK
INNER JOIN dbo.pfn_gmc_Print_InvoiceForInstallments(@datum) a on zn.ST_DOK = a.ST_DOK
JOIN dbo.nastavit n ON 1 = 1
WHERE z.ID_ZBIRNIK = @id and z.ddv_id is not null) bcode
WHERE z.ID_ZBIRNIK = @id and z.ddv_id is not null