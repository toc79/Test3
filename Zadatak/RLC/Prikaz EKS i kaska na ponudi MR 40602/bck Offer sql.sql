DECLARE @id1 VARCHAR(20), @id2 char(1) 

SET @id1 = CAST(SUBSTRING(@id, 0, CHARINDEX(';',@id)) AS VARCHAR(20))
SET @id2 = CAST(SUBSTRING(@id, CHARINDEX(';',@id)+1, LEN(RTRIM(@id))) AS CHAR(1))

DECLARE @zakup_nek VARCHAR(100)
SELECT @zakup_nek = val FROM custom_settings WHERE code = 'Nova.LE.Zakup.Nekretnina'

SELECT po.id_pon, po.naziv_kup,
	pa.naz_kr_kup, po.obr_mera, po.ef_obrm, po.str_notar, pa.ulica_sed, pa.id_poste_sed, pa.mesto_sed, 
	pa.vr_osebe, po.dat_pon, po.pred_naj, po.id_rtip, r.naziv as rtip_naziv,
	po.id_vrste, po.st_predr, ISNULL(CONVERT(VARCHAR(10),po.dat_predr,104), '') as dat_predr, 
	ISNULL(CONVERT(varchar(10),po.predr_do,104), '') as predr_do, 
	po.traj_naj, po.vr_val, ds.davek, po.st_obrok, po.opis_pred,
	po.id_val,
	dbo.gfn_xchange(po.id_tec, po.str_notar,'000', po.dat_pon) as str_notar_val, po.oststr,
	--DORADA PPMV
	po.vr_neto, po.vr_bruto, po.robresti_val, po.neto, po.bruto, po.robresti_dom, po.varscina, po.varsc_p,
	po.prv_obr_n, po.prv_obr, po.prv_obr_p, CAST(po.robresti_val*(po.prv_obr_p/100) AS DECIMAL(18,2)) AS prv_obr_ppmv,
	po.ost_obr, po.ost_obr_n, CAST((po.robresti_val-(po.robresti_val*(po.prv_obr_p/100))-(po.robresti_val*(po.opcija_p/100)))/po.st_obrok AS DECIMAL(18,2)) AS ost_obr_ppmv,
	po.man_str_n, po.man_str, po.manstr_p,
	po.opcija, po.opcija_p, CAST(po.robresti_val*(po.opcija_p/100) AS DECIMAL(18,2)) AS opcija_ppmv,
	CAST((po.opcija-(po.robresti_val*(po.opcija_p/100))) *(ds2.davek/100) AS DECIMAL(18,2)) AS opcija_davek,
	po.plac_zac, po.dovol_km, po.cena_dkm, po.je_foseba, po.id_dav_op, 
