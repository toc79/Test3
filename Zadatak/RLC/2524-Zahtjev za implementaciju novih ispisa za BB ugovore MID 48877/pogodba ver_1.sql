declare @delimiter_position int = (select charindex(';', @id))

declare @kategorija varchar(4) = left(@id, @delimiter_position -1)
declare @id_cont int = substring(@id, @delimiter_position +1, len(@id))


SELECT
	pog.id_cont,
	LTRIM(RTRIM(pog.id_pog)) AS id_pog, pog.dat_sklen, LTRIM(RTRIM(pog.kategorija)) AS kategorija, LTRIM(RTRIM(pog.nacin_leas)) AS nacin_leas, LTRIM(RTRIM(pog.pred_naj)) AS pred_naj, pog.traj_naj,
	par.id_kupca AS par_id_kupca, ISNULL(LTRIM(RTRIM(par.id_poste_sed)), '') AS par_id_poste_sed, ISNULL(LTRIM(RTRIM(par.mesto_sed)), '') AS par_mesto_sed, ISNULL(LTRIM(RTRIM(par.naz_kr_kup)), '') AS par_naz_kr_kup, ISNULL(LTRIM(RTRIM(par.ulica_sed)), '') AS par_ulica_sed, LTRIM(RTRIM(par.vr_osebe)) AS par_vr_osebe,
	dob.id_kupca AS dob_id_kupca, ISNULL(LTRIM(RTRIM(dob.id_poste_sed)), '') AS dob_id_poste_sed, ISNULL(LTRIM(RTRIM(dob.mesto_sed)), '') AS dob_mesto_sed, ISNULL(LTRIM(RTRIM(dob.naz_kr_kup)), '') AS dob_naz_kr_kup, ISNULL(LTRIM(RTRIM(dob.ulica_sed)), '') AS dob_ulica_sed, LTRIM(RTRIM(dob.vr_osebe)) AS dob_vr_osebe,
	pon.robresti_val, pon.vr_bruto, pon.vr_neto,
	oo.oo_id_obl_zav, oo.oo_id_kupca, oo.oo_id_poste_sed, oo.oo_mesto_sed, oo.oo_naz_kr_kup, oo.oo_ulica_sed, oo.oo_vr_osebe, oo_dav_stev, oo.oo_po,
	otk_vr.davek, otk_vr.neto, otk_vr.robresti, 
	ISNULL(LTRIM(RTRIM(zr.kubik)), '') AS kubik, ISNULL(LTRIM(RTRIM(zr.ps_kw)), '') AS ps_kw, ISNULL(LTRIM(RTRIM(zr.st_sas)), '') AS st_sas, ISNULL(LTRIM(RTRIM(zr.znamka)), '') AS znamka,
	ISNULL(LTRIM(RTRIM(tec.naziv)), '') AS tec_naziv,

	pog.dovol_km / 12 * pog.traj_naj AS uk_dog_km,
	otk_vr.neto + otk_vr.davek + otk_vr.robresti AS uk_otk_vr,

	CASE WHEN LEN(ISNULL(LTRIM(RTRIM(dob.dav_stev)), '')) = 11 THEN LTRIM(RTRIM(dob.dav_stev)) ELSE '' END AS dob_dav_stev,
	CASE WHEN LEN(ISNULL(LTRIM(RTRIM(par.dav_stev)), '')) = 11 THEN LTRIM(RTRIM(par.dav_stev)) ELSE '' END AS par_dav_stev,
	CASE WHEN b8.b8_id_obl_zav = 'B8' THEN 1 ELSE 0 END as sadrzi_B8,
	CASE WHEN dbo.gfn_Nacin_leas_HR(pog.nacin_leas) = 'OL' THEN 1 ELSE 0 END AS ozn_leas,
	CASE WHEN dbo.gfn_Nacin_leas_HR(pog.nacin_leas) = 'OL' THEN 'operativnom' ELSE 'financijskom' END AS naz_leas,
	CASE WHEN dob.vr_osebe != 'FO' THEN ', zastupano po ' +  ISNULL(LTRIM(RTRIM(dob.direktor)), '') ELSE '' END AS dob_po,
	CASE WHEN par.vr_osebe != 'FO' THEN ', zastupano po ' +  ISNULL(LTRIM(RTRIM(par.direktor)), '') ELSE '' END AS par_po,
	CASE WHEN pog.id_dob = oo.oo_id_kupca OR ISNULL(oo.oo_id_kupca, '')= '' THEN 1 ELSE 0 END as print_dob,

	'kraj' AS kraj
