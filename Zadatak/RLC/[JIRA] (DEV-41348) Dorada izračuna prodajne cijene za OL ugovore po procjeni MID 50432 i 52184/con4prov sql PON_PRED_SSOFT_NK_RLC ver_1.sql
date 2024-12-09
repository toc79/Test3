--declare @id varchar(100) = '76552;2'
DECLARE  @id_pon_pred_otkup varchar(max), @ponudba_flag varchar(max)--, @id varchar(max)
set @id_pon_pred_otkup = REPLACE(SUBSTRING(@id,1,CHARINDEX(';', @id) - 1), '', '') 
SET @ponudba_flag = SUBSTRING(@id, CHARINDEX(';', @id) + 1, LEN(@id) - CHARINDEX(';', @id))


DECLARE @XML AS xml = (SELECT REPLACE(CAST(xml_detail AS NVARCHAR(MAX)),'<?xml version="1.0" encoding="utf-16"?>','') FROM dbo.PON_PRED_ODKUP WHERE id_pon_pred_odkup = @id_pon_pred_otkup)

DECLARE @temp TABLE (osnova DECIMAL (18,2), varscina DECIMAL(18,2), ppmv DECIMAL(18,2), net_val_fl DECIMAL(18,2), regist DECIMAL(18,2), neto DECIMAL(18,2), zam_obr DECIMAL(18,2), net_val_ol DECIMAL(18,2))

;WITH XMLNAMESPACES (N'urn:gmi:nova:leasing' AS NS)
INSERT INTO @temp
SELECT
	 SUM(IIF(r.value('(NS:z_davkom)[1]', 'CHAR(1)') = '*', 0, IIF(vt.sif_terj = 'VOPC', r.value('(NS:neto)[1]', 'DECIMAL(18,2)'), r.value('(NS:disk_vred)[1]', 'DECIMAL(18,2)')))) AS osnova,
	 SUM(DISTINCT(r.value('(NS:varscina)[1]', 'DECIMAL(18,2)'))) AS varscina,
	SUM(IIF(r.value('(NS:z_davkom)[1]', 'CHAR(1)') = '*', 0, r.value('(NS:robresti)[1]', 'DECIMAL(18,2)'))) AS ppmv,
	 SUM(IIF(r.value('(NS:z_davkom)[1]', 'CHAR(1)') = '*' OR vt.sif_terj = 'VOPC', 0, r.value('(NS:net_val)[1]', 'DECIMAL(18,2)'))) AS net_val_fl,
	 SUM(IIF(r.value('(NS:z_davkom)[1]', 'CHAR(1)') = '*' OR vt.sif_terj = 'VOPC', 0, r.value('(NS:regist)[1]', 'DECIMAL(18,2)'))) AS regist,
	 SUM(IIF(r.value('(NS:z_davkom)[1]', 'CHAR(1)') = '*' OR vt.sif_terj = 'VOPC', 0, r.value('(NS:neto)[1]', 'DECIMAL(18,2)'))) AS neto,
	 SUM(r.value('(NS:zam_obr)[1]', 'DECIMAL(18,2)')) AS zam_obr,
	 SUM(IIF(r.value('(NS:z_davkom)[1]', 'CHAR(1)') = '*', r.value('(NS:net_val)[1]', 'DECIMAL(18,2)'), 0)) AS net_val_ol
	FROM @XML.nodes('//NS:GBO_OfferPriorredemptionDetails') n(r)
LEFT JOIN dbo.vrst_ter vt ON r.value('(NS:id_terj)[1]', 'CHAR(3)') = vt.id_terj


Select 
	a.id_cont, 
	a.datum_ponudbe, 
	a.dodatne_ter, 
	CAST(a.id_dav_st as Decimal(18,2)) AS id_dav_st, 
	dbo.gfn_id_pog4id_cont(a.id_cont) as id_pog, 
	a.popust_proc, 
	a.str_inkaso,
	a.id_tec, 
	a.str_izplac_zav, 
	Case when dbo.gfn_Nacin_leas_HR(pog.nacin_leas) NOT IN ('FF','F1','ZP') Then a.str_man else a.str_man End as str_man_s_pdv,
	a.str_man,
	a.str_odob_lj, 
	Case when dbo.gfn_Nacin_leas_HR(pog.nacin_leas) NOT IN ('FF','F1','ZP') Then a.str_odv else a.str_odv + (a.str_odv * (IIF(ISNULL(a.id_dav_st, '') = '', pog_davek.davek, pon_davek.davek)/100)) End as str_odv_s_pdv,
	a.str_odv,
	a.str_proc, 
	a.id_pon_pred_odkup,
	a.SUM_BOD_ODPLATA, 
	a.SUM_BOD_DAV, 
	a.SUM_NEPLAC_TER, 
	a.SUM_ZOBR, 
	a.veljavna_do,
	pog.nacin_leas,
	 pog.opcija, 
	dbo.gfn_xchange(dbo.gfn_getnewtec(pog.id_tec), pog.varscina, pog.id_tec, a.datum_ponudbe) as varscina, 
	dbo.gfn_Nacin_leas_HR(pog.nacin_leas) as tip_leas,
	CASE WHEN dbo.gfn_Nacin_leas_HR(pog.nacin_leas) IN ('FF','F1','ZP') THEN 1 ELSE 0 END AS PDV_u_rati, 
	pog.pred_naj, 
