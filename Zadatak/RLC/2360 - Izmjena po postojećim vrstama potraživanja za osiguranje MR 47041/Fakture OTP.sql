SELECT a.ID_FAKT, a.ID_KUPCA, a.ID_CONT, a.DATUM_DOK, a.DAT_ZAP, a.DDV_DATE, a.DDV_ID, a.ST_DOK, 
	a.VEZA, a.GLAVA, a.REP, a.ID_TEC, a.ID_TERJ, a.ID_DAV_ST, a.PROC_DAV, a.ZA_PLACILO as PLACILO_VAL, 
	ra.debit as ra_debit, ra.debit_davek as ra_debit_davek, ra.debit_neto as ra_debit_neto, ra.brez_davka as ra_brez_davka, ra.neobdav as ra_neobdavcen,
	a.VNESEL, a.id_klavzule, a.int_opombe, a.narocnik, ks.klavzula,
	b.naz_kr_kup, b.ulica, b.ulica_sed, b.mesto, b.mesto_sed,
	b.id_poste, b.id_poste_sed, b.dav_stev, b.emso, b.vr_osebe, b.direktor,
	c.opis, c.id_fak_pos, 
	dbo.gfn_xchange('000', c.znesek_net, a.id_tec, a.datum_dok) as znesek_net, 
	c.proc_mstr,
	dbo.gfn_xchange('000', c.mstr, a.id_tec, a.datum_dok) as mstr, 
	CASE WHEN c.dav_tip='D' THEN dbo.gfn_xchange('000', (c.znesek_net+c.mstr), a.id_tec, a.datum_dok)*(a.proc_dav/100) ELSE 0 END AS znes_dav,
	dbo.gfn_xchange('000', c.znesek_net, a.id_tec, a.datum_dok)+dbo.gfn_xchange('000', c.mstr, a.id_tec, a.datum_dok)+dbo.gfn_xchange('000', c.robresti, a.id_tec, a.datum_dok)+CASE WHEN c.dav_tip='D' THEN dbo.gfn_xchange('000', (c.znesek_net+c.mstr), a.id_tec, a.datum_dok)*(a.proc_dav/100) ELSE 0 END AS skupaj,
	f.id_pog, f.sklic, g.id_val, g.naziv, ra.izdal,
	dbo.gfn_transformDDV_ID_HR(a.ddv_id,a.datum_dok) as Fis_BrRac,
	RTRIM(CONVERT(varchar(50), ra.dat_vnosa,104) + '. '+ CONVERT(VARCHAR(50), ra.dat_vnosa,108)) AS Dat_Izdavanja,
	CASE WHEN a.id_kupca <> f.id_kupca THEN '998-' + a.id_kupca + '-' + f.id_sklic + dbo.tfn_GetControlNum('998-' + a.id_kupca + '-' + f.id_sklic) ELSE f.sklic END AS SKLIC_NEW,
	CASE WHEN a.id_dav_st = '00' AND CHARINDEX(d.sif_terj,'SFIN,MSTR,STRO')>0 AND CHARINDEX(e.tip_leas,'F1,ZP')>0 OR a.id_terj = '50' THEN 1 ELSE 0 END AS PRNT_CLPDV,
	CASE WHEN LEN(RTRIM(b.dav_stev)) <> 11 THEN 0 ELSE 1 END AS PRNT_OIB,	
	CASE WHEN a.paket IS NULL OR a.paket = ' ' THEN 0 ELSE 1 END AS PRNT_PAK,
	CASE WHEN a.ddv_date > '20110101' THEN 0 ELSE 1 END AS PRNT_EMSO,
	CASE WHEN a.datum_dok < '20130101' THEN 0 ELSE 1 END AS PRINT_DDV_HR,
	CASE WHEN a.datum_dok < ISNULL(i.val, '20130701') THEN 1 ELSE 0 END as print_r1,
	CASE WHEN a.datum_dok > ISNULL(j.val, '20130630') THEN 1 ELSE 0 END as print_PIB,
	usr.user_desc,
	k.se_regis,
	a.robresti,
	CASE WHEN f.nacin_leas = 'F3' and a.id_terj  in ('25','26') THEN 1 ELSE 0 END as print_PPOM,
	CASE WHEN a.id_terj IN ('39','40','41','43','44','45','46','48','63','65') AND a.marza > 0 THEN 1 ELSE 0 END AS print_Marza,
	CASE WHEN a.id_terj = '26' THEN 1 ELSE 0 END AS rabljeno
FROM dbo.FAKTURE a
INNER JOIN dbo.partner b ON a.id_kupca = b.id_kupca
INNER JOIN dbo.fak_pos c ON a.id_fakt = c.id_fakt
INNER JOIN dbo.vrst_ter d ON a.id_terj = d.id_terj
INNER JOIN dbo.pogodba f ON a.id_cont = f.id_cont
INNER JOIN dbo.tecajnic g ON a.id_tec = g.id_tec
LEFT JOIN dbo.rac_out ra ON a.ddv_id = ra.ddv_id
LEFT JOIN dbo.klavzule_sifr ks ON ks.id_klavzule = a.id_klavzule
left join dbo.custom_settings i on code='Nova.Reports.Print_R1'
INNER JOIN dbo.Users usr ON ra.izdal = usr.username
left join dbo.custom_settings j on j.code = 'Nova.Reports.Print_PIB'
LEFT JOIN (Select nacin_leas, 
	CASE WHEN tip_knjizenja = 1 THEN 'OL'
					WHEN tip_knjizenja = 2 AND LEAS_KRED = 'L' AND FINBRUTO = 0 THEN 'FF'
					WHEN tip_knjizenja = 2 AND LEAS_KRED = 'L' AND FINBRUTO = 1 THEN 'F1'
					WHEN tip_knjizenja = 2 AND LEAS_KRED = 'K' THEN 'ZP'
					ELSE 'XX' END as tip_leas
					From dbo.nacini_l 
			)e on f.nacin_leas = e.nacin_leas
LEFT JOIN dbo.vrst_opr k on f.id_vrste=k.id_vrste
WHERE a.ddv_id = @id
ORDER BY c.id_fak_pos