DECLARE @status_akt_enabled int, @status_akt_akttype int, @status_akt varchar(8000), @today datetime

SET @status_akt_enabled = {0}
SET @status_akt_akttype = {1}
SET @status_akt = {2}
SET @today = (SELECT dbo.gfn_GetDatePart(getdate()))

SELECT a.id_frame, a.frame_type, a.status_akt,
par.naz_kr_kup, 
--korišteno val u programu je vr_val za sif_frame_type REV iz gfn_FrameView jer su sva tri tipa okvira 1, 6, 8 te vrste 
ISNULL(SUM(dbo.gfn_XChange(a.id_tec, ISNULL(o.obligo_rev, CASE WHEN p.status_akt = 'Z' OR (p.status_akt = 'A' AND DATEDIFF(dd, p.dat_aktiv, @today) > 5) THEN 0 ELSE p.vr_val - p.varscina END), ISNULL(O.id_tec, p.id_tec), @today)), 0) as koristeno_val
INTO #okviri
FROM dbo.frame_list a
LEFT JOIN dbo.partner par ON a.id_kupca = par.id_kupca
LEFT JOIN dbo.frame_pogodba fc ON a.id_frame = fc.id_frame
LEFT JOIN dbo.pogodba p ON fc.id_cont = p.id_cont
LEFT JOIN (SELECT pp.id_cont, pp.id_kupca, pp.id_tec,
				SUM(pp.znp_saldo_brut_all + pp.bod_neto_lpod + CASE WHEN nl.ima_robresti = 1 THEN pp.bod_robresti_lpod ELSE 0 END) AS obligo_rev,
				SUM(pp.znp_saldo_brut_all + pp.bod_debit_brut_ALL - pp.bod_obresti_LPOD - case when nl.dav_o = 'D' then pp.bod_obresti_LPOD * (ds.davek / 100) else 0 end) AS obligo_rfo,
				SUM(pp.znp_saldo_ddv + pp.bod_davek_lpod) AS obligo_rne
			 FROM dbo.planp_ds pp
			 INNER JOIN dbo.pogodba po ON po.id_cont = pp.id_cont
			 INNER JOIN dbo.nacini_l nl ON nl.nacin_leas = po.nacin_leas
			 INNER JOIN dbo.dav_stop ds ON ds.id_dav_st = po.id_dav_st
			 GROUP BY pp.id_cont, pp.id_kupca, pp.id_tec) o ON p.id_cont = o.id_cont AND p.id_kupca = o.id_kupca
WHERE a.frame_type IN (1, 6, 8)
AND (@status_akt_enabled = 0 OR (@status_akt_akttype = 1 AND (CHARINDEX(a.status_akt, @status_akt) = 0 OR a.status_akt = '')) OR (@status_akt_akttype = 2 AND NOT(CHARINDEX(a.status_akt, @status_akt) = 0 OR a.status_akt = '')))
GROUP BY a.id_frame, a.frame_type, a.status_akt, par.naz_kr_kup
HAVING 
ISNULL(SUM(dbo.gfn_XChange(a.id_tec, ISNULL(o.obligo_rev, CASE WHEN p.status_akt = 'Z' OR (p.status_akt = 'A' AND DATEDIFF(dd, p.dat_aktiv, @today) > 5) THEN 0 ELSE p.vr_val - p.varscina END), ISNULL(O.id_tec, p.id_tec), @today)), 0) = 0

/*
--prvi pregled
SELECT a.id_frame, a.frame_type, a.status_akt, a.naz_kr_kup, a.koristeno_val, 
d.id_obl_zav, d.opis, d.vrnjen
FROM #okviri a
LEFT JOIN dbo.dokument d ON a.id_frame = d.id_frame
ORDER BY a.id_frame
*/

DECLARE @DocList varchar(8000)

SELECT @DocList = VALUE FROM dbo.general_register WHERE id_register = 'RLC Reporting list' AND id_key = 'RLC_IOP_LISTA'
SELECT * INTO #COLL FROM dbo.gfn_GetTableFromList(@DocList)

