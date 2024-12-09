/*
19.08.2019 g_tomislav MR 42784 (RLC 2011) - izrada;
*/
DECLARE @today datetime = getdate()
DECLARE @ds_id_tec char(3) = (select top 1 planp_ds_tec from dbo.loc_nast order by id_loc_nast)  -- prema gfn_ContractStateForDashboardFromDS (SELECT TOP 1 id_tec FROM dbo.planp_ds)

SELECT Ugovor, Tip_fin 
	, eval_model AS Model_evaluacije -- podatak kao u dodatnoj rutini "Dodavanje kolone Coconut, model eval i CRS status"
	, Sif_part, Coconut, Partner
	, c.znesek AS Još_duguje --znp_saldo_brut_all
	, d.znesek AS Buduća_glavnica --bod_neto_lpod
	, r.znesek AS Risk_izlozenost --"Risk izloženost" - podatak kao u dodatnoj rutini "Dodavanje kolone Risk izloženost, Proknj. nedosp. ostali troškovi". 
	, id_tec AS Šif_tec
	, Grupa
	, Predmet, aneks, Status, Status_ugovora 
	, Zadnja_rata
	, Zadnja_uplata_po_ug
	, Control_poin_1
	, Datum_naloga_za_raskid_ug --ru.datum_dok
	, Datum_povrata --ra.zacetek 
	, Control_poin_2
	, Datum_prodaje --re.velja_do 
	, Control_poin_3
	, Prodajna_cijena, RE_Sif_part, RE_Partner 
	, Dat_izrade_konačnog_obračuna --kl.zacetek
FROM (
	SELECT a.id_pog Ugovor, nacin_leas Tip_fin
		, e.eval_model -- podatak kao u dodatnoj rutini "Dodavanje kolone Coconut, model eval i CRS status"
		, a.id_kupca Sif_part, b.ext_id AS Coconut, b.naz_kr_kup AS Partner
		, ISNULL(ds.znp_saldo_brut_all, 0) AS znp_saldo_brut_all
		, ISNULL(ds.bod_neto_lpod, 0) AS bod_neto_lpod
		, ISNULL(ds.SKUPAJ + ds.OSTALO, 0) AS Risk_izlozenost  --"Risk izloženost" - podatak kao u dodatnoj rutini "Dodavanje kolone Risk izloženost, Proknj. nedosp. ostali troškovi". 
		, vrst_opr.id_grupe AS Grupa
		, a.pred_naj AS Predmet, a.aneks, a.Status
		, statusi.naziv AS Status_ugovora 
		, l.datum_dok AS Zadnja_rata
		, p.dat_pl AS Zadnja_uplata_po_ug
		, CASE WHEN dbo.gfn_Nacin_leas_HR(a.nacin_leas) = 'OL' AND a.status = 'RI' THEN p.dat_pl + 60 ELSE NULL END AS Control_poin_1
		, ru.datum_dok AS Datum_naloga_za_raskid_ug
		, ra.zacetek AS Datum_povrata
		, CASE WHEN a.status != 'RI' THEN ra.zacetek + 365 ELSE NULL END AS Control_poin_2
		, re.velja_do Datum_prodaje
		, CASE WHEN a.status != 'RI' THEN re.velja_do + CASE WHEN dbo.gfn_Nacin_leas_HR(a.nacin_leas) = 'OL' THEN 120 ELSE 90 END 
			ELSE NULL END AS Control_poin_3
		, re.vrednost AS Prodajna_cijena, re.id_kupca AS RE_Sif_part, re_part.naz_kr_kup AS RE_Partner 
		, kl.zacetek AS Dat_izrade_konačnog_obračuna
		, a.id_tec
	FROM dbo.pogodba a
	INNER JOIN dbo.partner b ON a.id_kupca = b.id_kupca
	LEFT JOIN (SELECT id_cont, id_tec, znp_saldo_brut_all, bod_neto_lpod
					, znp_saldo_brut_LPOD + znp_saldo_OST + bod_neto_LPOD + bod_findavek + bod_robresti_LPOD AS SKUPAJ --Formula za UKUPNO(SKUPAJ) u gfn_Report_SumContractFromDailySnapshot je Skupaj = Saldo + Se_neto + Se_fin_davek
					, poknj_nezap_debit_brut_all - poknj_nezap_neto_LPOD - poknj_nezap_robresti_LPOD AS OSTALO --OSTALO: budući neto i PPMV se već nalazi u SKUPAJ tj. u budućoj glavnici
				FROM dbo.gv_planp_ds_by_contract) ds ON a.id_cont = ds.id_cont
	LEFT JOIN (SELECT id_kupca, eval_model FROM dbo.gv_PEval_LastEvaluation) e ON a.id_kupca = e.id_kupca ---- This view return each partner last evaluation data of type E.  
	OUTER APPLY (SELECT TOP 1 id_cont, datum_dok FROM dbo.dokument WHERE id_obl_zav = 'RU' AND status_akt = 'A' AND id_cont = a.id_cont ORDER BY id_dokum DESC) ru
	OUTER APPLY (SELECT TOP 1 id_cont, zacetek FROM dbo.dokument WHERE id_obl_zav = 'RA' AND status_akt = 'A' AND id_cont = a.id_cont ORDER BY id_dokum DESC) ra
	OUTER APPLY (SELECT TOP 1 id_cont, velja_do, vrednost, id_kupca FROM dbo.dokument WHERE id_obl_zav = 'RE' AND status_akt = 'A' AND id_cont = a.id_cont ORDER BY id_dokum DESC) re
	OUTER APPLY (SELECT TOP 1 id_cont, zacetek FROM dbo.dokument WHERE id_obl_zav = 'KL' AND status_akt = 'A' AND id_cont = a.id_cont ORDER BY id_dokum DESC) kl
	LEFT JOIN dbo.vrst_opr ON a.id_vrste = vrst_opr.id_vrste
	LEFT JOIN dbo.statusi ON a.status = statusi.status
	OUTER APPLY (SELECT MAX(datum_dok) AS datum_dok	FROM dbo.gv_planpx WHERE sif_terj = 'LOBR' AND id_cont = a.id_cont) l
	OUTER APPLY (SELECT MAX(dat_pl) AS dat_pl FROM dbo.placila WHERE id_cont = a.id_cont) p
	LEFT JOIN dbo.partner re_part ON re.id_kupca = re_part.id_kupca
	WHERE a.status_akt = 'A'
	AND (a.status in ('RA', '08', 'PP', 'RI')  
		OR ru.id_cont IS NOT NULL OR ra.id_cont IS NOT NULL OR re.id_cont IS NOT NULL OR kl.id_cont IS NOT NULL)
) a
OUTER APPLY dbo.gfn_xchange_table(a.id_tec, a.znp_saldo_brut_all, @ds_id_tec, @today) c
OUTER APPLY dbo.gfn_xchange_table(a.id_tec, a.bod_neto_lpod, @ds_id_tec, @today) d
OUTER APPLY dbo.gfn_xchange_table(a.id_tec, a.Risk_izlozenost, @ds_id_tec, @today) r