DECLARE @datum datetime, @tip_leas char(2), @ddv_id char (14), @sif_terj char(4), @st_dok char (21), @id_cont int, @st_krov_pog char (50)--, @id int
SET @datum = getdate()

set @tip_leas = (select dbo.gfn_Nacin_leas_HR(nf.nacin_leas) 
	From dbo.ZBIRNIKI z
inner join dbo.ZBIRNIKI_NAJEM_FA zf on z.ID_ZBIRNIK = zf.ID_ZBIRNIK
inner join dbo.NAJEM_FA nf on zf.st_dok = nf.st_dok
where z.ID_ZBIRNIK = @id
group by dbo.gfn_Nacin_leas_HR(nf.nacin_leas))

SET @ddv_id = (select ddv_id from dbo.ZBIRNIKI where ID_ZBIRNIK = @id)

SET @sif_terj = (Select sif_terj from dbo.vrst_ter where id_terj = (Select id_terj from dbo.najem_fa where ddv_id = @ddv_id group by id_terj))

-- prvi st_dok i id_cont, zbog joina za izračun razdoblja
SET @st_dok = (Select top 1 st_dok from dbo.najem_fa where ddv_id = @ddv_id)
SET @id_cont = (Select top 1 id_cont from dbo.najem_fa where ddv_id = @ddv_id)

--prvi st_krov_pog za prikaz broja krovnog ugovora
SET @st_krov_pog = (Select top 1 kp.st_krov_pog from dbo.krov_pog kp inner join dbo.ZBIRNIKI z on kp.id_krov_pog = z.id_krov_pog where z.ID_ZBIRNIK = @id)

