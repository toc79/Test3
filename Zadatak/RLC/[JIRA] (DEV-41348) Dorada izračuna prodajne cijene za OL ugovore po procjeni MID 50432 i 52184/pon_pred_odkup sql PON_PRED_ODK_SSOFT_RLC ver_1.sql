DECLARE @id1 VARCHAR(30), @id2 char(1)
SET @id1 = CAST(SUBSTRING(@id, 0, CHARINDEX(';',@id)) AS VARCHAR(20))
SET @id2 = CAST(SUBSTRING(@id, CHARINDEX(';',@id)+1, LEN(RTRIM(@id))) AS CHAR(1))

DECLARE @XML AS xml = (SELECT REPLACE(CAST(xml_detail AS NVARCHAR(MAX)),'<?xml version="1.0" encoding="utf-16"?>','') FROM dbo.PON_PRED_ODKUP WHERE id_pon_pred_odkup = @id1)

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

SELECT
	--dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()), --nema naziva kolone pa sam zakomentirao
	@id2 AS id2,
	ppo.id_pon_pred_odkup, ppo.id_cont,
	par.id_kupca, LTRIM(RTRIM(par.naz_kr_kup)) AS naz_kr_kup, LTRIM(RTRIM(par.ulica_sed)) AS ulica_sed, LTRIM(RTRIM(par.id_poste_sed)) AS id_poste_sed, LTRIM(RTRIM(par.mesto_sed)) AS mesto_sed,
	ISNULL(LTRIM(RTRIM(pog.id_pog)),'') AS id_pog, 
	ISNULL(LTRIM(RTRIM(pog.pred_naj)),'') AS pred_naj,
	CASE WHEN vo.se_regis = '*' THEN ISNULL(LTRIM(RTRIM(zr.st_sas)),'') ELSE ISNULL(LTRIM(RTRIM(nr.ser_st)),'') END AS st_sas, 
	ISNULL(LTRIM(RTRIM(zr.reg_stev)),'') AS reg_stev, 
	CASE WHEN vo.se_regis = '*' THEN ISNULL(LTRIM(RTRIM(zr.let_pro)),'') ELSE ISNULL(LTRIM(RTRIM(nr.let_pro)),'') END AS let_pro,
	CASE WHEN vo.se_regis = '*' THEN ISNULL(LTRIM(RTRIM(vor.naziv)),'') ELSE ISNULL(LTRIM(RTRIM(vo.naziv)),'') END  AS vor_naziv,
	tec.id_val, tec.naziv AS tecaj,
	LTRIM(RTRIM(u.user_desc)) AS user_desc, 
	LTRIM(RTRIM(u.phone)) AS phone,
	ISNULL(ds.davek, 0) AS davek,
	temp.ppmv, temp.zam_obr, temp.net_val_ol,
	IIF(ppo.dat_izr IS NOT NULL, CONVERT(VARCHAR, ppo.dat_izr, 104), '') AS dat_izr,
	IIF(dbo.gfn_Nacin_leas_HR(pog.nacin_leas) = 'OL', 'operativni', 'financijski') AS naz_leas,
	IIF(dbo.gfn_Nacin_leas_HR(pog.nacin_leas) = 'OL', 1, 0) AS tip_leas,
	IIF(DATEPART(MONTH, ppo.datum_ponudbe) = '12' AND DATEPART(YEAR, ppo.datum_ponudbe) = '2022', 1, 0) AS datum_txt,
		-- PRODAJNA CIJENA ZA KUPCA -------------------------------------------
	ppo.str_sod as vrijednost_procjene,
	(ppo.str_sod - temp.ppmv)/(1+(ISNULL(ds.davek, 0)/100)) as osnovica_bez_pdv,
	(ppo.str_sod - temp.ppmv)/(1+(ISNULL(ds.davek, 0)/100)) * (ISNULL(ds.davek, 0)/100) as pdv_od_osnovice,
	ppo.str_vrac_kas as popust_prodajna_cijena, 
	((ppo.str_sod - temp.ppmv)/(1+(ISNULL(ds.davek, 0)/100))) * (1 - ppo.str_vrac_kas/100) as popust_osnovica_bez_pdv,
	(((ppo.str_sod - temp.ppmv)/(1+(ISNULL(ds.davek, 0)/100))) * (1 - ppo.str_vrac_kas/100)) * (ISNULL(ds.davek, 0)/100) as popust_pdv_od_osnovice,
	ppo.dodatne_ter,								
	---------------------------------------------------------------------------------------------------------------------------------------------------
	temp.osnova + IIF(nl.odstej_var = 0, 0, dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE())) + ppo.str_odv + ppo.str_man + IIF(dbo.gfn_Nacin_leas_HR(pog.nacin_leas) != 'OL', ((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),temp.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100)) + (((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100)) * (IIF(ISNULL(ppo.id_dav_st, '') = '', dsp.davek, ds.davek) / 100)), ((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100))) - temp.ppmv AS uk_brez_davek,
	---------------------------------------------------------------------------------------------------------------------------------------------------
	ROUND((temp.osnova + IIF(nl.odstej_var = 0, 0, dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE())) + ppo.str_odv + ppo.str_man + IIF(dbo.gfn_Nacin_leas_HR(pog.nacin_leas) != 'OL', ((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),temp.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100)) + (((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100)) * (IIF(ISNULL(ppo.id_dav_st, '') = '', ISNULL(dsp.davek, 0), ISNULL(ds.davek, 0)) / 100)), ((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100))) - temp.ppmv) * (ISNULL(ds.davek, 0) / 100) , 2) AS uk_davek,
	---------------------------------------------------------------------------------------------------------------------------------------------------
	(temp.osnova + IIF(nl.odstej_var = 0, 0, dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE())) + ppo.str_odv + ppo.str_man + IIF(dbo.gfn_Nacin_leas_HR(pog.nacin_leas) != 'OL', ((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),temp.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100)) + (((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100)) * (IIF(ISNULL(ppo.id_dav_st, '') = '', ISNULL(dsp.davek, 0), ISNULL(ds.davek, 0)) / 100)), ((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100))) - temp.ppmv) + ROUND((temp.osnova + IIF(nl.odstej_var = 0, 0, dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE())) + ppo.str_odv + ppo.str_man + IIF(dbo.gfn_Nacin_leas_HR(pog.nacin_leas) != 'OL', ((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100)) + (((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100)) * (IIF(ISNULL(ppo.id_dav_st, '') = '', ISNULL(dsp.davek, 0), ISNULL(ds.davek, 0)) / 100)), ((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100))) - temp.ppmv) * (ISNULL(ds.davek, 0) / 100) , 2) AS uk_s_davek,
	---------------------------------------------------------------------------------------------------------------------------------------------------
	(temp.osnova + IIF(nl.odstej_var = 0, 0, dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE())) + ppo.str_odv + ppo.str_man + IIF(dbo.gfn_Nacin_leas_HR(pog.nacin_leas) != 'OL', ((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),temp.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100)) + (((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100)) * (IIF(ISNULL(ppo.id_dav_st, '') = '', ISNULL(dsp.davek, 0), ISNULL(ds.davek, 0)) / 100)), ((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100))) - temp.ppmv) + ROUND((temp.osnova + IIF(nl.odstej_var = 0, 0, dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE())) + ppo.str_odv + ppo.str_man + IIF(dbo.gfn_Nacin_leas_HR(pog.nacin_leas) != 'OL', ((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100)) + (((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100)) * (IIF(ISNULL(ppo.id_dav_st, '') = '', ISNULL(dsp.davek, 0), ISNULL(ds.davek, 0)) / 100)), ((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100))) - temp.ppmv) * (ISNULL(ds.davek, 0) / 100) , 2) + temp.ppmv AS ukupno_plac,
	---------------------------------------------------------------------------------------------------------------------------------------------------
	UKUPNO_PLAC_EUR_MIG.res_print AS res_print_plac, UKUPNO_PLAC_EUR_MIG.res_amount AS res_amount_plac, UKUPNO_PLAC_EUR_MIG.res_exch AS res_exch_plac, UKUPNO_PLAC_EUR_MIG.res_id_val AS res_id_val_plac,
	---------------------------------------------------------------------------------------------------------------------------------------------------
	ROUND((IIF(dbo.gfn_Nacin_leas_HR(pog.nacin_leas) != 'OL', temp.net_val_fl + temp.regist, temp.neto + temp.ppmv + IIF(pog.nacin_leas = 'OR', 0, dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()))) * ppo.popust_proc/100) + ppo.str_izplac_zav,2) AS nakn_zatv,
	---------------------------------------------------------------------------------------------------------------------------------------------------
	ROUND(ppo.str_odob_lj * (1 + (IIF(ISNULL(ppo.id_dav_st, '') = '', ISNULL(dsp.davek, 0), ISNULL(ds.davek, 0)) / 100)), 2) AS ost_tros,
	---------------------------------------------------------------------------------------------------------------------------------------------------
	ROUND((IIF(dbo.gfn_Nacin_leas_HR(pog.nacin_leas) != 'OL', temp.net_val_fl + temp.regist, temp.neto + temp.ppmv + IIF(pog.nacin_leas = 'OR', 0, dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()))) * ppo.popust_proc/100) + ppo.str_izplac_zav,2) + temp.zam_obr + temp.net_val_ol + ROUND(ppo.str_odob_lj * (1 + (IIF(ISNULL(ppo.id_dav_st, '') = '', ISNULL(dsp.davek, 0), ISNULL(ds.davek, 0)) / 100)), 2) + ppo.dodatne_ter AS ukupno,
	---------------------------------------------------------------------------------------------------------------------------------------------------
	UKUPNO_EUR_MIG.res_print, UKUPNO_EUR_MIG.res_amount, UKUPNO_EUR_MIG.res_exch, UKUPNO_EUR_MIG.res_id_val,
	'kraj' AS kraj
