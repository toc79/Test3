SELECT a.ID_FAKT, a.ID_KUPCA, a.ID_CONT, a.DATUM_DOK, a.DAT_ZAP, a.DDV_DATE, a.DDV_ID, a.ST_DOK, 
	a.VEZA, a.GLAVA, a.REP, a.ID_TEC, a.ID_TERJ, a.ID_DAV_ST, a.PROC_DAV, a.ZA_PLACILO as PLACILO_VAL, 
	dbo.gfn_xchange('000', a.ZA_PLACILO, a.id_tec, a.datum_dok) as ZA_PLACILO,
	dbo.gfn_xchange('000', a.NETO, a.id_tec, a.datum_dok) as NETO, 
	dbo.gfn_xchange('000', a.MARZA,  a.id_tec, a.datum_dok) as MARZA, 
	dbo.gfn_xchange('000', a.OSNOVA_DDV, a.id_tec, a.datum_dok) as OSNOVA_DDV, 
	dbo.gfn_xchange('000', a.DAVEK, a.id_tec, a.datum_dok) as DAVEK, 
	dbo.gfn_xchange('000', a.NEOBDAVCEN, a.id_tec, a.datum_dok)as NEOBDAVCEN, 
	dbo.gfn_xchange('000', a.OPROSCEN,  a.id_tec, a.datum_dok) as OPROSCEN, 
	dbo.gfn_xchange('000', a.ROBRESTI, a.id_tec, a.datum_dok)as ROBRESTI,
	a.VNESEL, a.id_klavzule, a.int_opombe, a.narocnik,
	b.polni_naz, b.ulica, b.ulica_sed, b.mesto, b.mesto_sed,
	b.id_poste, b.id_poste_sed, b.dav_stev, b.emso, b.vr_osebe, b.direktor,
	c.opis,
	c.id_fak_pos,
	dbo.gfn_xchange('000', c.znesek_net, a.id_tec, a.datum_dok) as znesek_net, 
	c.proc_mstr,
	dbo.gfn_xchange('000', c.mstr, a.id_tec, a.datum_dok) as mstr, 
	dbo.gfn_xchange('000', c.znes_dav,  a.id_tec, a.datum_dok) as znes_dav,
	dbo.gfn_xchange('000', c.robresti, a.id_tec, a.datum_dok) as robresti_fak_pos, 	
	dbo.gfn_xchange('000', c.skupaj, a.id_tec, a.datum_dok) as skupaj, 
	dbo.gfn_TransformDDV_ID_HR(a.ddv_id, a.datum_dok) as ddv_id_hr, 
	f.id_pog, f.sklic, g.id_val, g.naziv,
	KS.klavzula,
	RO.dat_vnosa as ro_dat_vnosa, 
	RO.izdal as ro_izdal, 
	CASE WHEN a.id_kupca <> f.id_kupca THEN '998-' + a.id_kupca + '-' + f.id_sklic + dbo.tfn_GetControlNum('998-' + a.id_kupca + '-' + f.id_sklic) ELSE f.sklic END AS SKLIC_NEW,
	CASE WHEN LEN(RTRIM(b.dav_stev)) <> 11 THEN 0 ELSE 1 END AS PRNT_OIB,
	CASE WHEN a.id_dav_st = '00' AND CHARINDEX(d.sif_terj,'SFIN,MSTR,STRO')>0 AND CHARINDEX(e.tip_leas,'F1,ZP')>0 OR a.id_terj = '50' THEN 1 ELSE 0 END AS PRNT_CLPDV,
	CASE WHEN a.paket IS NULL OR a.paket = ' ' THEN 0 ELSE 1 END AS PRINT_PAK,
	CASE WHEN a.ddv_date > '20110101' THEN 0 ELSE 1 END AS PRNT_EMSO,
	CASE WHEN a.ddv_id IS NOT NULL THEN 1 ELSE 0 END as is_racun,
	CASE WHEN a.ddv_date < ISNULL(s.val, '20500101') THEN 1 ELSE 0 END as print_r1,
	CASE WHEN a.marza>0 THEN 1 ELSE 0 END AS PRINT_MSTR,
CASE WHEN (SELECT COUNT(1) from fak_pos where id_fakt = (select top 1 id_fakt FROM fakture WHERE ddv_id=@id) AND id_post='39')=0 THEN 0 else 1 END AS PRINT_PF_TEXT,
	usr.user_id as ro_izdal_id,
dbo.pfn_gmc_hub3_BarCode(b.id_kupca, 'HRK', dbo.gfn_xchange('000', a.ZA_PLACILO, a.id_tec, a.datum_dok), 'HR01', RTRIM('01'+' '+CASE WHEN a.id_kupca <> f.id_kupca THEN '998-' + a.id_kupca + '-' + f.id_sklic + dbo.tfn_GetControlNum('998-' + a.id_kupca + '-' + f.id_sklic) ELSE f.sklic END ), 'OTHR', LTRIM(RTRIM(RO.opisdok))) as barkod_value
FROM dbo.FAKTURE a
INNER JOIN dbo.partner b ON a.id_kupca = b.id_kupca
INNER JOIN dbo.fak_pos c ON a.id_fakt = c.id_fakt
INNER JOIN dbo.vrst_ter d ON a.id_terj = d.id_terj
INNER JOIN dbo.pogodba f ON a.id_cont = f.id_cont
INNER JOIN dbo.tecajnic g ON a.id_tec = g.id_tec
LEFT JOIN dbo.klavzule_sifr KS ON KS.id_klavzule = a.id_klavzule
LEFT JOIN dbo.rac_out RO ON RO.ddv_id = a.ddv_id
LEFT JOIN dbo.custom_settings s on s.code = 'Nova.Reports.Print_R1'
LEFT JOIN (Select nacin_leas, 
	CASE WHEN tip_knjizenja = 1 THEN 'OL'
					WHEN tip_knjizenja = 2 AND LEAS_KRED = 'L' AND FINBRUTO = 0 THEN 'FF'
					WHEN tip_knjizenja = 2 AND LEAS_KRED = 'L' AND FINBRUTO = 1 THEN 'F1'
					WHEN tip_knjizenja = 2 AND LEAS_KRED = 'K' THEN 'ZP'
					ELSE 'XX' END as tip_leas
					From dbo.nacini_l 
			)e on f.nacin_leas = e.nacin_leas
LEFT JOIN dbo.users usr on RO.izdal = usr.username
WHERE a.ddv_id = @id



