/* 	29.10.2014 DIana: Izmijenjeni nazivi 3 kolone u dijelu "Ime stupca"(Ana Teskera)
	31.01.2017 g_tomislav; dorada prema zahtjevu MR 37206
	14.08.2019 g_tomislav; dorada datum_placila, dodavanje kolona: razlika_sklen_podpisa, razlika_sklen_placila i razlika_podpisa_placila
*/
DECLARE @unos_oznacen bit, @date_from_unos datetime, @date_to_unos datetime
DECLARE @promjena_oznacen bit, @date_from_promjena datetime, @date_to_promjena datetime

SET @unos_oznacen = {0}
SET @date_from_unos = {1}
SET @date_to_unos = {2}
SET @promjena_oznacen = {3}
SET @date_from_promjena = {4}
SET @date_to_promjena = {5}


SELECT 
a.id_document, a.id_doc, a.id_pon, a.kupec_naziv, a.pred_naj, a.net_nal, 
ISNULL(wh.pocetak_unos, NULL) as pocetak_unos, 
ISNULL(wh.zakljucak_end, NULL) as zakljucak_end, 
ISNULL(wh.id_status_end, NULL) as id_status_end, 
ISNULL(ws.title, NULL) as status_end_title, 
DATEDIFF(dd, wh.pocetak_unos, wh.zakljucak_end) as razlika_unos_zakljucak, 
DATEDIFF(hh, wh.pocetak_unos, wh.zakljucak_end) as razlika_unos_zakljucak_sati, --10
ISNULL(wh.odo_unos, NULL) as odo_unos, -- 10a Datum statusa ODO
DATEDIFF(dd, wh.pocetak_unos, wh.odo_unos) as razlika_vns_odo, --10b Broj dana od VNS do Dat. st. ODO
ISNULL(wh.dkn_unos, NULL) as dkn_unos, -- 11 Datum DKN
DATEDIFF(dd, wh.pocetak_unos, wh.dkn_unos) as razlika_vns_dkn, --12 Broj dana od VNS do DKN
DATEDIFF(hh, wh.pocetak_unos, wh.dkn_unos) as razlika_vns_dkn_sati, --13 Broj sati od VNS do DKN
ISNULL(wh.dkc_unos, NULL) as dkc_unos, -- 14 Datum DKC
DATEDIFF(dd, wh.pocetak_unos, wh.dkc_unos) as razlika_vns_dkc, --15 Broj dana od VNS do DKC
DATEDIFF(hh, wh.pocetak_unos, wh.dkc_unos) as razlika_vns_dkc_sati, --16 Broj sati od VNS do DKC
DATEDIFF(dd, wh.dkn_unos, wh.dkc_unos) as razlika_dkn_dkc, --17 Broj dana od VNS do DKC
DATEDIFF(hh, wh.dkn_unos, wh.dkc_unos) as razlika_dkn_dkc_sati, --18 Broj sati od VNS do DKC
ISNULL(wh.analiza_unos, NULL) as analiza_unos, 
DATEDIFF(dd, wh.pocetak_unos, wh.analiza_unos) as razlika_unos_analiza, 
DATEDIFF(dd, wh.dkc_unos, wh.analiza_unos) as razlika_dkc_analiza_unos, --21 Broj dana od DKC do UNS
ISNULL(wh.crm_unos, NULL) as crm_unos, 
DATEDIFF(dd, wh.analiza_unos, wh.crm_unos) as razlika_analiza_crm, 
ISNULL(wh.rla_unos, NULL) as rla_unos, 
DATEDIFF(dd, wh.analiza_unos, wh.rla_unos) as razlika_analiza_rla, 
ISNULL(wh.crp_unos, NULL) as crp_unos, 
--MID 29483
--DATEDIFF(dd, wh.crm_unos, wh.crp_unos) as razlika_crm_crp, 
DATEDIFF(dd, CASE WHEN wh.crm_unos IS NULL THEN wh.rla_unos ELSE wh.crm_unos END, wh.crp_unos) as razlika_crm_crp, 
ISNULL(wh.rbk_unos, NULL) as rbk_unos, 
DATEDIFF(dd, wh.rbk_unos, wh.zakljucak_end) as razlika_rbk_zakljucak, 
ISNULL(wh.rlk_unos, NULL) as rlk_unos, 
DATEDIFF(dd, wh.rlk_unos, wh.zakljucak_end) as razlika_rlk_zakljucak, 
ISNULL(wh.user_entered_end, NULL) as user_entered_end, 
ISNULL(u.user_desc, NULL) as user_desc_end, 
SUBSTRING(ISNULL(wh.comment_end, ''), 0, 250) as comment_end, 
a.assigned_to_full_name, a.username_referent_to_full_name, 
o.id_vrste, a.vrsta_opreme, 
a.id_dobavitelj, a.dobavitelj_naziv, 
p.id_pog, p.status_akt, p.status, p.dat_aktiv, re.naziv as referent_pog, 
DATEDIFF(dd, wh.zakljucak_end, p.dat_aktiv) as razlika_ended_aktiv, 
p.dat_sklen, DATEDIFF(dd, p.dat_sklen, p.dat_aktiv) as razlika_sklen_aktiv,
p.dat_podpisa, DATEDIFF(dd, p.dat_podpisa, p.dat_aktiv) as razlika_podpis_aktiv,
DATEDIFF(dd, wh.pocetak_unos, p.dat_aktiv) as razlika_unos_aktiv, 
DATEDIFF(dd, p.dat_sklen, p.dat_podpisa) as razlika_sklen_podpisa, 
DATEDIFF(dd, p.dat_sklen, sp.datum_placila) as razlika_sklen_placila, 
DATEDIFF(dd, p.dat_podpisa, sp.datum_placila) as razlika_podpisa_placila, 
p.id_vrste as id_vrste_pog, pv.naziv as vrsta_opreme_pog, 
p.pred_naj as pred_naj_pog, 
sp.datum_placila, 
c.naz_kr_kup as dob_plac_izh, 
pa.naz_kr_kup, pa.vr_osebe, pe.eval_model
FROM dbo.gv_ObstojaOdobrit a
INNER JOIN dbo.odobrit o ON a.id_odobrit = o.id_odobrit
INNER JOIN dbo.partner pa ON a.id_kupca = pa.id_kupca
LEFT JOIN
	(SELECT a.id_document, 
	MIN(CASE WHEN s.is_start = 1 THEN a.date_started ELSE NULL END) as pocetak_unos, 
	MAX(CASE WHEN s.is_end = 1 THEN a.date_ended ELSE NULL END) as zakljucak_end, 
	MAX(CASE WHEN s.is_end = 1 THEN a.id_status_new ELSE NULL END) as id_status_end, 
	MIN(CASE WHEN a.id_status_new = 'UNS' THEN a.date_started ELSE NULL END) as analiza_unos, 
	MIN(CASE WHEN a.id_status_new = 'ODO' THEN a.status_date ELSE NULL END) as odo_unos, --Odobreno
	MIN(CASE WHEN a.id_status_new = 'DKN' THEN a.date_started ELSE NULL END) as dkn_unos, --Nepotpuna dokumentacija Dostaljena nepotpuna dokumentacija
	MIN(CASE WHEN a.id_status_new = 'DKC' THEN a.date_started ELSE NULL END) as dkc_unos, --Cjelokupna dokumentacija	Dostavljena cjelokupna dokumentacija
	MIN(CASE WHEN a.id_status_new = 'CRM' THEN a.date_started ELSE NULL END) as crm_unos, 
	MIN(CASE WHEN a.id_status_new = 'RBA' THEN a.date_started ELSE NULL END) as rla_unos, 
	MIN(CASE WHEN a.id_status_new = 'CRP' THEN a.date_started ELSE NULL END) as crp_unos, 
	MIN(CASE WHEN a.id_status_new = 'RBK' THEN a.date_started ELSE NULL END) as rbk_unos, 
	MIN(CASE WHEN a.id_status_new = 'RLK' THEN a.date_started ELSE NULL END) as rlk_unos, 
	MAX(CASE WHEN s.is_end = 1 THEN a.user_entered ELSE NULL END) as user_entered_end, 
	MAX(CASE WHEN s.is_end = 1 THEN a.comment ELSE NULL END) as comment_end
	FROM dbo.wf_history a
	INNER JOIN dbo.wf_status s ON a.id_status_new = s.id_status
	GROUP BY a.id_document) wh ON a.id_document = wh.id_document 