FROM dbo.pon_pred_odkup ppo
LEFT JOIN dbo.partner par ON ppo.id_kupca = par.id_kupca
LEFT JOIN dbo.pogodba pog ON ppo.id_cont = pog.id_cont
LEFT JOIN dbo.zap_reg zr ON pog.id_cont = zr.id_cont
LEFT JOIN dbo.zap_ner nr ON pog.id_cont = nr.id_cont
LEFT JOIN dbo.VRST_OPR vo ON pog.id_vrste = vo.id_vrste
LEFT JOIN dbo.vrste_opr_reg vor ON zr.vrsta = vor.id_vrste
LEFT JOIN dbo.tecajnic tec ON ppo.id_tec = tec.id_tec
LEFT JOIN dbo.users u ON ppo.vnesel = u.username
LEFT JOIN dbo.dav_stop ds ON ppo.id_dav_st = ds.id_dav_st
LEFT JOIN dbo.nacini_l nl ON pog.nacin_leas = nl.nacin_leas
LEFT JOIN @temp temp ON 1 = 1
LEFT JOIN dbo.dav_stop dsp ON pog.id_dav_st = dsp.id_dav_st
---------------------------------------------------------------------------------------------------------------------------------------------------
OUTER APPLY dbo.pfn_gmc_xchangeEurMigrationPrintouts2(ppo.id_tec, (temp.osnova + IIF(nl.odstej_var = 0, 0, dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE())) + ppo.str_odv + ppo.str_man + IIF(dbo.gfn_Nacin_leas_HR(pog.nacin_leas) != 'OL', ((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100)) + (((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100)) * (IIF(ISNULL(ppo.id_dav_st, '') = '', ISNULL(dsp.davek, 0), ISNULL(ds.davek, 0)) / 100)), ((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100))) - temp.ppmv) + ROUND((temp.osnova + IIF(nl.odstej_var = 0, 0, dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),temp.varscina,pog.id_tec,GETDATE())) + ppo.str_odv  + ppo.str_man + IIF(dbo.gfn_Nacin_leas_HR(pog.nacin_leas) != 'OL', ((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100)) + (((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100)) * (IIF(ISNULL(ppo.id_dav_st, '') = '', ISNULL(dsp.davek, 0), ISNULL(ds.davek, 0)) / 100)), ((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100))) - temp.ppmv) * (ISNULL(ds.davek, 0) / 100) , 2) + temp.ppmv, ppo.datum_ponudbe, par.vr_osebe, ppo.id_cont) AS UKUPNO_PLAC_EUR_MIG
---------------------------------------------------------------------------------------------------------------------------------------------------
OUTER APPLY dbo.pfn_gmc_xchangeEurMigrationPrintouts2(ppo.id_tec, ROUND((IIF(dbo.gfn_Nacin_leas_HR(pog.nacin_leas) != 'OL', temp.net_val_fl + temp.regist, temp.neto + temp.ppmv + IIF(pog.nacin_leas = 'OR', 0, dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()))) * ppo.popust_proc/100) + ppo.str_izplac_zav,2) + temp.zam_obr + temp.net_val_ol + ROUND(ppo.str_odob_lj * (1 + (IIF(ISNULL(ppo.id_dav_st, '') = '', ISNULL(dsp.davek, 0), ISNULL(ds.davek, 0)) / 100)), 2) + ppo.dodatne_ter, ppo.datum_ponudbe, par.vr_osebe, ppo.id_cont)  AS UKUPNO_EUR_MIG
---------------------------------------------------------------------------------------------------------------------------------------------------
WHERE ppo.id_pon_pred_odkup = @id1