(select '999-' + a.id_kupca + '-' + pog.id_sklic + dbo.gfn_CalculateControlDigit('999-'+a.id_kupca+'-'+pog.id_sklic)) as sklic_new, 
	par.naz_kr_kup, 
	par.id_poste_sed, 
	par.mesto_sed, 
	par.ulica_sed, 
	par.vr_osebe, 
	pon_davek.davek as pon_davek,
	opr.se_regis,
	CASE WHEN dbo.gfn_Nacin_leas_HR(pog.nacin_leas) IN ('FF','F1','ZP') THEN pog_davek.davek ELSE CAST(0 as Decimal(18,2)) END AS pog_davek, 
	tec.id_val AS id_val, tec.naziv as tec_naz,
	CASE WHEN opr.se_regis = '*' THEN zreg.let_pro ELSE zner.let_pro END AS let_pro, 
	CASE WHEN opr.se_regis = '*' THEN zreg.st_sas ELSE zner.ser_st END AS sasija,
	CASE WHEN opr.se_regis = '*' THEN zreg.reg_stev ELSE '' END AS reg_stev, 
	vtr.id_terj as opc_id,
	a.future_robresti,
	RTRIM(LTRIM(pog.kategorija1)) as kategorija1,
	dbo.gfn_GetOpcSt_dok(a.id_cont,pog.nacin_leas) as opcija_st_dok,
	CASE WHEN a.str_proc > 0 OR a.str_man > 0 THEN 1 ELSE 0 END AS print_mstr,
	ns.data as logo,
	dbo.gfn_BarCode2(a.id_pon_pred_odkup,'PON_PRED_ODKUP','Z04') as gmi_barcode_value,
	CASE WHEN a.id_kupca <> pog.id_kupca THEN 0 ELSE 1 END AS print_otv,
	par.naziv1_kup,
	par.naziv2_kup,
	CASE WHEN a.dat_izr IS NULL THEN '' ELSE CONVERT(VARCHAR, a.dat_izr, 104) END AS dat_izr,
	ddv.id_dav_st as xdavek,
	IIF(ISNULL(a.id_dav_st, '') = '', pog_davek.davek, pon_davek.davek) AS xdavek1,
	oreg.naziv as naziv_opreme,
	zn.naziv as naziv_znamke,
	dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),a.se_varsc, pog.id_tec,getdate()) as se_varsc,
	zreg.tip,
	zreg.st_sas,
	a.razlog_pred_odk,
	CASE WHEN LTRIM(RTRIM(@ponudba_flag)) = 2 THEN 1 ELSE 0 END AS ponudba_flag,
	SUM_BOD_ODPLATA_EUR_MIG.res_print as SUM_BOD_ODPLATA_RES_PRINT,
	ROUND(SUM_BOD_ODPLATA_EUR_MIG.res_amount,2) as SUM_BOD_ODPLATA_RES_AMOUNT,
	SUM_BOD_ODPLATA_EUR_MIG.res_exch as SUM_BOD_ODPLATA_RES_EXCH,
	SUM_BOD_ODPLATA_EUR_MIG.res_id_val as SUM_BOD_ODPLATA_ID_VAL,
	se_varsc_EUR_MIG.res_print as se_varsc_RES_PRINT,
	ROUND(se_varsc_EUR_MIG.res_amount,2) as se_varsc_RES_AMOUNT,
	se_varsc_EUR_MIG.res_exch as se_varsc_RES_EXCH,
	se_varsc_EUR_MIG.res_id_val as se_varsc_ID_VAL,
	str_odv_EUR_MIG.res_print as str_odv_RES_PRINT,
	ROUND(str_odv_EUR_MIG.res_amount,2) as str_odv_RES_AMOUNT,
	str_odv_EUR_MIG.res_exch as str_odv_RES_EXCH,
	str_odv_EUR_MIG.res_id_val as str_odv_ID_VAL,
	str_man_EUR_MIG.res_print as str_man_RES_PRINT,
	ROUND(str_man_EUR_MIG.res_amount,2) as str_man_RES_AMOUNT,
	str_man_EUR_MIG.res_exch as str_man_RES_EXCH,
	str_man_EUR_MIG.res_id_val as str_man_ID_VAL,
	dodatne_ter_EUR_MIG.res_print as dodatne_ter_RES_PRINT,
	ROUND(dodatne_ter_EUR_MIG.res_amount,2) as dodatne_ter_RES_AMOUNT,
	dodatne_ter_EUR_MIG.res_exch as dodatne_ter_RES_EXCH,
	dodatne_ter_EUR_MIG.res_id_val as dodatne_ter_ID_VAL,
	future_robresti_EUR_MIG.res_print as future_robresti_RES_PRINT,
	ROUND(future_robresti_EUR_MIG.res_amount,2) as future_robresti_RES_AMOUNT,
	future_robresti_EUR_MIG.res_exch as future_robresti_RES_EXCH,
	future_robresti_EUR_MIG.res_id_val as future_robresti_ID_VAL,
	IIF(DATEPART(MONTH, a.datum_ponudbe) = '12' AND DATEPART(YEAR, a.datum_ponudbe) = '2022', 1, 0) AS datum_txt,
	-- PRODAJNA CIJENA ZA KUPCA -------------------------------------------
	a.str_sod as vrijednost_procjene,
	(a.str_sod - temp.ppmv)/(1+(ISNULL(pon_davek.davek, 0)/100)) as osnovica_bez_pdv,
	(a.str_sod - temp.ppmv)/(1+(ISNULL(pon_davek.davek, 0)/100)) * (ISNULL(pon_davek.davek, 0)/100) as pdv_od_osnovice,
	a.str_vrac_kas as popust_prodajna_cijena, 
	((a.str_sod - temp.ppmv)/(1+(ISNULL(pon_davek.davek, 0)/100))) * (1 - a.str_vrac_kas/100) as popust_osnovica_bez_pdv,
	(((a.str_sod - temp.ppmv)/(1+(ISNULL(pon_davek.davek, 0)/100))) * (1 - a.str_vrac_kas/100)) * (ISNULL(pon_davek.davek, 0)/100) as popust_pdv_od_osnovice,
	temp.ppmv
