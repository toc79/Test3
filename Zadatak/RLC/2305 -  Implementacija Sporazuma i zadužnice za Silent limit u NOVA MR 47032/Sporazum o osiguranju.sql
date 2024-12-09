1) UGOVOR O OKVIRU (word ispis)
6) Zadužnica ‑ Obična za okvir (word ispis)

nije prebačen PS

"SPORAZUM O OSIGURANJU Stimulsoft u Word"
sam pokrenuo na produkciji i ok je


2.1.1.	Zadužnica Klijenta
•  1 zadužnica Klijenta, u iznosu {Format("{0:N2}", frame_list.iznos)} {frame_list.id_val} (slovima: {frame_list.iznos_slovima.Trim()}){IIF(frame_list.print_eur == 1, frame_list.tecajnic_tekst2, "")}

SELECT 
	fl.id_frame,
	par.id_kupca, LTRIM(RTRIM(par.naz_kr_kup)) AS naz_kr_kup, LTRIM(RTRIM(ISNULL(par.id_poste_sed, ''))) AS id_poste_sed, LTRIM(RTRIM(ISNULL(par.mesto_sed, ''))) AS mesto_sed,	LTRIM(RTRIM(ISNULL(par.ulica_sed, ''))) AS ulica_sed,
	pon.id_val,
	CASE WHEN par.vr_osebe != 'FO' THEN ', koje zastupa ' + LTRIM(RTRIM(ISNULL(par.direktor, ''))) ELSE '' END AS direktor,
	CASE WHEN pon.id_val != 'HRK' THEN 1 ELSE 0 END AS print_eur,
	IIF(LEN(par.dav_stev) = 11, ', OIB: ' + LTRIM(RTRIM(ISNULL(par.dav_stev, ''))), '') AS dav_stev,
	IIF(par.vr_osebe = 'SP', ', MBO: ' + LTRIM(RTRIM(ISNULL(par.stev_reg, ''))),'') AS stev_reg,
	IIF(ISNULL(REPLACE(fl.dat_izteka,'1900-01-01',''),'') = '', '', CONVERT(VARCHAR, fl.dat_izteka, 104)) AS dat_izteka,
	CASE WHEN dbo.gfn_Nacin_leas_HR(pon.nacin_leas) = 'OL' THEN ROUND(pon.st_obrok*pon.ost_obr, 2) ELSE ROUND(pp.debit*pon.st_obrok, 2)+pon.opcija END AS iznos,
	CASE WHEN dbo.gfn_Nacin_leas_HR(pon.nacin_leas) = 'OL' THEN LTRIM(RTRIM(dbo.gfn_NumberToWords(ROUND(pon.st_obrok*pon.ost_obr, 2), 1, 1, pon.id_val, 0))) ELSE LTRIM(RTRIM(dbo.gfn_NumberToWords((pp.debit*pon.st_obrok)+pon.opcija, 1, 1, pon.id_val, 0))) END AS iznos_slovima,
CASE WHEN pon.id_tec != '000' THEN ' u kunskoj protuvrijednosti koristeći '+ltrim(rtrim(t.naziv))+' na dan '
			 WHEN pon.id_tec is null THEN ' u kunskoj protuvrijednosti koristeći '+ltrim(rtrim(tec_sred.tec_naziv))+' na dan '
			 ELSE '' END as tecajnic_tekst1,
CASE WHEN pon.id_tec != '000' THEN ' u kunskoj protuvrijednosti po '+ltrim(rtrim(t.naziv))+' važećem na dan dospijeća'
			 WHEN pon.id_tec is null THEN ' u kunskoj protuvrijednosti po '+ltrim(rtrim(tec_sred.tec_naziv))+' važećem na dan dospijeća'
			 ELSE '' END as tecajnic_tekst2
FROM dbo.frame_list fl
LEFT JOIN dbo.partner par ON fl.id_kupca = par.id_kupca
LEFT JOIN dbo.odobrit od ON fl.sif_odobrit = od.id_odobrit
LEFT JOIN dbo.ponudba pon ON od.id_pon = pon.id_pon
left join dbo.tecajnic t on pon.id_tec = t.id_tec
outer apply (select naziv as tec_naziv from tecajnic 
	where id_tec = '017') tec_sred
OUTER APPLY (SELECT top 1 debit FROM dbo.gfn_GenerateAmortisationPlan4Offer(pon.id_pon) WHERE sif_terj = 'LOBR') pp
WHERE fl.id_frame = @id
