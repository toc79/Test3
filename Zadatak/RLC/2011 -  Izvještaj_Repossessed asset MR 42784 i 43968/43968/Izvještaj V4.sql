/*
19.08.2019 Tomislav MID 42784 (RLC 2011) - izrada;
13.05.2020 Tomislav MID 43968 (RLC 2090) - promjena logike;
*/
DECLARE @today datetime = dbo.gfn_GetDatePart(getdate())
DECLARE @ds_id_tec char(3) = (select top 1 planp_ds_tec from dbo.loc_nast order by id_loc_nast)  -- prema gfn_ContractStateForDashboardFromDS (SELECT TOP 1 id_tec FROM dbo.planp_ds)

--Kandidati
select distinct id_cont 
into #kandidati
from dbo.dokument where id_obl_zav in ('RA', 'RE') and status_akt = 'A'

select id_cont
	, sum(case when id_obl_zav = 'RA' and status_akt = 'A' then 1 else 0 end) as RA_otvoren
	, sum(case when id_obl_zav = 'RA' and status_akt != 'A' then 1 else 0 end) as RA_zatvoren
	, sum(case when id_obl_zav = 'RE' and status_akt = 'A' then 1 else 0 end) as RE_otvoren
	--, sum(case when id_obl_zav = 'RE' and status_akt != 'A' then 1 else 0 end) as RE_zatvoren
