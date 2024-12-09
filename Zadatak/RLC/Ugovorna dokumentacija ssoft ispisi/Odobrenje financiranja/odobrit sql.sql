DECLARE @id int
SET @id = 21448 --2486 --3729 ---2486

SELECT 	a.id_odobrit, a.id_doc, a.osnova, a.id_pon, a.nacin_leas, a.id_wf_document
	, a.id_tec, a.vec_ponudb, a.aktivna, a.id_vrste, a.pred_naj
	, a.id_kupca, a.referent, a.naziv_kup_pon, a.kupec_crna_lista, a.kupec_odobritev, a.kupec_zavrnitev
	--, a.id_dobavitelj, a.dobavitelj_crna_lista, a.dobavitelj_pogodb, a.obligoLH, a.obligoLH_vred
	, CONVERT(varchar(10), a.dat_pricak, 104) AS dat_pricak
	, a.opis_pred, a.vr_val, a.vr_val_val, a.vr_ocen_vred, a.vr_ocen_vred_val, a.vr_ocen_vred_tip, a.vr_ocen_vred_datum
	, a.MPC, a.MPC_val, a.letnik, a.ocena_tveganja, a.rizik_predmeta_financiranja, a.skupina_predmeta_financiranja
	--, a.kdo_provizija
	, a.plac_dob
	, CASE WHEN ltrim(rtrim(a.boniteta)) = '' THEN '0' ELSE ltrim(rtrim(a.boniteta)) END AS boniteta
	, a.bilanca_datum, a.evaluacija_datum, a.prv_obr, a.varscina
	--, a.net_nal, a.ost_obr, a.opcija, a.obr_mera, a.bod_debit
	, a.ostanek_dolga, a.znpl, a.bod_glav, a.obligo
	--, a.man_str, a.stroski_zt, a.stroski_pz, a.zav_fin, a.st_obrok, a.traj_naj, a.pokritost_zavar
	, a.tip_ddv, a.tip_ddv_traj, a.porostva_dod_opis, a.zavar_ostalo, a.ddv
	, CASE WHEN a.id_frame = 0 THEN NULL ELSE a.id_frame END AS id_frame
	, a.vin, a.id_odobrit_veza, a.prevozeni_km, a.id_cont, a.id_odobrit_kateg, a.id_odobrit_tip
	, a.id_planp_cl_content, a.id_p_eval, a.id_kupca_pl, a.BOD_robresti, a.kategorija1, a.kategorija2
	--, a.dat_1registracije DODANO U 2.23
	, CASE WHEN ISNUMERIC(a.boniteta) = 0 OR ltrim(rtrim(a.boniteta)) = '' THEN 0 ELSE round(cast(a.boniteta as decimal),0) END as bondec
	--, dbo.gfn_Nacin_leas_HR(a.nacin_leas) AS tip_leas
	, k1.naz_kr_kup AS partner_naz_kr_kup
	-- , CASE WHEN ltrim(rtrim(k1.ulica)) = '' THEN '' ELSE ltrim(rtrim(k1.ulica)) + ', ' END AS partner_ulica ULICA JE OBAVEZNA TAKO DA NIJE POTREBAN TAJ DIO
	, k1.ulica AS partner_ulica, k1.mesto AS partner_mesto, k1.kontakt AS partner_kontakt
	, CASE WHEN LEN(ltrim(rtrim(k1.dav_stev))) = 11 THEN k1.dav_stev ELSE '' END AS partner_dav_stev_11
	, k1.zr1 AS partner_zr1, k1.sif_dej AS partner_sif_dej, k1.delodajale AS partner_delodajale, k1.telefon AS partner_telefon
	, k1.fax AS partner_fax, k1.email AS partner_email, k1.opis_dej AS partner_opis_dej, k1.poklic AS partner_poklic
	, k1.ustanovit AS partner_ustanovit, k1.dob_kup AS partner_dob_kup, k1.vr_osebe AS partner_vr_osebe
	, vrst_ose.naziv AS vrst_ose_naziv
	, dejavnos.opis AS dejavnos_opis
	, dob.naz_kr_kup AS dob_naz_kr_kup
	, pon.pred_naj AS pon_pred_naj, pon.id_vrste AS pon_id_vrste, pon.st_obrok AS pon_st_obrok, pon.traj_naj AS pon_traj_naj
	, pon.id_val AS pon_id_val, pon.vr_val AS pon_vr_val, pon.prv_obr AS pon_prv_obr, pon.prv_obr_p AS pon_prv_obr_p
	, pon.varscina AS pon_varscina, pon.ddv AS pon_ddv, pon.ost_obr AS pon_ost_obr, pon.ost_obr_b AS pon_ost_obr_b
	, pon.opcija AS pon_opcija, pon.man_str AS pon_man_str, pon.rabat_nam AS pon_rabat_nam, pon.rabat_njim AS pon_rabat_njim
	, pon.dobrocno AS pon_dobrocno, pon.obr_financ AS pon_obr_financ, pon.net_nal AS pon_net_nal
	, pon.obr_mera AS pon_obr_mera, pon.id_rtip AS pon_id_rtip, pon.fix_del AS pon_fix_del
	, pon_dav_stop.davek / 100 AS rpt_davek    
	, CASE WHEN nacini_l.tip_knjizenja = 1 THEN 1 ELSE 0 END AS je_oper
	--iif(!je_oper,_ponuda.prv_obr,_ponuda.varscina)
	--, CASE WHEN nacini_l.tip_knjizenja != 1 THEN pon.prv_obr ELSE pon.varscina END AS akondep
	--iif(je_oper,0,akondep/iif(_ponuda.dobrocno=.t.,(1+rpt_davek),1)) +_ponuda.ost_obr/iif(_ponuda.dobrocno=.t.,(1+rpt_davek),1)*_ponuda.st_obrok+iif(je_oper,0,_ponuda.opcija/iif(_ponuda.dobrocno=.t.,(1+rpt_davek),1)
	-- dobrocno se može izbaciti iz izraèuna
	, CASE WHEN nacini_l.tip_knjizenja = 1 THEN 0 ELSE pon.prv_obr + pon.opcija END 
	+ ROUND(pon.ost_obr * pon.st_obrok, 2)  
	AS vrijednost_ugovora
	, vrst_opr.naziv AS vrst_opr_naziv
	, nacini_l.naziv AS nacini_l_naziv
	, CONVERT(varchar(10), frame_list.velja_do, 104) AS frame_list_velja_do, CONVERT(varchar(10), frame_list.dat_izteka, 104) AS frame_list_dat_izteka
	, rtip.id_tiprep -- 0 je da 'Nema reprogramiranja' 
	, bilans.datum_bil AS bilans_datum_bil, bilans.prihodki AS bilans_prihodki, bilans.kapital AS bilans_kapital, bilans.opis_kapital AS bilans_opis_kapital
	, bilans.id_tec_bil AS bilans_id_tec_bil, bilans.fprihodki AS bilans_fprihodki, bilans.ap_max AS bilans_ap_max, bilans.odhodki AS bilans_odhodki
	, bilans.id_val_bil AS bilans_id_val_bil
FROM dbo.Odobrit a
INNER JOIN dbo.Partner k1 ON a.id_kupca = k1.id_kupca
LEFT JOIN dbo.Partner dob ON a.id_dobavitelj = dob.id_kupca
LEFT JOIN dbo.vrst_ose ON k1.vr_osebe = vrst_ose.vr_osebe
LEFT JOIN dbo.dejavnos ON k1.sif_dej = dejavnos.sif_dej
LEFT JOIN dbo.ponudba pon ON a.id_pon = pon.id_pon
LEFT JOIN dbo.vrst_opr ON pon.id_vrste = vrst_opr.id_vrste
LEFT JOIN dbo.nacini_l ON pon.nacin_leas = nacini_l.nacin_leas
LEFT JOIN dbo.frame_list ON a.id_frame = frame_list.id_frame
LEFT JOIN dbo.dav_stop pon_dav_stop ON pon.id_dav_st = pon_dav_stop.id_dav_st
LEFT JOIN dbo.rtip ON pon.id_rtip = rtip.id_rtip
LEFT JOIN (SELECT a.*, b.id_val AS id_val_bil FROM --drugi naèin je gv_PBilanc_LastBilanc
(SELECT ROW_NUMBER() OVER (PARTITION BY id_kupca order by datum_bil DESC) br_retka
			, id_kupca, datum_bil, prihodki, kapital, opis_kapital, id_tec_bil, fprihodki, ap_max, odhodki 
			FROM dbo.p_bilanc) a
			LEFT JOIN dbo.tecajnic b ON a.id_tec_bil = b.id_tec
			WHERE a.br_retka = 1
			) bilans ON a.id_kupca = bilans.id_kupca
WHERE id_odobrit = @id