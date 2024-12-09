DECLARE @svi bit
SET @svi = {0}

DECLARE @today datetime

SET @today = (SELECT dbo.gfn_GetDatePart(getdate()))


SELECT a.id_krov_pog, a.st_krov_pog, a.id_tip, k.naziv as tip_naziv, a.id_kupca, c.naz_kr_kup as partner_krov_pog, 
p.id_pog, p.nacin_leas, p.id_kupca as id_kupca_pogodba, par.naz_kr_kup as partner_pogodba, p.se_varsc, p.varscina, p.aneks, p.status, p.status_akt, 
pl.dat_pl, DATEDIFF(dd, pl.dat_pl, GETDATE()) as days_due, 
CASE
	WHEN opc.se_opc IS NULL THEN ' '
	WHEN opc.se_opc = 0 THEN 'NE'
	WHEN opc.se_opc = 1 THEN 'DA'
END as se_opc, opc.datum_dok as dat_opc, 
dra.zacetek as dat_pov, 
drz.id_obl_zav, drz.opis as opis_dokumenta, drz.vrnjen, LEFT(drz.opombe, 250) as napomena_dokumenta
INTO #rezultat
FROM dbo.krov_pog a 
INNER JOIN dbo.krov_pog_tip k ON a.id_tip = k.id_tip
LEFT JOIN dbo.krov_pog_pogodba b ON a.id_krov_pog = b.id_krov_pog
LEFT JOIN dbo.partner c ON a.id_kupca = c.id_kupca
LEFT JOIN dbo.pogodba p ON b.id_cont = p.id_cont
LEFT JOIN dbo.partner par ON p.id_kupca = par.id_kupca
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
LEFT JOIN (
	SELECT a.id_cont, a.datum_dok, CASE WHEN a.ddv_id IS NOT NULL AND a.ddv_id <> '' THEN 1 ELSE 0 END AS se_opc
	FROM dbo.planp a
	INNER JOIN dbo.vrst_ter b on a.id_terj = b.id_terj
	WHERE b.sif_terj = 'OPC' 
	GROUP BY a.id_cont, a.datum_dok, a.ddv_id
	) opc ON p.id_cont = opc.id_cont
LEFT JOIN (SELECT a.* FROM dbo.dokument a WHERE a.id_obl_zav = 'RA') dra ON p.id_cont = dra.id_cont
LEFT JOIN (SELECT a.* FROM dbo.dokument a WHERE a.id_obl_zav IN ('ZZ', 'ZY')) drz ON p.id_cont = drz.id_cont


IF @svi = 0
BEGIN
	SELECT a.* 
	FROM #rezultat a
	WHERE a.status_akt = 'Z' 
	AND a.vrnjen IS NULL
	AND a.id_krov_pog NOT IN (SELECT id_krov_pog FROM #rezultat WHERE status_akt = 'A' GROUP BY id_krov_pog)
	ORDER BY a.st_krov_pog
END
ELSE
BEGIN
	SELECT a.* 
	FROM #rezultat a
	ORDER BY a.st_krov_pog
END


DROP TABLE #rezultat