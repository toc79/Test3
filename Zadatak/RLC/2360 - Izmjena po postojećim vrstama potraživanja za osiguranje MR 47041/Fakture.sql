ispis je prilagođen prikazu da marža ide samo kada je jedna stavka. Sada kada su dvije treba podesiti da se ispravno podesi kada su dvije stavke i jedn aje marža, a da se ne pokvari ispis za slučaj jedne stavke i marže na toj stavci

Naknada za obradu -
prefakturiranje troškovana OTPu je podešeno da se svaka stavka prikazuje u svojem redu 
znes_dav se izračunava 
CASE WHEN c.dav_tip='D' THEN dbo.gfn_xchange('000', (c.znesek_net+c.mstr), a.id_tec, a.datum_dok)*(a.proc_dav/100) ELSE 0 END AS znes_dav,

{Format("{0:N2}", Fakture.znesek_net_pdv)}

SELECT a.ID_FAKT, a.ID_KUPCA, a.ID_CONT, a.DATUM_DOK, a.DAT_ZAP, a.DDV_DATE, a.DDV_ID, a.ST_DOK, 
	a.VEZA, a.GLAVA, a.REP, a.ID_TEC, a.ID_TERJ, a.ID_DAV_ST, 
	CASE WHEN c.dav_tip = 'D' THEN a.PROC_DAV ELSE 0.00 END as PROC_DAV, 
	a.ZA_PLACILO as PLACILO_VAL, 
	dbo.gfn_xchange('000', a.ZA_PLACILO, a.id_tec, a.datum_dok) as ZA_PLACILO,
	dbo.gfn_xchange('000', a.NETO, a.id_tec, a.datum_dok) as NETO, 
	dbo.gfn_xchange('000', a.MARZA,  a.id_tec, a.datum_dok) as MARZA, 
	dbo.gfn_xchange('000', a.OSNOVA_DDV, a.id_tec, a.datum_dok) as OSNOVA_DDV, 
	dbo.gfn_xchange('000', a.DAVEK, a.id_tec, a.datum_dok) as DAVEK, 
	dbo.gfn_xchange('000', a.NEOBDAVCEN, a.id_tec, a.datum_dok)as NEOBDAVCEN, 
	dbo.gfn_xchange('000', a.OPROSCEN,  a.id_tec, a.datum_dok) as OPROSCEN, 
	a.VNESEL, a.id_klavzule, a.int_opombe, a.narocnik,
	b.naz_kr_kup, b.polni_naz, b.ulica, b.ulica_sed, b.mesto, b.mesto_sed,
	b.id_poste, b.id_poste_sed, b.dav_stev, b.emso, b.vr_osebe, b.direktor,
	c.opis,
	c.id_fak_pos,
	dbo.gfn_xchange('000', c.znesek_net, a.id_tec, a.datum_dok) as znesek_net,
	dbo.gfn_xchange('000', c.robresti, a.id_tec, a.datum_dok) as znesek_robresti,
	(dbo.gfn_xchange('000', c.znesek_net, a.id_tec, a.datum_dok))*h.davek/100 as znesek_net_pdv,
	c.proc_mstr,
	dbo.gfn_xchange('000', c.mstr, a.id_tec, a.datum_dok) as mstr,
	(dbo.gfn_xchange('000', c.mstr, a.id_tec, a.datum_dok))*h.davek/100 as mstr_pdv,
	dbo.gfn_xchange('000', c.znes_dav,  a.id_tec, a.datum_dok) as znes_dav, 
	dbo.gfn_xchange('000', c.skupaj, a.id_tec, a.datum_dok) as skupaj, 
	dbo.gfn_TransformDDV_ID_HR(a.ddv_id, a.datum_dok) as ddv_id_hr, 
	IsNull(TP_pog.id_pog, f.id_pog) as id_pog,
	IsNull(TP_pog.sklic, f.sklic) as sklic, g.id_val, g.naziv,
	KS.klavzula,
	RO.dat_vnosa as ro_dat_vnosa, 
	RO.izdal as ro_izdal, 
	RO.debit_neto as ro_debit_neto,
	RO.neobdav as ro_neobdav,
	CASE WHEN a.id_cont_third_party IS NULL 
		THEN
			CASE WHEN a.id_kupca <> f.id_kupca THEN '998-' + a.id_kupca + '-' + f.id_sklic + dbo.tfn_GetControlNum('998-' + a.id_kupca + '-' + f.id_sklic) ELSE f.sklic END
		ELSE 
			'999-' + TP_POG.id_kupca + '-' + TP_pog.id_sklic + dbo.tfn_GetControlNum('999-' + TP_pog.id_kupca + '-' + TP_pog.id_sklic)
		END	AS SKLIC_NEW,
	CASE WHEN LEN(RTRIM(b.dav_stev)) <> 11 THEN 0 ELSE 1 END AS PRNT_OIB,
	CASE WHEN a.id_dav_st = '00' AND CHARINDEX(d.sif_terj,'SFIN,MSTR,STRO')>0 AND CHARINDEX(e.tip_leas,'F1,ZP')>0 OR a.id_terj = '50' THEN 1 ELSE 0 END AS PRNT_CLPDV,
	CASE WHEN a.paket IS NULL OR a.paket = ' ' THEN 0 ELSE 1 END AS PRINT_PAK,
	CASE WHEN a.DDV_DATE > '20110101' THEN 0 ELSE 1 END AS PRNT_EMSO,
	CASE WHEN a.ddv_id IS NOT NULL THEN 1 ELSE 0 END as is_racun,
	CASE WHEN a.DDV_DATE < '20130101' then 0 else 1 end as PRINT_DDV_HR,
	CASE WHEN a.DDV_DATE < ISNULL(s.val, '20500101') THEN 1 ELSE 0 END as print_r1,
	CASE WHEN a.marza>0 THEN 1 ELSE 0 END AS PRINT_MSTR, 
	CASE WHEN b.vr_osebe = 'FO' or b.vr_osebe = 'F1' THEN 1 ELSE 0 END as je_FO,
	op.se_regis,
	CASE WHEN op.se_regis = '*' THEN 1 Else 0 END as bool_se_regis,
	COALESCE(grp.value, '') as Print_izdao,
	COALESCE(grPrim.value, gr.value, '') AS Print_veri,
	dbo.pfn_gmc_hub3_BarCode(a.id_kupca, n.dom_valuta, a.za_placilo, 'HR01', RTRIM(f.sklic), 'OTHR', LTRIM(RTRIM(ro.opisdok))) as barkod_value