into #otvorenost_dokumenata
from dbo.dokument d
where exists (select * from #kandidati where id_cont = d.id_cont)
group by id_cont


SELECT id_cont, count(*) as ima_rpg_08
into #reprogram08
FROM dbo.reprogram r
where exists (select * from #kandidati where id_cont = r.id_cont)
and exists (select * from dbo.pogodba where status = '08' and id_cont = r.id_cont)
and (auto_desc like '%pogodba.STATUS ![00 -> 08!]%' escape '!'
	or auto_desc like '%pogodba.STATUS ![01 -> 08!]%' escape '!'
	or auto_desc like '%pogodba.STATUS ![02 -> 08!]%' escape '!'
	or auto_desc like '%pogodba.STATUS ![03 -> 08!]%' escape '!'
	or auto_desc like '%pogodba.STATUS ![DS -> 08!]%' escape '!'
	or auto_desc like '%pogodba.STATUS ![RI -> 08!]%' escape '!'
)
group by id_cont


SELECT Ugovor, Tip_financ 
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
	, Datum_vraćanja --kl.vrnjen
	
FROM (
	SELECT a.id_pog Ugovor, nacin_leas Tip_financ 
		, e.eval_model -- podatak kao u dodatnoj rutini "Dodavanje kolone Coconut, model eval i CRS status"
		, a.id_kupca Sif_part, b.ext_id AS Coconut, b.naz_kr_kup AS Partner
		, ISNULL(ds.znp_saldo_brut_all, 0) AS znp_saldo_brut_all
		, ISNULL(ds.bod_neto_lpod, 0) AS bod_neto_lpod
		, ISNULL(ds.SKUPAJ + ds.OSTALO, 0) AS Risk_izlozenost  --"Risk izloženost" - podatak kao u dodatnoj rutini "Dodavanje kolone Risk izloženost, Proknj. nedosp. ostali troškovi". 
		, vrst_opr.id_grupe AS Grupa
		, a.pred_naj AS Predmet, a.aneks, a.Status
		, statusi.naziv AS Status_ugovora 
		, l.max_datum_dok AS Zadnja_rata
		, p.max_dat_pl AS Zadnja_uplata_po_ug
		--Control_poin_1
		, CASE WHEN dbo.gfn_Nacin_leas_HR(a.nacin_leas) = 'OL' AND (isnull(otv.RA_otvoren, 0) > 0 OR (isnull(otv.RA_zatvoren, 0) > 0 and isnull(otv.RE_otvoren, 0) > 0)) and isnull(rpg08.ima_rpg_08, 0) > 0  
			THEN dateadd(dd, 60, p.max_dat_pl) ELSE NULL END AS Control_poin_1 --imao prvo status Ugovora XX, a kasnije je promjenjen status na POVRAT PREDMETA FINANCIRANJA i ima otvoreni RA dokument ili zatvoreni RA dokument, a otvoreni RE dokument -> ROK za izradu konačnog obračuna je 60 dana od datuma zadnje uplate po Ugovoru -> Control poin 1
		, ru.datum_dok AS Datum_naloga_za_raskid_ug
		, ra.zacetek AS Datum_povrata
		--Control_poin_2		
		, CASE WHEN isnull(otv.RA_otvoren, 0) > 0 THEN dateadd(dd, 365, ra.zacetek) ELSE NULL END AS Control_poin_2 --Ako Ugovor ima otvoreni RA dokument -> ROK 365 dana od preuzimanja/vraćanja (podatak iz 1.otvorenog RA dokumenta (aktivan/neaktivan) polje „Početak“ + 365 dana) -> Control poin 2
		, re.velja_do Datum_prodaje
		--Control poin 3
		, CASE WHEN isnull(otv.RA_zatvoren, 0) > 0 and isnull(otv.RE_otvoren, 0) > 0 THEN 
				dateadd(dd, case when dbo.gfn_Nacin_leas_HR(a.nacin_leas) = 'OL' then 120 else 90 end, re.velja_do)
			ELSE NULL END AS Control_poin_3 --Ako Ugovor ima zatvoreni RA dokument, a otvoreni RE dokument ROK 90 dana od dana unovčenja (podatak iz RE dokumenta (aktivan) polje „Vrijedi do“+ 90 dana) -> Control poin 3
		, re.vrednost AS Prodajna_cijena, re.id_kupca AS RE_Sif_part, re_part.naz_kr_kup AS RE_Partner 
		, a.id_tec
		, kl.zacetek AS Dat_izrade_konačnog_obračuna
		, case when kl.ima = 1 then kl.vrnjen else null end as Datum_vraćanja
	FROM dbo.pogodba a
	INNER JOIN dbo.partner b ON a.id_kupca = b.id_kupca
	LEFT JOIN (SELECT id_cont, id_tec, znp_saldo_brut_all, bod_neto_lpod
					, znp_saldo_brut_LPOD + znp_saldo_OST + bod_neto_LPOD + bod_findavek + bod_robresti_LPOD AS SKUPAJ --Formula za UKUPNO(SKUPAJ) u gfn_Report_SumContractFromDailySnapshot je Skupaj = Saldo + Se_neto + Se_fin_davek
					, poknj_nezap_debit_brut_all - poknj_nezap_neto_LPOD - poknj_nezap_robresti_LPOD AS OSTALO --OSTALO: budući neto i PPMV se već nalazi u SKUPAJ tj. u budućoj glavnici
				FROM dbo.gv_planp_ds_by_contract) ds ON a.id_cont = ds.id_cont
	LEFT JOIN (SELECT id_kupca, eval_model FROM dbo.gv_PEval_LastEvaluation) e ON a.id_kupca = e.id_kupca ---- This view return each partner last evaluation data of type E.  
	OUTER APPLY (SELECT TOP 1 id_cont, datum_dok FROM dbo.dokument WHERE id_obl_zav = 'RU' AND status_akt = 'A' AND id_cont = a.id_cont ORDER BY id_dokum DESC) ru
	OUTER APPLY (SELECT TOP 1 id_cont, zacetek FROM dbo.dokument WHERE id_obl_zav = 'RA' AND id_cont = a.id_cont ORDER BY id_dokum asc) ra
	OUTER APPLY (SELECT TOP 1 id_cont, velja_do, vrednost, id_kupca FROM dbo.dokument WHERE id_obl_zav = 'RE' AND status_akt = 'A' AND id_cont = a.id_cont ORDER BY id_dokum DESC) re
	OUTER APPLY (SELECT TOP 1 id_cont, zacetek, ima, vrnjen FROM dbo.dokument WHERE id_obl_zav = 'KL' AND status_akt = 'A' AND id_cont = a.id_cont ORDER BY id_dokum DESC) kl
	LEFT JOIN dbo.vrst_opr ON a.id_vrste = vrst_opr.id_vrste
	LEFT JOIN dbo.statusi ON a.status = statusi.status
	OUTER APPLY (SELECT MAX(datum_dok) AS max_datum_dok	FROM dbo.gv_planpx WHERE sif_terj = 'LOBR' AND id_cont = a.id_cont) l
	OUTER APPLY (SELECT MAX(dat_pl) AS max_dat_pl FROM dbo.placila WHERE id_cont = a.id_cont) p
	LEFT JOIN dbo.partner re_part ON re.id_kupca = re_part.id_kupca
	left join #otvorenost_dokumenata otv on a.id_cont = otv.id_cont
	left join #reprogram08 rpg08 on a.id_cont = rpg08.id_cont
	
	WHERE exists (select * from #kandidati where id_cont = a.id_cont)
	and a.status_akt = 'A'
) a
OUTER APPLY dbo.gfn_xchange_table(a.id_tec, a.znp_saldo_brut_all, @ds_id_tec, @today) c
OUTER APPLY dbo.gfn_xchange_table(a.id_tec, a.bod_neto_lpod, @ds_id_tec, @today) d
OUTER APPLY dbo.gfn_xchange_table(a.id_tec, a.Risk_izlozenost, @ds_id_tec, @today) r

drop table #kandidati
drop table #otvorenost_dokumenata
drop table #reprogram08