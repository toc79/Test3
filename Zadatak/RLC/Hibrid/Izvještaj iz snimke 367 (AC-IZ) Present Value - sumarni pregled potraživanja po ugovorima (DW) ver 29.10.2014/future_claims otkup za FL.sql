DECLARE @id_oc_report int = 106

SELECT a.id_cont, a.datum_dok, a.zap_obr, a.neto, a.robresti, a.id_tec -- , a.st_dok
INTO #oc_claims_future_FL
FROM dbo.oc_claims_future a 
INNER JOIN dbo.nacini_l b ON a.nacin_leas = b.nacin_leas AND b.tip_knjizenja = '2' AND b.ol_na_nacin_fl = 0 AND a.id_oc_report = b.id_oc_report -- samo FL leas
INNER JOIN dbo.vrst_ter c ON a.id_terj = c.id_terj AND a.id_oc_report = c.id_oc_report
AND a.id_oc_report = @id_oc_report 
AND a.obresti = 0 
AND c.sif_terj = 'LOBR'

SELECT a.id_cont, a.neto, a.robresti, a.id_tec 
INTO #oc_claims_future_FL_otkup
FROM (
	SELECT ROW_NUMBER () OVER(PARTITION BY a.id_cont ORDER BY zap_obr DESC) AS br_retka, 	--top 1  
	a.id_cont, a.datum_dok, a.zap_obr, a.neto, a.robresti, a.id_tec --, b.max_datum_dok 
	FROM #oc_claims_future_FL a
	INNER JOIN (SELECT id_cont, MAX(datum_dok) as max_datum_dok 
					FROM #oc_claims_future_FL
					GROUP BY id_cont) 
				b ON a.id_cont = b.id_cont AND a.datum_dok = b.max_datum_dok
) a
WHERE a.br_retka = 1  --top 1

DROP TABLE #oc_claims_future_FL
DROP TABLE #oc_claims_future_FL_otkup
