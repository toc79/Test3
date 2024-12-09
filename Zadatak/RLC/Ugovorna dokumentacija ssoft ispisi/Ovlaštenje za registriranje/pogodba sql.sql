DECLARE @id varchar(100)
SET @id = 56149 --55980 --56149

SELECT 
	a.id_pog,
	a.pred_naj,
	a.prv_obr,
	a.dat_sklen,
	a.id_val,
	a.ost_obr,
	a.id_dav_st,
	a.st_obrok,
	a.dovol_km,
	CAST(a.dovol_km AS int) AS dovol_km_int,
	a.cena_dkm,
	a.traj_naj,
	a.obr_mera,
	a.vr_val, a.vr_val_zac, 
	a.varscina,
	a.opcija,
	a.vnesel, dbo.gfn_GetUserDesc(a.vnesel) AS vnesel_desc
	, a.robresti_val
	, a.robresti_sit
	, a.dni_zap
	, CASE WHEN v.se_regis = '*' THEN 1 ELSE 0 END as print_se_regis,
	v.tip_opr,
	p.naziv1_kup as part_naziv1_kup,
	p.dav_stev as part_dav_stev,
	CASE WHEN LEN(ltrim(rtrim(p.dav_stev))) = 11 THEN 'OIB: '+p.dav_stev ELSE '' END as part_dav_stev_11,
	p.ulica_sed as part_ulica_sed,
	p.id_poste_sed as part_id_poste_sed,
	p.mesto_sed as part_mesto_sed,
	p.emso as part_emso,
	p.direktor as part_direktor,
	p.vr_osebe as part_vr_osebe,
	p.naz_kr_kup as part_naz_kr_kup,
	p.stev_reg as part_stev_reg,
	a.id_pon,
	c.dat_pon,
	c.plac_zac,
	c.opcija_p,
	c.varsc_p,
	c.prv_obr_p,
	c.st_predr,
	CASE WHEN c.dat_predr IS NULL THEN '' ELSE ' od '+CONVERT(varchar(10), c.dat_predr, 104) END AS dat_predr_txt,
	d.naz_kr_kup as dob_naz_kr_kup,
	d.dav_stev as dob_dav_stev,
	d.ulica_sed as dob_ulica_sed,
	d.id_poste_sed as dob_id_poste_sed,
	d.mesto_sed as dob_mesto_sed,
	d.emso as dob_emso,
	dbo.gfn_Nacin_leas_HR(a.nacin_leas) AS tip_leas,
	a.naziv_tuje,
	a.spl_pog
	, ISNULL(gv_DodStrPogodba_05.br_zapisa,0) AS gv_DodStrPogodba_br_zapisa 
From pogodba a
LEFT JOIN dbo.vrst_opr v ON a.id_vrste = v.id_vrste
LEFT JOIN dbo.partner p ON a.id_kupca = p.id_kupca
LEFT JOIN dbo.ponudba c ON a.id_pon = c.id_pon
LEFT JOIN dbo.partner d ON a.id_dob = d.id_kupca
LEFT JOIN (SELECT id_cont, count(*) br_zapisa FROM dbo.gv_DodStrPogodba WHERE id_vrst_dod_str='05' group by id_cont) gv_DodStrPogodba_05 ON a.id_cont = gv_DodStrPogodba_05.id_cont
WHERE a.id_cont= @id