SELECT fr.id_frame, 
p.id_pog, p.nacin_leas, p.id_kupca, c.naz_kr_kup, p.se_varsc, p.varscina, p.status_akt, p.aneks, s.naziv as status_naziv,
d.id_obl_zav, d.opis as opis_dokumenta, d.vrnjen, LEFT(d.opombe, 250) as napomena_dokumenta, 
CASE
	WHEN opc.se_opc IS NULL THEN ' '
	WHEN opc.se_opc = 0 THEN 'NE'
	WHEN opc.se_opc = 1 THEN 'DA'
END as se_opc, opc.datum_dok as dat_opc,
pl.dat_pl, DATEDIFF(dd, pl.dat_pl, GETDATE()) as days_due, 
dra.zacetek as dat_pov
INTO #dod_rutina
FROM dbo.frame_list F
INNER JOIN #okviri fr ON f.id_frame = fr.id_frame
INNER JOIN dbo.frame_pogodba FP ON F.id_frame = FP.id_frame
INNER JOIN dbo.pogodba P ON FP.id_cont = P.id_cont
INNER JOIN dbo.frame_type FT ON FT.id_frame_type = F.frame_type
INNER JOIN dbo.partner C ON P.id_kupca = C.id_kupca
INNER JOIN dbo.statusi s ON p.status = s.status
LEFT JOIN (SELECT a.* FROM dbo.dokument a INNER JOIN #COLL b ON a.id_obl_zav = b.id) d ON p.id_cont = d.id_cont
LEFT JOIN (SELECT a.* FROM dbo.dokument a WHERE a.id_obl_zav = 'RA') dra ON p.id_cont = dra.id_cont
LEFT JOIN (
	SELECT a.id_cont, a.datum_dok, CASE WHEN a.ddv_id IS NOT NULL AND a.ddv_id <> '' THEN 1 ELSE 0 END AS se_opc
	FROM dbo.planp a
	INNER JOIN dbo.vrst_ter b on a.id_terj = b.id_terj
	WHERE b.sif_terj = 'OPC' 
	GROUP BY a.id_cont, a.datum_dok, a.ddv_id
	) opc ON p.id_cont = opc.id_cont
LEFT JOIN (
	--DATUM ZADNJEG PLAĆANJA IZ LSK i PLACILA (dio koda iz gft_PaymentDistribution_View_General1)
	SELECT a.id_cont, a.id_kupca, MAX(a.max_datum_placanja) as dat_pl
	FROM (
		SELECT	l.ID_CONT, l.id_kupca, MAX(pl.dat_pl) as max_datum_placanja
		FROM dbo.lsk l 
		INNER JOIN dbo.placila pl ON l.id_plac = pl.id_plac
		WHERE l.id_plac <> -1
		AND l.Kredit_DOM <> 0
		AND l.ID_Dogodka IN ('PLAC_IZ_AV','PLAC_ODPIS','PLAC_VRACI', 'PLAC_ZA_OD', 'PLACILO ', 'AV_VRACILO', 'AV_ODPIS', 'AV_ZAC_ODP')
		GROUP BY l.id_cont, l.id_kupca) a
	GROUP BY a.id_cont, a.id_kupca
	) pl ON p.id_cont = pl.id_cont AND p.id_kupca = pl.id_kupca
--WHERE pl.dat_pl > = '20140531'

--prvi pregled
SELECT a.id_frame, a.frame_type, a.status_akt, a.naz_kr_kup, a.koristeno_val, 
d.id_obl_zav, d.opis, d.vrnjen
FROM #okviri a
LEFT JOIN dbo.dokument d ON a.id_frame = d.id_frame
WHERE a.id_frame IN (SELECT id_frame FROM #dod_rutina GROUP BY id_frame HAVING MAX(dat_pl) > = '20140531')
ORDER BY a.id_frame

--dodatna rutina
SELECT * FROM #dod_rutina

DROP TABLE #okviri
DROP TABLE #COLL
DROP TABLE #dod_rutina