From dbo.PON_PRED_ODKUP a
INNER JOIN dbo.pogodba pog on a.id_cont = pog.id_cont
INNER JOIN dbo.partner par on a.id_kupca = par.id_kupca
LEFT JOIN dbo.dav_stop pon_davek on a.id_dav_st = pon_davek.id_dav_st
INNER JOIN dbo.dav_stop pog_davek on pog.id_dav_st = pog_davek.id_dav_st
INNER JOIN dbo.dav_stop ddv on 1=1 and ddv.sif_dav = 'DDV'
INNER JOIN dbo.tecajnic tec on a.id_tec = tec.id_tec
LEFT JOIN dbo.zap_reg zreg on a.id_cont = zreg.id_cont
LEFT JOIN dbo.zap_ner zner on a.id_cont = zner.id_cont
LEFT JOIN dbo.znamke zn on zreg.znamka = zn.id_znamke
INNER JOIN dbo.vrst_opr opr on pog.id_vrste = opr.id_vrste
LEFT JOIN dbo.VRSTE_OPR_REG oreg on zreg.vrsta = oreg.id_vrste
LEFT JOIN dbo.vrst_ter vtr on 1=1 And vtr.sif_terj = 'OPC'
LEFT JOIN dbo.nova_resources ns on pog.kategorija1=ns.id_resource
LEFT JOIN @temp temp ON 1 = 1
--sum_nezap_ter,se_varsc,str_odv,str_man,dodatne_ter
OUTER APPLY dbo.pfn_gmc_xchangeEurMigrationPrintouts2(a.id_tec, a.SUM_BOD_ODPLATA, a.datum_ponudbe, par.vr_osebe,a.id_cont) as SUM_BOD_ODPLATA_EUR_MIG
OUTER APPLY dbo.pfn_gmc_xchangeEurMigrationPrintouts2(a.id_tec, dbo.gfn_xchange(a.id_tec, pog.varscina, pog.id_tec, a.datum_ponudbe), a.datum_ponudbe, par.vr_osebe,a.id_cont) as se_varsc_EUR_MIG
OUTER APPLY dbo.pfn_gmc_xchangeEurMigrationPrintouts2(a.id_tec, a.str_odv, a.datum_ponudbe, par.vr_osebe,a.id_cont) as str_odv_EUR_MIG
OUTER APPLY dbo.pfn_gmc_xchangeEurMigrationPrintouts2(a.id_tec, a.str_man, a.datum_ponudbe, par.vr_osebe,a.id_cont) as str_man_EUR_MIG
OUTER APPLY dbo.pfn_gmc_xchangeEurMigrationPrintouts2(a.id_tec, a.dodatne_ter, a.datum_ponudbe, par.vr_osebe,a.id_cont) as dodatne_ter_EUR_MIG
OUTER APPLY dbo.pfn_gmc_xchangeEurMigrationPrintouts2(a.id_tec, a.future_robresti, a.datum_ponudbe, par.vr_osebe,a.id_cont) as future_robresti_EUR_MIG
Where a.id_pon_pred_odkup = @id_pon_pred_otkup