select
	z.ddv_id, z.ID_ZBIRNIK, ra.id_kupca,
	pa.naz_kr_kup, pa.ulica, pa.id_poste, pa.mesto, pa.ulica_sed, pa.id_poste_sed, pa.mesto_sed, pa.dav_stev, pa.emso, pa.stev_reg,
	CASE WHEN ra.id_klavzule is null or ra.id_klavzule = '' THEN 0 ELSE 1 END AS PRINT_KLAVZULA,
	ks.klavzula,
	dbo.gfn_transformDDV_ID_HR(a.ddv_id,a.datum_dok) as Fis_BrRac,
	RTRIM(CONVERT(varchar(50), ra.dat_vnosa,104) + '. '+ CONVERT(VARCHAR(50), ra.dat_vnosa,108)) AS Dat_Izdavanja,
	a.datum_dok, a.DAT_ZAP, a.ra_dat_vnosa,
	a.DAV_VRED, a.SOBRESTI, a.SDAVEK, a.SNETO, a.SREGIST, a.SMARZA, a.SROBRESTI, a.SDEBIT, a.DEBIT, a.dolg,
	a.znesek_net_pdv,
	a.sregist_pdv,
	CASE WHEN @sif_terj = 'SFIN' THEN CONVERT(VARCHAR(25),ISNULL(inter_obr.dat_od,''),104) ELSE CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(a.datum_dok)-1),a.datum_dok),104) END AS Datum_od,
	CASE WHEN @sif_terj = 'SFIN' THEN CONVERT(VARCHAR(25),ISNULL(inter_obr.dat_do,''),104) ELSE CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,a.datum_dok))),DATEADD(mm,12/c.obnaleto,a.datum_dok)),104) END AS Datum_do,
	a.id_tec,
	tec.naziv as naz_tecaj,
	a.id_dav_st,
	a.id_val,
	z.sklic, z.id_krov_pog,
	@st_krov_pog as st_krov_pog,
	CASE WHEN pa.vr_osebe = 'SP' AND LEN(pa.stev_reg)>0 THEN 1 ELSE 0 END AS PRINT_MBO,
	CASE WHEN pa.vr_osebe NOT IN ('SP','FO') AND LEN(pa.emso)>0 AND LEN(pa.emso)<13 THEN 1 ELSE 0 END AS PRINT_MB,
	@tip_leas as tip_leas,
	CASE WHEN LEN(RTRIM(pa.dav_stev)) = 11 THEN 0 ELSE 1 END AS OIB_NOT_OK,
	--CASE WHEN a.dat_zap <= @datum THEN CAST(a.dolg-a.debit AS DECIMAL(18,2)) ELSE a.dolg END AS PRINT_DOLG,
	dbo.gfn_Xchange('000', (CASE WHEN a.dat_zap <= @datum THEN CAST(a.dolg-a.debit AS DECIMAL(18,2)) ELSE a.dolg END), a.id_tec, a.datum_dok) AS PRINT_DOLG,
	COALESCE(grp.value, '') as Print_izdao,
	COALESCE(grPrim.value, gr.value, '') AS Print_veri,
	CASE WHEN @sif_terj <> 'LOBR' THEN 1 ELSE 0 END AS NOT_LOBR,
	ra.izravnava_ddv,
	ra.st_dok as st_dok_zbir,
	@sif_terj as sif_terj,
	a.saldo as g_saldo, a.kredit as g_kredit, a.pp_val as g_id_val,
	CASE WHEN a.saldo=0 AND (@sif_terj='MSTR' or @sif_terj='POLO') THEN 1 ELSE 0 END AS PRINT_PODMIREN,
	CASE WHEN @tip_leas = 'OL' AND @sif_terj = 'POLO' THEN a.SNETO+a.SREGIST+a.SMARZA+a.SOBRESTI ELSE a.SNETO+a.SREGIST+a.SMARZA+a.SOBRESTI+a.SROBRESTI END AS NOT_LOBR_NETO,
	CASE WHEN @tip_leas = 'OL' AND @sif_terj = 'POLO' THEN a.SNETO+a.SREGIST+a.SMARZA+a.SOBRESTI+a.SDAVEK ELSE a.SNETO+a.SREGIST+a.SMARZA+a.SOBRESTI+a.SROBRESTI+a.SDAVEK END AS NOT_LOBR_NETO1,
	CASE WHEN @tip_leas = 'OL' AND @sif_terj = 'POLO' THEN a.SDEBIT-a.SROBRESTI ELSE a.SDEBIT END AS NOT_LOBR_DEBIT,
	CASE 
		 WHEN @tip_leas = 'OL' AND @sif_terj = 'LOBR' THEN 'Obrok'
		 WHEN @tip_leas = 'F1' AND @sif_terj = 'LOBR' THEN 'Glavnica'
		 WHEN @tip_leas = 'OL' AND @sif_terj = 'SFIN' THEN 'Naknada za korištena sredstava'
		 WHEN @tip_leas = 'F1' AND @sif_terj = 'SFIN' THEN 'Interkalarna kamata'
		 WHEN @tip_leas = 'F1' AND @sif_terj = 'POLO' THEN vt.naziv
		 WHEN @tip_leas = 'OL' AND @sif_terj = 'POLO' THEN 'Posebna najamnina'
		 ELSE vt.naziv
	END AS NAZ_TERJ1,
	CASE WHEN inter_obr.dat_od IS NULL OR inter_obr.dat_do IS NULL THEN 1 ELSE 0 END AS SFIN_NA_PLANP,
	vt.id_terj,
	ISNULL(konp.opis,'') as Print_DP,
	dbo.pfn_gmc_hub3_BarCode(ra.id_kupca, n.dom_valuta, a.sdebit, 'HR01', RTRIM(z.sklic), 'OTHR', LTRIM(RTRIM(ra.opisdok))) as barkod_value,
		CASE WHEN a.id_tec IN ('016', '017') THEN 1 ELSE 0 END AS hnb_txt
	, datIzv.dat_izpisk as dat_izpisk
	--, CASE WHEN kon.id_kupca_k IS NOT NULL THEN 1 ELSE 0 END AS Print_Vloga --31.08.2022 g_tomislav MID 49062 - nije bilo pa sam kopirao s FAK_LOBR i zakomentirao
	--, 0 AS Print_Vloga --DODANO JER RETRIEVE CULOMNS TREBA VRATITI TU KOLONU
	, case when pa.ident_stevilka is not null and pa.ident_stevilka <> '' then 1 else 0 end as is_for_fina
