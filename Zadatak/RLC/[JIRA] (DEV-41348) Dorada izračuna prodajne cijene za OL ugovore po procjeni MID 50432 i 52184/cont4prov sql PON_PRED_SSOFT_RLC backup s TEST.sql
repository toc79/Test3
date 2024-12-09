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
	Case when dbo.gfn_Nacin_leas_HR(pog.nacin_leas) NOT IN ('FF','F1','ZP') Then a.str_man else a.str_man + (a.str_man*ddv.id_dav_st/100) End as str_man_s_pdv,
	a.str_man,
	a.str_odob_lj, 
	Case when dbo.gfn_Nacin_leas_HR(pog.nacin_leas) NOT IN ('FF','F1','ZP') Then a.str_odv else a.str_odv + (a.str_odv*ddv.id_dav_st/100) End as str_odv_s_pdv,
	a.str_odv,
	a.str_proc, 
	a.str_sod, 
	a.str_vrac_kas, 
	a.id_pon_pred_odkup,
	a.SUM_BOD_ODPLATA, 
	a.SUM_BOD_DAV, 
	a.SUM_NEPLAC_TER, 
	a.SUM_ZOBR, 
	a.veljavna_do,
	pog.nacin_leas,
	 pog.opcija, 
	dbo.gfn_xchange(a.id_tec, pog.varscina, pog.id_tec, GETDATE()) as varscina, 
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
	CASE WHEN opr.se_regis = '*' THEN zreg.let_pro ELSE zner.let_pro END AS let_pro, CASE WHEN opr.se_regis = '*' THEN zreg.st_sas ELSE zner.ser_st END AS sasija,
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
	pog.id_val as pog_id_val,
	pog_tec.naziv as naziv_tecaja_pog,
	IIF(DATEPART(MONTH, a.datum_ponudbe) = '12' AND DATEPART(YEAR, a.datum_ponudbe) = '2022', 1, 0) AS datum_txt,
	RTRIM(LTRIM(gr_barcode.document_id)) +';'+RTRIM(LTRIM(pog.id_pog))+';'++RTRIM(LTRIM(a.id_kupca))+';'+CAST(FORMAT(GETDATE(), 'yyyyMMddHHmmss') AS CHAR(14)) as barcode_rlc
From dbo.PON_PRED_ODKUP a
INNER JOIN dbo.pogodba pog on a.id_cont = pog.id_cont
INNER JOIN dbo.partner par on a.id_kupca = par.id_kupca
LEFT JOIN dbo.dav_stop pon_davek on a.id_dav_st = pon_davek.id_dav_st
INNER JOIN dbo.dav_stop pog_davek on pog.id_dav_st = pog_davek.id_dav_st
INNER JOIN dbo.dav_stop ddv on 1=1 and ddv.sif_dav = 'DDV'
INNER JOIN dbo.tecajnic tec on a.id_tec = tec.id_tec
INNER JOIN dbo.tecajnic pog_tec on a.id_tec = pog_tec.id_tec
LEFT JOIN dbo.zap_reg zreg on a.id_cont = zreg.id_cont
LEFT JOIN dbo.zap_ner zner on a.id_cont = zner.id_cont
INNER JOIN dbo.vrst_opr opr on pog.id_vrste = opr.id_vrste
LEFT JOIN dbo.vrst_ter vtr on 1=1 And vtr.sif_terj = 'OPC'
LEFT JOIN dbo.nova_resources ns on pog.kategorija1=ns.id_resource
OUTER APPLY(SELECT val_char AS document_id FROM dbo.gfn_g_register_active_v('BARCODE_REPORTS_RLHR','') WHERE id_key = 'PON_PRED_SSOFT_RLC') gr_barcode
Where a.id_pon_pred_odkup = @id