FROM dbo.FAKTURE a
INNER JOIN dbo.partner b ON a.id_kupca = b.id_kupca
INNER JOIN dbo.fak_pos c ON a.id_fakt = c.id_fakt
INNER JOIN dbo.vrst_ter d ON a.id_terj = d.id_terj
INNER JOIN dbo.pogodba f ON a.id_cont = f.id_cont
INNER JOIN dbo.tecajnic g ON a.id_tec = g.id_tec
INNER JOIN dbo.dav_stop h ON a.id_dav_st = h.id_dav_st
LEFT JOIN dbo.prev_pog pr ON IsNull(a.id_cont_third_party, a.id_cont)= pr.POG_PO AND LTRIM(RTRIM(pr.Opomba)) = 'Fiktivni ugovor'
LEFT JOIN dbo.pogodba TP_pog ON a.id_cont_third_party = TP_pog.id_cont
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
LEFT JOIN dbo.VRST_OPR op on f.id_vrste = op.id_vrste
LEFT JOIN (Select id_cont, MAX(id_zapo) as id_zapo from dbo.gv_Zapisniki group by id_cont) zap on IsNull(pr.pog_prej, f.id_cont) = zap.id_cont
LEFT JOIN dbo.GENERAL_REGISTER gr ON gr.ID_REGISTER = 'REPORT_SIGNATORY' and gr.id_key = 'FAKTUREV' AND gr.neaktiven = 0
LEFT JOIN dbo.GENERAL_REGISTER grp ON grp.ID_REGISTER = 'REPORT_SIGNATORY' and grp.id_key = 'FAKTURE' AND gr.neaktiven = 0
LEFT JOIN dbo.GENERAL_REGISTER grPrim ON grPrim.ID_REGISTER = 'REPORT_SIGNATORY' and grPrim.id_key = RO.izdal
JOIN dbo.nastavit n ON 1 = 1
WHERE a.ddv_id = @id