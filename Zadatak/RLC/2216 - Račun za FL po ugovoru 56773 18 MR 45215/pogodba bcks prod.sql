Select pog.dat_aktiv, pog.ddv_id, pog.id_cont, pog.id_dav_op, pog.id_kupca, pog.id_pog, 
	pog.nacin_leas, pog.pred_naj, pog.vr_sit, pog.sklic, pog.kk_memo, pog.ddv, pog.po_tecaju,
	dbo.gfn_Nacin_leas_HR(pog.nacin_leas) as tip_leas, pog.id_tec, pog.opombe, pog.naziv_tuje, 
	pog.opis_pred,
	tec.id_val,
	--RAC_OUT
	ro.dat_vnosa as ro_dat_vnosa, ro.izdal as ro_izdal, ro.debit_neto as ro_debit_neto, 
	ro.brez_davka as ro_brez_davka, ro.debit_davek as ro_debit_davek, ro.debit as ro_debit,
	ks.klavzula, vo.se_regis, vo.tip_opr, CAST(CASE WHEN vo.tip_opr = 'N' THEN 1 else 0 END as bit) as je_nekretnina,
	--PARTNER
	par.emso, par.id_poste, par.id_poste_sed, par.mesto, par.mesto_sed, par.naz_kr_kup, 
	par.ulica, par.ulica_sed, par.dav_stev, par.naziv1_kup, par.vr_osebe,
	--DOKUMENTACIJA
	ISNULL(dok.opombe,'') AS Dok_Opombe, ds.davek as ro_davek,
	--ZAP_REG
	zrvo.naziv as naziv_opr, zreg.vrsta, zreg.znamka, zreg.tip, zreg.st_sas, zreg.let_pro, zreg.barva, zreg.reg_stev, zreg.proizv_st, zreg.kubik,
	zreg.st_mot, zreg.ps_kw, zreg.st_kljuc, zreg.st_sedezev, COALESCE(zreg.dat_prev,zner.dat_prev,pog.dat_aktiv) as dat_prev,
	--OTHER STUFF
	dbo.gfn_transformDDV_ID_HR(pog.ddv_id,pog.dat_aktiv) as Fis_BrRac,
	RTRIM(CONVERT(varchar(50), ro.dat_vnosa,104) + '. ' + convert(varchar(50), ro.dat_vnosa,108)) as Dat_Izdavanja,
	CASE WHEN dbo.gfn_Nacin_leas_HR(pog.nacin_leas) = 'FF' THEN pp.dat_pdv ELSE NULL END AS dat_pdv,
	CASE WHEN pog.dat_aktiv < ISNULL(cust.val, '20130701') THEN 1 ELSE 0 END as print_r1,
	CASE WHEN LTRIM(RTRIM(par.ulica)) = LTRIM(RTRIM(par.ulica_sed)) THEN 0 ELSE 1 END AS print_sadr,
	CASE WHEN ISNULL(pog.naziv_tuje,'') = '' OR LTRIM(RTRIM(pog.naziv_tuje)) = ' ' THEN 0 ELSE 1 END AS print_kref,
	CASE WHEN LEN(RTRIM(par.dav_stev)) = 11 THEN 0 ELSE 1 END AS OIB_NOT_OK,
	CASE WHEN pog.dat_aktiv < '20100101' THEN 0 ELSE 1 END AS PRINT_DDV_HR,
	CASE WHEN par.vr_osebe = 'FO' or par.vr_osebe = 'F1' THEN 1 ELSE 0 END as je_FO,
	CASE WHEN vo.tip_opr = 'P' THEN 'Vrsta plovila:' ELSE 'Vrsta vozila:' END as txtTip,
	CASE WHEN vo.tip_opr = 'P' THEN 'Broj trupa:' ELSE 'Broj šasije:' END as txtTipSasije,
	COALESCE(grp.Value,'') as Print_izdao, COALESCE(grPrim.VALUE, gr.Value) as Print_veri,
	--DORADA PPOM
	CASE WHEN CHARINDEX(grPPOM.VALUE, pog.nacin_leas) > 0 THEN 1 ELSE 0 END AS PPOM
	--KRAJ DORADE
From dbo.pogodba pog
INNER JOIN dbo.partner par ON pog.id_kupca = par.id_kupca
INNER JOIN dbo.rac_out ro ON pog.ddv_id = ro.ddv_id
INNER JOIN dbo.dav_stop ds ON ro.id_dav_st = ds.id_dav_st
INNER JOIN dbo.vrst_opr vo ON pog.id_vrste = vo.id_vrste
INNER JOIN dbo.tecajnic tec ON pog.id_tec = tec.id_tec
LEFT JOIN dbo.klavzule_sifr ks on ks.id_klavzule = ro.id_klavzule
LEFT JOIN dbo.zap_reg zreg ON pog.id_cont = zreg.id_cont
LEFT JOIN dbo.zap_ner zner ON pog.id_cont = zner.id_cont
LEFT JOIN dbo.vrste_opr_reg zrvo ON zreg.vrsta = zrvo.id_vrste
LEFT JOIN (SELECT id_cont, MIN(dat_zap) As dat_pdv From dbo.planp where id_terj='00' Group by id_cont) pp on pog.id_cont = pp.id_cont
LEFT JOIN dbo.dokument dok ON dok.id_cont = pog.id_cont AND dok.id_obl_zav = 'NA' AND dok.ima = 1 
LEFT JOIN dbo.custom_settings cust on cust.code = 'Nova.Reports.Print_R1'
LEFT JOIN dbo.general_register grp ON grp.id_register = 'REPORT_SIGNATORY' AND grp.id_key = 'KK_FAKT'
LEFT JOIN dbo.general_register gr ON gr.id_register = 'REPORT_SIGNATORY' AND gr.id_key = 'KK_FAKTV'
LEFT JOIN dbo.general_register grPrim ON grPrim.id_register = 'REPORT_SIGNATORY' AND grPrim.id_key = ro.izdal
LEFT JOIN dbo.general_register grPPOM on grPPOM.id_register = 'RLC Reporting list' AND grPPOM.neaktiven = 0 AND grPPOM.id_key = 'RLC_PPOM_NL'
Where pog.ddv_id = @id