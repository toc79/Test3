DECLARE @partner_enabled int, @partner char(6), @nacin_leas_enabled int, @nacin_leas varchar(8000), @strm_enabled int, @strm varchar(8000), @id_tec_enabled bit, @id_tec char(3), @datum_enabled int, @datum_od datetime, @datum_do datetime, @akt_enabled int, @akt_type int, @akt varchar(8000), @user_enabled int, @username varchar(8000)

SET @partner_enabled = {0}
SET @partner = {1}
SET @nacin_leas_enabled  = {2}
SET @nacin_leas = {3}
SET @strm_enabled  = {4}
SET @strm = {5}
SET @id_tec_enabled = {6}
SET @id_tec = {7}
SET @datum_enabled = {10}
SET @datum_od = {11}
SET @datum_do = {12}
SET @akt_enabled = {13}
SET @akt_type = {14}
SET @akt = {15}
SET @user_enabled = {16}
SET @username = {17}

SELECT 
CAST(0 as bit) as oznacen, 
a.id_cont, a.id_pog, a.pred_naj, a.id_kupca, p.naz_kr_kup, a.nacin_leas, a.id_strm, a.status_akt, a.id_val, a.id_tec, t.naziv, a.dat_sklen, a.dat_podpisa, a.vr_val, a.vr_sit, u.user_desc
, IIF(d.id_cont IS NULL, 0, d.br_1R_dok) AS Broj_1R_dok
FROM dbo.pogodba a
INNER JOIN dbo.partner p ON a.id_kupca = p.id_kupca
INNER JOIN dbo.tecajnic t ON a.id_tec = t.id_tec
LEFT JOIN dbo.users u ON a.vnesel = u.username
OUTER APPLY (SELECT id_cont, count(*) AS br_1R_dok 
			FROM dbo.dokument 
			WHERE id_obl_zav = '1R' AND id_cont = a.id_cont
			GROUP BY id_cont) d
WHERE a.dat_podpisa IS NULL
order by a.id_cont
WHERE a.dat_podpisa IS NULL
AND (@partner_enabled = 0 OR a.id_kupca = @partner)
AND (@nacin_leas_enabled = 0 OR CHARINDEX(a.nacin_leas, @nacin_leas) > 0)
AND (@strm_enabled = 0 OR CHARINDEX(a.id_strm, @strm) > 0)
AND (@id_tec_enabled  = 0 OR a.id_tec = @id_tec)
AND (@datum_enabled = 0 OR (a.dat_sklen BETWEEN @datum_od AND @datum_do))
AND (@akt_enabled = 0 OR (@akt_type = 1 AND (CHARINDEX(a.status_akt, @akt) = 0 OR a.status_akt = '')) OR (@akt_type = 2 AND NOT(CHARINDEX(a.status_akt, @akt) = 0 OR a.status_akt = '')))
AND (@user_enabled = 0 OR a.vnesel = @username)
ORDER BY a.id_pog