--FROM @xml_data.nodes('VFPData/rezultat') t(c)
--JOIN dbo.pogodba pog ON t.c.value('id_cont[1]','varchar(max)') = pog.id_cont
FROM dbo.pogodba pog 
JOIN dbo.partner par ON pog.id_kupca = par.id_kupca
JOIN dbo.partner dob ON pog.id_dob = dob.id_kupca
JOIN dbo.ponudba pon ON pog.id_pon = pon.id_pon
LEFT JOIN dbo.zap_reg zr ON pog.id_cont = zr.id_cont
LEFT JOIN dbo.tecajnic tec ON pog.id_tec = tec.id_tec
--obveznik otkupa
OUTER APPLY (
	SELECT
		ISNULL(dokum.id_kupca, '') AS oo_id_kupca, ISNULL(dokum.id_obl_zav, '') AS oo_id_obl_zav,
		par.id_kupca, ISNULL(LTRIM(RTRIM(par.id_poste_sed)), '') AS oo_id_poste_sed, ISNULL(LTRIM(RTRIM(par.mesto_sed)), '') AS oo_mesto_sed, ISNULL(LTRIM(RTRIM(par.naz_kr_kup)), '') AS oo_naz_kr_kup, ISNULL(LTRIM(RTRIM(par.ulica_sed)), '') AS oo_ulica_sed, LTRIM(RTRIM(par.vr_osebe)) AS oo_vr_osebe,
		IIF(LEN(ISNULL(LTRIM(RTRIM(par.dav_stev)), '')) = 11, LTRIM(RTRIM(par.dav_stev)), '') AS oo_dav_stev,
		IIF(par.vr_osebe != 'FO', ', zastupano po ' +  ISNULL(LTRIM(RTRIM(par.direktor)), ''), '') AS oo_po
	FROM dbo.dokument dokum
	LEFT JOIN dbo.partner par on dokum.id_kupca = par.id_kupca
	WHERE dokum.id_cont = pog.id_cont
	AND dokum.ID_OBL_ZAV IN ('B1', 'B2', 'B3', 'B4','B5', 'B6')
) oo
--dokument 'B8'
OUTER APPLY (
	SELECT 
		ISNULL(dokum.id_kupca, '') AS b8_id_kupca, ISNULL(dokum.id_obl_zav, '') AS b8_id_obl_zav, LTRIM(RTRIM(par.polni_naz)) AS b8_polni_naz, LTRIM(RTRIM(par.dav_stev)) AS b8_dav_stev, LTRIM(RTRIM(par.ulica_sed)) AS b8_ulica_sed, LTRIM(RTRIM(par.id_poste_sed)) AS b8_id_poste_sed, LTRIM(RTRIM(par.mesto_sed)) AS b8_mesto_sed, LTRIM(RTRIM(par.emso)) AS b8_emso, LTRIM(RTRIM(par.direktor)) AS b8_direktor,	LTRIM(RTRIM(par.vr_osebe)) AS b8_vr_osebe, LTRIM(RTRIM(par.naz_kr_kup)) AS b8_naz_kr_kup, LTRIM(RTRIM(par.stev_reg)) AS b8_stev_reg
	FROM dbo.dokument dokum
	LEFT JOIN dbo.partner par on dokum.id_kupca = par.id_kupca
	WHERE dokum.id_cont = pog.id_cont
	AND dokum.ID_OBL_ZAV = 'B8'
) b8
OUTER APPLY (
SELECT
	pp.neto, pp.davek, pp.robresti, pp.neto + pp.davek + pp.robresti AS uk_otk_vr
	FROM dbo.planp pp
	JOIN dbo.vrst_ter vt ON pp.id_terj = vt.id_terj
														   
	WHERE vt.sif_terj = 'OPC'
	and pp.id_cont = pog.id_cont
) otk_vr
--dokument 'B7'
-- OUTER APPLY (
	-- SELECT CASE WHEN COUNT(id_obl_zav) > 0 THEN 1 ELSE 0 END AS sadrzi_b7 FROM dbo.dokument WHERE id_cont = pog.id_cont AND id_obl_zav = 'B7'
-- ) b7
WHERE pog.kategorija = @kategorija
and (0 = (case when @id_cont = -1 then 0 else 1 end) 
	or pog.id_cont = @id_cont)
and (exists (SELECT * FROM dbo.dokument WHERE id_obl_zav = 'B7' and id_cont = pog.id_cont)
	 or @id_cont != -1) 