LEFT JOIN dbo.wf_status ws ON wh.id_status_end = ws.id_status
LEFT JOIN dbo.users u ON wh.user_entered_end = u.username
LEFT JOIN dbo.pogodba p ON a.id_odobrit = p.id_odobrit AND (p.prevzeta IS NULL OR p.prevzeta = '')
LEFT JOIN dbo.referent re ON p.id_ref = re.id_ref
LEFT JOIN dbo.vrst_opr pv ON p.id_vrste = pv.id_vrste
LEFT JOIN (
	SELECT b.id_cont, b.id_dob, MAX(a.datum) as datum_placila
	FROM dbo.status_placila a
	INNER JOIN dbo.plac_izh b ON a.id_plac_izh = b.id_plac_izh
	WHERE a.v_status = 'S'  /* AND b.id_plac_izh_tip = 2 => sada za sve tipove plaćanja */
	GROUP BY b.id_cont, b.id_dob
	) sp ON p.id_cont = sp.id_cont
LEFT JOIN dbo.partner c ON sp.id_dob = c.id_kupca
LEFT JOIN (
	SELECT a.id_kupca, a.eval_model, a.dat_eval
	FROM dbo.p_eval a 
	INNER JOIN (
		SELECT id_kupca, MAX(dat_eval) as max_dat_eval
		FROM dbo.p_eval WHERE eval_type = 'E'
		GROUP BY id_kupca) b ON a.id_kupca = b.id_kupca AND a.dat_eval = b.max_dat_eval 
		WHERE a.eval_type = 'E') pe ON a.id_kupca = pe.id_kupca
WHERE 
(@unos_oznacen = 0 OR dbo.gfn_ConvertDateTime(a.date_wf_started) BETWEEN @date_from_unos AND @date_to_unos)
AND (@promjena_oznacen = 0 OR dbo.gfn_ConvertDateTime(a.date_last_status_change) BETWEEN @date_from_promjena AND @date_to_promjena)
ORDER BY a.id_document 