FROM dbo.ZBIRNIKI z
INNER JOIN dbo.rac_out ra on z.ddv_id = ra.ddv_id
INNER JOIN dbo.partner pa on ra.id_kupca = pa.id_kupca
LEFT JOIN dbo.klavzule_sifr ks on ks.id_klavzule = ra.id_klavzule
INNER JOIN 
	(Select a.ddv_id, a.datum_dok, a.DAT_ZAP, a.ra_dat_vnosa, a.DAV_VRED, a.id_dav_st, a.id_tec, a.id_val, a.ra_izdal, a.dat_prip, sum(a.SOBRESTI) as SOBRESTI, sum(a.SDAVEK) as SDAVEK, sum(a.SNETO) as SNETO, 
		sum(a.SREGIST) as SREGIST, sum(a.SMARZA) as SMARZA, sum (a.SROBRESTI) as SROBRESTI,
		sum(a.SDEBIT) as SDEBIT, sum(a.DEBIT) as DEBIT, sum(a.dolg) as dolg, sum(a.REGIST) as REGIST,
		SUM(CASE WHEN a.SREGIST > 0 THEN ROUND((a.SNETO+a.SMARZA+a.SOBRESTI)*h.davek/100,2) ELSE a.SDAVEK END) as znesek_net_pdv,
		SUM(ROUND(a.SREGIST*h.davek/100,2)) as sregist_pdv, 
		sum(pp.saldo)as saldo, sum(pp.kredit) as kredit, pp.id_val as pp_val
	 from dbo.pfn_gmc_Print_InvoiceForInstallments(@datum) a
	 inner join dbo.dav_stop h ON a.rac_out_id_dav_st = h.id_dav_st
	 inner join dbo.PLANP pp ON a.id_cont = pp.id_cont AND a.ST_DOK = pp.ST_DOK
	 where a.ddv_id = @ddv_id
	Group by a.ddv_id, a.datum_dok, a.DAT_ZAP, a.ra_dat_vnosa, a.DAV_VRED, a.id_dav_st, a.id_tec, a.id_val, a.ra_izdal, a.dat_prip, pp.id_val) a on z.DDV_ID = a.DDV_ID
LEFT JOIN dbo.gen_interkalarne_obr_child inter_obr ON inter_obr.st_dok = @st_dok
INNER JOIN dbo.pogodba b on b.id_cont = @id_cont
INNER JOIN dbo.obdobja c on b.id_obd = c.id_obd
INNER JOIN dbo.TECAJNIC tec on a.id_tec = tec.id_tec
INNER JOIN dbo.vrst_ter vt on vt.sif_terj = @sif_terj
LEFT JOIN dbo.GENERAL_REGISTER gr ON gr.ID_REGISTER = 'REPORT_SIGNATORY' and gr.id_key = CASE WHEN @sif_terj = 'MSTR' THEN 'FAK_LOBRV_MSTR' 
																								WHEN @sif_terj = 'SFIN' THEN 'FAK_LOBRV_SFIN'
																								WHEN @sif_terj = 'POLO' THEN 'FAK_LOBRV_POLO'
																								ELSE 'FAK_LOBRV' END AND gr.neaktiven = 0
LEFT JOIN dbo.GENERAL_REGISTER grp ON grp.ID_REGISTER = 'REPORT_SIGNATORY' and grp.id_key = CASE WHEN @sif_terj = 'MSTR' THEN 'FAK_LOBR_MSTR' 
																								WHEN @sif_terj = 'SFIN' THEN 'FAK_LOBR_SFIN'
																								WHEN @sif_terj = 'POLO' THEN 'FAK_LOBR_POLO'
																								ELSE 'FAK_LOBR' END AND grp.neaktiven = 0
LEFT JOIN dbo.GENERAL_REGISTER grPrim ON grPrim.ID_REGISTER = 'REPORT_SIGNATORY' and grPrim.id_key = a.ra_izdal
LEFT JOIN (SELECT * FROM P_KONTAKT WHERE ID_VLOGA = 'DP' AND NEAKTIVEN = 0) konp on ra.id_kupca = konp.id_kupca
LEFT JOIN (SELECT * FROM P_KONTAKT WHERE ID_VLOGA = 'IV' AND NEAKTIVEN = 0) kon on ra.id_kupca = kon.id_kupca
JOIN dbo.nastavit n ON 1 = 1
OUTER APPLY (select max(dat_izpisk) as dat_izpisk from dbo.placila where id_app_pren is not null ) datIzv
WHERE z.ID_ZBIRNIK = @id and z.ddv_id is not null