--KRAJ DORADE
	CASE 
		WHEN v.tip_opr='V' and v.se_regis='*' THEN 'V'
		WHEN v.tip_opr='P' and v.se_regis='*' then 'P'
		ELSE '' 
	END as tip_opr, 
	v.se_regis, po.id_tec, t.naziv as naziv_tecaj,
	po.net_nal, po.naziv_dob, po.nacin_leas, po.opombe, po.obvezno, po.kasko,
	100*(po.varscina/po.vr_val)+100*(po.opcija/po.vr_val) as ukupno_bud_p,
	CASE 
		WHEN po.dat_pon < '20130701' THEN 'PDV na kamatu i trošak obrade nije obračunat sukladno Čl.11a Zakona o porezu na dodanu vrijednost.' 
		ELSE 'PDV na kamatu i trošak obrade nije obračunat sukladno Čl.40 Zakona o porezu na dodanu vrijednost.' 
	END AS print_klavzua,
	dbo.gfn_Nacin_leas_HR(po.nacin_leas) as tip_leas, 
	o.naziv as obd_naziv, po.ddv,
	ISNULL(CASE WHEN gr.id_key = po.id_vrste THEN 1 ELSE 0 END, 0) as print_str_osig, 
	CAST(@id2 as bit) as print_str_osig_code_before,
	CASE WHEN v.se_regis = '*' AND (v.tip_opr = 'V' or v.tip_opr = 'P') AND po.oststr = 0 THEN 1 ELSE 0 END as print_osig_kasko,
	CASE 
		--WHEN gr.val_char = 'LD' THEN 'Osiguranje pravne zaštite- dodatno pokriće uz UNIQA AO policu za laka teretna vozila'
		WHEN gr.val_char = 'OV' THEN 'Kombinacija I- dodatno pokriće uz UNIQA AO policu za osobna vozila'
		ELSE '' 
	END as txt_1,
	CASE 
		--WHEN gr.val_char = 'LD' THEN 'Osiguranje troškova pravne zaštite uslijed uporabe vozila smatra se prometna nezgoda, zbog koje protiv osiguranika može biti pokrenut kazneni ili prekršajni postupak (sukladno uvjetima AOZ 1/2014)'
		WHEN gr.val_char = 'OV' THEN 'Kombinacija I -osiguranjem je pokriven trošak najma osobnog vozila za vrijeme popravka osiguranog vozila koje je oštećeno u sudaru s drugim vozilo. Trošak najma vozila je cijena najamnog dana, ali najviše do 200,00 HRK po danu-najviše do 5 dana (sukladno uvjetima UKAO 1/2014)'
		ELSE '' 
	END as txt_2,
	CASE 
		--WHEN gr.val_char = 'LD' THEN 'Osiguranje troškova pravne zaštite uslijed uporabe vozila.'
		WHEN gr.val_char = 'OV' THEN 'Trošak najma vozila do 5 dana za vrijeme popravka oštećenog vozila.'
		ELSE '' 
	END as txt_3
	--DORADA PPOM
	, CASE WHEN CHARINDEX(grPPOM.VALUE, po.nacin_leas) > 0 THEN 1 ELSE 0 END AS PPOM
	--KRAJ DORADE
	, CASE WHEN IsNULL(r.id_rtip_base,'') = '' THEN 0 ELSE 1 END AS rtip_izvedeni
	, CASE WHEN osig.id_stroska = 'KO' AND ik.id_stroska = 'IK' THEN ' (u izračun EKS uključeni su predviđeni troškovi kasko osiguranja koji pokrivaju rizik od krađe i totalne štete u iznosu od '+dbo.gfn_gccif(osig.znesek)+' '+po.id_val+' godišnje i interkalarna kamata za period od 30 dana)' ELSE '' END as txt_osig
FROM dbo.PONUDBA po 
INNER JOIN dbo.DAV_STOP ds ON po.id_dav_st = ds.id_dav_st
LEFT JOIN dbo.PARTNER pa ON po.id_kupca = pa.id_kupca 
LEFT JOIN dbo.vrst_opr v on po.id_vrste = v.id_vrste
LEFT JOIN dbo.tecajnic t on po.id_tec = t.id_tec
LEFT JOIN dbo.obdobja o on po.id_obd = o.id_obd
LEFT JOIN dbo.dav_stop ds2 on po.id_dav_st = ds2.id_dav_st
LEFT JOIN dbo.rtip r on po.id_rtip = r.id_rtip
LEFT JOIN dbo.general_register gr on 'OSIG_PONUDA' = gr.id_register AND 0 = gr.neaktiven AND po.id_vrste = gr.id_key
LEFT JOIN dbo.general_register grPPOM on grPPOM.id_register = 'RLC Reporting list' AND grPPOM.neaktiven = 0 AND grPPOM.id_key = 'RLC_PPOM_NL'
LEFT JOIN (SELECT top 1 id_pon, id_stroska, znesek from dbo.pon_terj_stros where id_stroska = 'KO' and id_pon=@Id1 order by id_pon_terj_stros asc) osig on po.id_pon=osig.id_pon
LEFT JOIN (SELECT top 1 id_pon, id_stroska FROM dbo.pon_terj_stros WHERE id_stroska = 'IK' AND id_pon = @Id1 ORDER BY id_pon_terj_stros ASC) ik ON po.id_pon=osig.id_pon
WHERE CAST(po.id_pon AS VARCHAR(20)) = @Id1