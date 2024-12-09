DECLARE @partner_enabled int, @partner char(6), @datum_enabled int, @datum_od datetime, @datum_do datetime, @akt_enabled int, @akt_type int, @akt varchar(8000)

SET @partner_enabled = '0'--{0}
SET @partner = ''--{1}
SET @datum_enabled = '1'--{2}
SET @datum_od = '20190101'--{3}
SET @datum_do = '20190716'--{4}
SET @akt_enabled = 1--{5}
SET @akt_type = 2--{6}
SET @akt = 'A'--{7}

SELECT CAST(0 as bit) as Oznacen 
	, a.id_pog AS Ugovor
	, IIF(d.id_cont IS NULL, 0, d.br_1R_dok) AS Broj_1R_dok
	, a.dat_podpisa AS Datum_potpisa 
	, a.pred_naj AS Predmet, a.id_kupca AS Kupac, a.nacin_leas AS Tip_leas, a.status_akt AS Akt, a.dat_sklen AS Datum_sklapanja
FROM dbo.pogodba a
OUTER APPLY (SELECT id_cont, count(*) AS br_1R_dok 
			FROM dbo.dokument 
			WHERE id_obl_zav = '1R' AND id_cont = a.id_cont
			GROUP BY id_cont) d
WHERE (@partner_enabled = 0 OR a.id_kupca = @partner)
AND (@datum_enabled = 0 OR (a.dat_sklen BETWEEN @datum_od AND @datum_do))
AND (@akt_enabled = 0 OR (@akt_type = 1 AND (CHARINDEX(a.status_akt, @akt) = 0 OR a.status_akt = '')) OR (@akt_type = 2 AND NOT(CHARINDEX(a.status_akt, @akt) = 0 OR a.status_akt = '')))
ORDER BY a.id_pog