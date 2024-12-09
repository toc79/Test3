{Offer.ukupno_bud_p/100}
{Format("{0:N2}", (Offer.opcija-Offer.opcija_ppmv)+Offer.varscina)}
{Format("{0:N2}", ((Offer.opcija-Offer.opcija_ppmv)+Offer.varscina)*(Offer.davek/100))}
{Format("{0:N2}", Offer.opcija_ppmv)}
{Format("{0:N2}", ((Offer.opcija-Offer.opcija_ppmv)+Offer.varscina)+(((Offer.opcija-Offer.opcija_ppmv)+Offer.varscina)*(Offer.davek/100))+Offer.opcija_ppmv)}

DISABLE
{Offer.opcija_p/100} => isto
{Format("{0:N2}", Offer.opcija-Offer.opcija_ppmv)}
{Format("{0:N2}", Offer.opcija_davek)}
{Format("{0:N2}", Offer.opcija_ppmv)}
{Format("{0:N2}", Offer.opcija+Offer.opcija_davek)}



@id1 VARCHAR(20), @id2 char(1) 

SET @id1 = CAST(SUBSTRING(@id, 0, CHARINDEX(';',@id)) AS VARCHAR(20))
SET @id2 = CAST(SUBSTRING(@id, CHARINDEX(';',@id)+1, LEN(RTRIM(@id))) AS CHAR(1))

--DECLARE @zakup_nek VARCHAR(100) --ne koristi se 
--SELECT @zakup_nek = val FROM custom_settings WHERE code = 'Nova.LE.Zakup.Nekretnina' --ne koristi se 

SELECT po.id_pon, po.naziv_kup, po.fix_del,
	pa.naz_kr_kup, po.obr_mera, po.ef_obrm, po.str_notar, pa.ulica_sed, pa.id_poste_sed, pa.mesto_sed, 
	pa.vr_osebe, po.dat_pon, po.pred_naj, LTRIM(RTRIM(po.id_rtip)) AS id_rtip, LTRIM(RTRIM(r.naziv)) as rtip_naziv,
	po.id_vrste, po.st_predr, ISNULL(CONVERT(VARCHAR(10),po.dat_predr,104), '') as dat_predr, 
	ISNULL(CONVERT(varchar(10),po.predr_do,104), '') as predr_do, 
	po.traj_naj, po.vr_val, ds.davek, po.st_obrok, po.opis_pred,
	po.id_val,
	dbo.gfn_xchange(po.id_tec, po.str_notar,'000', po.dat_pon) as str_notar_val, po.oststr,
	LTRIM(RTRIM(o.naziv_tuj3)) AS naziv_tuj3,
	LTRIM(RTRIM(o.naziv_tuj2)) AS naziv_tuj2,
	LTRIM(RTRIM(o.naziv_tuj1)) AS naziv_tuj1,
	CASE WHEN po.je_foseba = 1 THEN 'polica koja pokriva totalnu štetu i krađu obavezno je' ELSE 'je obavezno' END AS 'kasko_txt',
	ke1.vrednost,
	ke2.val_string,
	--DORADA PPMV
	po.vr_neto, po.vr_bruto, po.robresti_val, po.neto, po.bruto, po.robresti_dom, po.varscina, po.varsc_p,
	po.prv_obr_n, po.prv_obr, po.prv_obr_p, CAST(po.robresti_val*(po.prv_obr_p/100) AS DECIMAL(18,2)) AS prv_obr_ppmv,
	po.ost_obr, po.ost_obr_n, CAST((po.robresti_val-(po.robresti_val*(po.prv_obr_p/100))-(po.robresti_val*(po.opcija_p/100)))/nullif(po.st_obrok,0) AS DECIMAL(18,2)) AS ost_obr_ppmv,
	po.man_str_n, po.man_str, po.manstr_p,
	po.opcija, po.opcija_p, CAST(po.robresti_val*(po.opcija_p/100) AS DECIMAL(18,2)) AS opcija_ppmv,
	CAST((po.opcija-(po.robresti_val*(po.opcija_p/100))) *(ds2.davek/100) AS DECIMAL(18,2)) AS opcija_davek,
	po.plac_zac, po.dovol_km, po.cena_dkm, po.je_foseba, po.id_dav_op,
	IIF(ham.vrednost = 'DA', 1, 0) AS print_ham,
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
	LTRIM(RTRIM(o.naziv)) as obd_naziv, po.ddv,
	ISNULL(CASE WHEN gr.id_key = po.id_vrste THEN 1 ELSE 0 END, 0) as print_str_osig, 
	CAST(@id2 as bit) as print_str_osig_code_before,
	CASE WHEN (v.se_regis = '*' AND (v.tip_opr = 'V' or v.tip_opr = 'P')  AND po.oststr = 0 and (dbo.gfn_Nacin_leas_HR(po.nacin_leas) = 'OL' or (dbo.gfn_Nacin_leas_HR(po.nacin_leas) != 'OL' and (pa.vr_osebe != 'FO' and po.je_foseba=0))) or v.id_grupe = 'VBO')  THEN 1 ELSE 0 END as print_osig_kasko,
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
,CASE WHEN osig.id_stroska = 'KO' AND ik.id_stroska = 'IK' THEN ' (u izračun EKS uključeni su ' 
		--za VBO (plovila) ELSE VNC (nova vozila), VUC (rabljena vozila) i VLT (laka komercijalna) 
		+ CASE WHEN v.id_grupe = 'VBO' THEN 'troškovi kasko osiguranja koji su poznati davatelju leasinga' ELSE CASE WHEN po.je_foseba = 1 THEN 'rok otplate, nominalna kamata, trošak obrade te ' ELSE '' END + 'minimalno zahtjevani troškovi kasko osiguranja, koji su poznati davatelju leasinga, a koji pokrivaju rizik od krađe i totalne štete' END +' u iznosu od '+dbo.gfn_gccif(osig.znesek)+' '+po.id_val+' godišnje'
			-- za trošak Procjena rabljenog objekta leasinga 
			+ CASE WHEN pr.id_stroska = 'PR' THEN ', trošak procjene objekta leasinga u iznosu od '+dbo.gfn_gccif(pr.znesek)+' '+po.id_val+' jednokratno' ELSE '' END 
	+' i interkalarna kamata za period od 30 dana)' 
	 WHEN po.je_foseba = 1 and v.id_grupe in ('VNC','VLT', 'VUC', 'VOW') THEN ' (u izračun EKS uključeni su ' 
		--za VBO (plovila) ELSE VNC (nova vozila), VUC (rabljena vozila) i VLT (laka komercijalna) 
		+ CASE WHEN v.id_grupe = 'VBO' THEN 'troškovi kasko osiguranja koji su poznati davatelju leasinga' ELSE CASE WHEN po.je_foseba = 1 THEN 'rok otplate, nominalna kamata, trošak obrade' ELSE '' END end 
			-- za trošak Procjena rabljenog objekta leasinga 
			+ CASE WHEN pr.id_stroska = 'PR' THEN ', trošak procjene objekta leasinga u iznosu od '+dbo.gfn_gccif(pr.znesek)+' '+po.id_val+' jednokratno' ELSE '' END 
	+' i interkalarna kamata za period od 30 dana)' ELSE '' END as txt_osig,
	CASE WHEN rtrim(ltrim(po.kategorija1)) = '002' then 'Mjesečna' else 'Godišnja' END AS razdoblje_km
	,po.dej_obr,
	CASE WHEN po.id_obd = '005' AND po.st_obrok IN(1,2) THEN 1 ELSE 0 END AS god_txt1,
	CASE WHEN po.st_obrok = 1 THEN '50' WHEN po.st_obrok = 2 THEN '33' END AS god_txt2,
	CASE WHEN po.st_obrok = 1 THEN 'odmah po aktivaciji ugovora' WHEN po.st_obrok = 2 THEN 'u dva dijela - 1.dio odmah po aktivaciji ugovora te 2.dio nakon godinu dana' ELSE '' END AS god_txt3,
	ltrim(rtrim(cast(po.kategorija as varchar(10)))) as kategorija,
	CASE WHEN dbo.gfn_Nacin_leas_HR(po.nacin_leas) = 'OL' THEN 'obrok' ELSE 'rata' END AS po_terj,
	CASE WHEN dbo.gfn_Nacin_leas_HR(po.nacin_leas) = 'OL' THEN 'obroka' ELSE 'ratu' END AS po_terj2,
	CASE WHEN LTRIM(RTRIM(ISNULL(ORYX.vrednost,'')))='Paket broj 2' THEN 2
	WHEN LTRIM(RTRIM(ISNULL(ORYX.vrednost,'')))='Paket broj 1' THEN 1 ELSE 0 END AS oryx_flag,
    CASE WHEN LTRIM(RTRIM(ISNULL(WALLISU.vrednost,'')))<>'' THEN 1 ELSE 0 END AS wallisu_flag,
    CASE WHEN v.id_grupe in ('VNC','VLT', 'VUC', 'VOW') and po.je_foseba=1 and dbo.gfn_Nacin_leas_HR(po.nacin_leas) != 'OL'  then 1 else 0 end as ispis_dopisa
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
LEFT JOIN (SELECT top 1 id_pon, id_stroska FROM dbo.pon_terj_stros WHERE id_stroska = 'IK' AND id_pon = @Id1 ORDER BY id_pon_terj_stros ASC) ik ON po.id_pon=ik.id_pon
LEFT JOIN (Select id_pon, id_stroska, SUM(znesek) AS znesek from dbo.pon_terj_stros where id_stroska = 'PR' and id_pon=@Id1 GROUP BY id_pon, id_stroska) pr ON po.id_pon=pr.id_pon --dodana suma
OUTER APPLY (
SELECT c.vrednost FROM dbo.kategorije_entiteta a
	LEFT JOIN dbo.kategorije_tip b ON a.id_kategorije_tip = b.id_kategorije_tip
	LEFT JOIN dbo.kategorije_sifrant c ON a.id_kategorije_sifrant = c.id_kategorije_sifrant
	WHERE b.entiteta = 'PONUDBA' AND ISNULL(c.vrednost, '') != '' AND b.sifra = 'AH_akcija' AND a.id_entiteta = po.id_pon
) ke1
OUTER APPLY (
SELECT a.val_string FROM dbo.kategorije_entiteta a
	LEFT JOIN dbo.kategorije_tip b ON a.id_kategorije_tip = b.id_kategorije_tip
	WHERE b.entiteta = 'PONUDBA' AND ISNULL(a.val_string, '') != '' AND b.sifra = 'GP' AND a.id_entiteta = po.id_pon
) ke2
OUTER APPLY (
SELECT b.vrednost from dbo.kategorije_entiteta a
	JOIN dbo.kategorije_sifrant b ON a.id_kategorije_sifrant = b.id_kategorije_sifrant
	JOIN dbo.kategorije_tip c ON a.id_kategorije_tip = c.id_kategorije_tip
	WHERE b.vrednost = 'DA' AND c.entiteta = 'PONUDBA' AND c.naziv = 'HAMAG' AND a.id_entiteta = @id1
) ham
OUTER APPLY (
SELECT b.vrednost from dbo.kategorije_entiteta a
	JOIN dbo.kategorije_sifrant b ON a.id_kategorije_sifrant = b.id_kategorije_sifrant
	JOIN dbo.kategorije_tip c ON a.id_kategorije_tip = c.id_kategorije_tip
	WHERE b.neaktiven = 0 AND c.entiteta = 'PONUDBA' AND c.naziv = 'ORYX' AND a.id_entiteta = @id1
) ORYX
OUTER APPLY (
SELECT b.vrednost from dbo.kategorije_entiteta a
	JOIN dbo.kategorije_sifrant b ON a.id_kategorije_sifrant = b.id_kategorije_sifrant
	JOIN dbo.kategorije_tip c ON a.id_kategorije_tip = c.id_kategorije_tip
	WHERE b.neaktiven = 0 AND c.entiteta = 'PONUDBA' AND c.naziv = 'WALLIS' AND a.id_entiteta = @id1
) WALLISU
WHERE CAST(po.id_pon AS VARCHAR(20)) = @Id1


-- Ugovor

Ostatak vrijednosti po isteku trajanja ovog Ugovora iznosi ukupno {Format("{0:N2}",pogodba.UK_PR_VRED)} {pogodba.id_val.Trim()}, s pripadajućim PDV-om u iznosu od {Format("{0:N2}",pogodba.UK_PR_VRED_PDV)} {pogodba.id_val}{IIF(pogodba.robresti_val>0," i razmjernim dijelom posebnog poreza na motorna vozila u iznosu od "+Format("{0:N2}", pogodba.OPC_PPMV)+" "+pogodba.id_val.Trim(),"")}.
{IIF(pogodba.p_ks==1,ToProperCase(pogodba.naziv_tuj3)+" "+pogodba.pog_terj+" iz Članka 3. ovog Ugovora je ugovoren uz primjenu referentne stope "+pogodba.r_naziv.Trim()+" za "+pogodba.id_val+", te "+IIF(pogodba.izv_prom_ks==1, "čini zajedno sa ugovorenom maržom, iskazanom na Leasing ponudi, dio implicitne kamatne stope. Ukupna implicitna kamatna stopa ne može biti niža od kamatne marže. Ukoliko je ugovorena referentna kamatna stopa za odgovarajuće obračunsko razdoblje negativna tj. ispod nule, tada će ukupna implicitna kamatna stopa za to obračunsko razdoblje biti jednaka visini kamatne marže."+System.Environment.NewLine+"P", "p")+"romjenom referentne kamatne stope Davatelju leasinga pristoji pravo promijeniti visinu "+pogodba.naziv_tuj3+" "+pogodba.pog_terj2+" i sukladno tomu promijeniti iznos računa za "+pogodba.naziv_tuj3+" "+pogodba.pog_terj2+" leasinga, a kako je detaljno opisano u točki 7. Općih uvjeta ugovora o "+pogodba.tip_leas.Trim()+" leasingu "+pogodba.spl_pog.Trim()+". "+IIF(pogodba.izv_prom_ks==1, System.Environment.NewLine+"U slučaju porasta visine referentne kamatne stope, mjesečni obrok će porasti u punoj mjeri porasta te vrijednosti."+System.Environment.NewLine, "")+"Obavijest o promijeni "+pogodba.naziv_tuj3+" "+pogodba.pog_terj2+" dostavlja se Primatelju leasinga u pisanom obliku, i to uz račun za prvi mjesec referentnog period kada se mijenja "+pogodba.naziv_tuj3+" "+pogodba.pog_terj+", a koji račun Davatelj leasinga izdaje/obračunava Primatelju leasinga svakog 1. (prvog) dana u mjesecu za tekući mjesec."+System.Environment.NewLine+"Podaci o visini ugovorene stope "+pogodba.r_naziv_fix+" će Primatelju leasinga biti javno dostupni na internetskim stranicama Raiffeisenbank Austria d.d., pod Istraživanja, Makroekonomija, Indikatori: "+Settings.http_banka+", kao i na oglasnoj ploči u poslovnim prostorijama Davatelja leasinga.","")}

SELECT 
	a.id_pog,
	a.pred_naj,
	a.prv_obr,
	round(a.prv_obr * 100 / (100 + st.davek), 2) as prv_obr_neto,
	a.dat_sklen,
	a.id_val,
	a.ost_obr,
	round(a.ost_obr * 100 / (100 + st.davek), 2) as ost_obr_neto,
	pd.debit as sum_debit_rata,
	a.id_dav_st,
	a.man_str,
	round(a.man_str * 100 / (100 + st.davek), 2) as man_str_neto,
	round(a.man_str * st.davek / (100 + st.davek), 2) as man_str_davek,
	a.st_obrok,
	a.dovol_km,
	CAST(a.dovol_km AS int) AS dovol_km_int,
	a.cena_dkm,
	a.traj_naj,
	a.obr_mera,
	a.vr_val, a.vr_val_zac,
	CASE dbo.gfn_Nacin_leas_HR(a.nacin_leas) WHEN 'OJ' THEN a.vr_val_zac-a.robresti_val ELSE c.vr_neto END AS pog_neto,
	CAST(ROUND(a.vr_val/(1+(op.davek/100)),2) as decimal(18,2)) as vr_val_neto,
	a.varscina,
	a.opcija,
	a.vnesel, dbo.gfn_GetUserDesc(a.vnesel) AS vnesel_desc, a.robresti_val, a.robresti_sit, round(c.vr_bruto-c.vr_neto,2) as pred_ddv,
	a.dni_zap,
	a.id_rtip,
	a.dej_obr,
	a.fix_del,
	a.id_tec,
	LTRIM(RTRIM(r.naziv)) AS r_naziv,
	case when r.naziv like '%EURIBOR%' then 'EURIBOR-a'  else '' end AS r_naziv_fix,
	LTRIM(RTRIM(r.naziv_tuj2)) as r_naziv_tuj2,
	LTRIM(RTRIM(r_izv.naziv_tuj2)) as r_izv_naziv_tuj2,
case when left(r.naziv, 1)='3' then 'kvartalno'
		when left(r.naziv, 1)='6' then 'polugodišnje'
		when left(r.naziv, 1)='12' then 'godišnje'
		else '' end as r_razdoblje_naziv,
	left(r.naziv, 1) AS r_naz_mj,
	CASE WHEN a.nacin_leas = gr.value THEN 1 ELSE 0 END AS ppom,
	CASE WHEN p.vr_osebe IN('FO','F1') THEN 'ugovorena/' ELSE '' END AS fo_kam,
case when left(r.naziv, 1)='3' THEN	' (1. siječnja, 1. travnja, 1. srpnja i 1. listopada za pripadajuće tromjesečje). U tekućem kvartalu primjenjuje se visina RKS-a od zadnjeg radnog dana prethodnog kvartala (31. ožujak, 30. lipanj, 30. rujan, 31. prosinac).'
    else ' (1. siječnja i 1. srpnja za pripadajuće polugodište). U tekućem polugodištu primjenjuje se visina RKS-a od zadnjeg radnog dana prethodnog polugodišta (30. lipanj, 31. prosinac).' end as kvartalno_polugodisnje,
	CASE WHEN a.id_rtip != '0' THEN 1 ELSE 0 END AS p_ks,	
	CASE WHEN a.id_rtip != '0' AND right(rtrim(ltrim(a.id_rtip)), 1) ='I' THEN 1 ELSE 0 END AS izv_prom_ks,
	CASE WHEN a.id_rtip != '0' AND right(rtrim(ltrim(a.id_rtip)), 1) !='I' THEN 1 ELSE 0 END AS prom_ks,
	CASE WHEN a.id_rtip = '0' THEN 1 ELSE 0 END AS fix_ks,
	CASE WHEN dbo.gfn_Nacin_leas_HR(a.nacin_leas) != 'OL' AND p.vr_osebe NOT IN('FO','F1') THEN 1 ELSE 0 END AS odredbe,
	CASE WHEN dbo.gfn_Nacin_leas_HR(a.nacin_leas) = 'OL' OR (dbo.gfn_Nacin_leas_HR(a.nacin_leas) != 'OL' AND p.vr_osebe IN('FO','F1')) THEN '10' ELSE '9' END AS clan10,
	CASE WHEN dbo.gfn_Nacin_leas_HR(a.nacin_leas) = 'OL' OR (dbo.gfn_Nacin_leas_HR(a.nacin_leas) != 'OL' AND p.vr_osebe IN('FO','F1')) THEN '11' ELSE '10' END AS clan11,
	CASE WHEN dbo.gfn_Nacin_leas_HR(a.nacin_leas) != 'OL' AND p.vr_osebe IN('FO','F1') THEN '6. i' ELSE '' END AS fo_ou,
	IIF(p.vr_osebe IN('FO','F1'), 1, 0) AS potrosac,
--DORADA ZA PPMV
	round((a.prv_obr-c.robresti_val*(c.prv_obr_p/100)) * st.davek / (100 + st.davek), 2) as PRV_OBR_DAVEK,
	c.prv_obr-c.prv_obr_n AS PRV_OBR_DDV, 
	round(c.prv_obr_n-(c.robresti_val*(c.prv_obr_p/100)),2) as PRV_OBR_N_BP,
	round(c.robresti_val*(c.prv_obr_p/100),2) as PRV_OBR_PPMV,
	round(c.ost_obr_n-((c.robresti_val-(c.robresti_val*(c.prv_obr_p/100))-(c.robresti_val*(c.opcija_p/100)))/c.st_obrok),2) as OST_OBR_N_BP,
	round((a.ost_obr-((c.robresti_val-(c.robresti_val*(c.prv_obr_p/100))-(c.robresti_val*(c.opcija_p/100)))/c.st_obrok)) * st.davek / (100 + st.davek), 2) as OST_OBR_DAVEK,
	c.ost_obr_b-c.ost_obr_n as OST_OBR_DDV,
	round(((c.robresti_val-(c.robresti_val*(c.prv_obr_p/100))-(c.robresti_val*(c.opcija_p/100)))/c.st_obrok),2) as OST_OBR_PPMV,
	c.ost_obr_b as OST_OBR_B,
--ALLT(TRANS(ROUND((_ponudba.opcija-(_ponudba.robresti_val*(_ponudba.opcija_p/100)))*(lookup(dav_stop_pp.davek, _ponudba.id_dav_st, dav_stop_pp.id_dav_st)/100),2),GCCIF)) --OPC_DDV
	round((a.opcija-(a.robresti_val*(c.opcija_p/100)))*(st.davek / 100),2) as OPC_DDV,
	round(a.robresti_val*(c.opcija_p/100),2) as OPC_PPMV,
--ALLT(TRANS(ROUND(((_ponudba.opcija-(_ponudba.robresti_val*(_ponudba.opcija_p/100)))*(lookup(dav_stop.davek, _ponudba.id_dav_st, dav_stop.id_dav_st)/100))+_ponudba.opcija,2),GCCIF)) --OPC_B
	round(a.opcija + (a.opcija-(a.robresti_val*(c.opcija_p/100)))*(st.davek / 100),2) as OPC_B,
--UK_PR_VRED_N
--ROUND(_ponudba.opcija-(_ponudba.robresti_val*(_ponudba.opcija_p/100))+_ponudba.varscina,2)
	round((a.opcija-(a.robresti_val*(c.opcija_p/100))+a.varscina),2) AS UK_PR_VRED_N, 
-- UK_PR_VRED_DDV
--ROUND((_ponudba.opcija-(_ponudba.robresti_val*(_ponudba.opcija_p/100))+_ponudba.varscina)*(lookup(dav_stop.davek, _ponudba.id_dav_st, dav_stop.id_dav_st)/100),2)
	round((a.opcija-(a.robresti_val*(c.opcija_p/100))+a.varscina)*(st.davek/100),2) as UK_PR_VRED_PDV,
--UK_PR_VRED 
--UK_PR_VRED_N+UK_PR_VRED_DDV+ROUND(_ponudba.robresti_val*(_ponudba.opcija_p/100),2)
	round(((a.opcija-(a.robresti_val*(c.opcija_p/100))+a.varscina))+((a.opcija-(a.robresti_val*(c.opcija_p/100))+a.varscina)*(st.davek/100))+(a.robresti_val*(c.opcija_p/100)),2) AS UK_PR_VRED,
--KRAJ DORADE PPMV
	CASE WHEN v.se_regis = '*' THEN 1 ELSE 0 END as print_se_regis,
	v.tip_opr,
	p.polni_naz as part_polni_naz,
	p.dav_stev as part_dav_stev,
	p.ulica_sed as part_ulica_sed,
	
	p.id_poste_sed as part_id_poste_sed,
	p.mesto_sed as part_mesto_sed,
	p.emso as part_emso,
	p.direktor as part_direktor,
	p.vr_osebe as part_vr_osebe,
	p.naz_kr_kup as part_naz_kr_kup,
	p.stev_reg as part_stev_reg,
	a.id_pon,
	c.dat_pon,
	c.plac_zac,
	a.st_predr,
	CASE WHEN a.dat_predr IS NULL THEN ' '
	ELSE right('0' + cast(datepart(dd,a.dat_predr) as varchar(2)), 2)+'.'+right('0' + cast(datepart(mm,a.dat_predr) as varchar(2)), 2)+'.'+	cast(datepart(yyyy,a.dat_predr) as char(4))+'.' END as dat_predr,
	c.manstr_p,
	c.opcija_p,
	c.varsc_p,
	c.prv_obr_p,
	d.naz_kr_kup as dob_naz_kr_kup,
	d.dav_stev as dob_dav_stev,
	d.ulica_sed as dob_ulica_sed,
	d.id_poste_sed as dob_id_poste_sed,
	d.mesto_sed as dob_mesto_sed,
	d.emso as dob_emso,
	st.davek as st_davek,
	op.davek as op_davek,
	dbo.gfn_Nacin_leas_HR(a.nacin_leas) as leasing,
	CASE WHEN dbo.gfn_Nacin_leas_HR(a.nacin_leas) = 'OL' THEN 1 ELSE 0 END AS ozn_leas,
	CASE WHEN dbo.gfn_Nacin_leas_HR(a.nacin_leas) = 'OL' THEN 'operativnom' ELSE 'financijskom' END AS tip_leas,
	t.naziv as naziv_tec,
	a.naziv_tuje,
	isnull(kat.value,'') as kateg1_value,
	IIF(ham.vrednost = 'DA', ham.spl_pog, a.spl_pog) AS spl_pog,
	strm.mesto as str_mesto,
	LTRIM(RTRIM(ob.naziv_tuj3)) AS naziv_tuj3,
	LTRIM(RTRIM(ob.naziv_tuj2)) AS naziv_tuj2,
	LTRIM(RTRIM(ob.naziv_tuj2)) AS naziv_tuj1,
	ob.naziv as naziv_raz,
	dbo.gfn_xchange(a.id_tec,c.str_notar,'000',c.dat_pon) as str_notar, 
	ISNULL(man_stros.bruto,0) AS man_stros_bruto,
	CASE WHEN p.vr_osebe IN('FO','F1') THEN 1 ELSE 0 END as txt_fo,
	a.kategorija,
	vo.sifra as osebe_sifra,
	a.id_obd,
	CASE WHEN dbo.gfn_Nacin_leas_HR(a.nacin_leas) = 'OL' THEN 'obrok' ELSE 'rata' END AS pog_terj,
	CASE WHEN dbo.gfn_Nacin_leas_HR(a.nacin_leas) = 'OL' THEN 'obroka' ELSE 'ratu' END AS pog_terj2,
	IIF(ham.vrednost = 'DA', 1, 0) AS print_ham
From pogodba a
LEFT JOIN dbo.vrst_opr v ON a.id_vrste = v.id_vrste
LEFT JOIN dbo.partner p ON a.id_kupca = p.id_kupca
LEFT JOIN dbo.ponudba c ON a.id_pon = c.id_pon
LEFT JOIN dbo.partner d ON a.id_dob = d.id_kupca
LEFT JOIN (select id_register, id_key, [value] from dbo.general_register where id_register = 'KATEGORIJA1') kat on a.kategorija1 = kat.id_key
LEFT JOIN (select id_register, id_key, value from dbo.general_register where id_register = 'RLC Reporting list' and id_key = 'RLC_PPOM_NL') gr on a.nacin_leas = gr.value
INNER JOIN dbo.dav_stop st ON st.id_dav_st = a.id_dav_st
INNER JOIN dbo.dav_stop op ON op.id_dav_st = a.id_dav_op
INNER JOIN dbo.nacini_l nl ON a.nacin_leas = nl.nacin_leas
INNER JOIN dbo.tecajnic t on a.id_tec = t.id_tec
INNER JOIN dbo.obdobja ob ON a.id_obd = ob.id_obd
LEFT JOIN dbo.strm1 strm on a.id_strm = strm.id_strm
LEFT JOIN (Select pp.id_cont, Sum(pp.neto) as neto, sum(pp.obresti) as kamata, sum(pp.davek) as davek, sum(pp.debit) as debit 
	From dbo.planp pp Inner Join dbo.vrst_ter vt on pp.id_terj = vt.id_terj
			Where vt.sif_terj='LOBR' and pp.id_cont = @id group by pp.id_cont) pd on a.id_cont = pd.id_cont
LEFT JOIN (Select pp.id_cont, Sum(pp.neto+pp.marza) as neto, sum(pp.davek) as davek, sum(pp.debit) as bruto 
	From dbo.planp pp Inner Join dbo.vrst_ter vt on pp.id_terj = vt.id_terj
			Where vt.sif_terj='MSTR' and pp.id_cont = @id group by pp.id_cont) man_stros on a.id_cont = pd.id_cont
LEFT JOIN dbo.rtip r ON a.id_rtip = r.id_rtip
LEFT JOIN (SELECT b.id_rtip_base, a.naziv_tuj2
	FROM dbo.RTIP a
			INNER JOIN dbo.RTIP b on a.id_rtip = b.id_rtip_base) r_izv ON r.id_rtip_base = r_izv.id_rtip_base
			LEFT JOIN dbo.vrst_ose vo on vo.vr_osebe=p.vr_osebe
OUTER APPLY (
	SELECT
		c.vrednost, e.spl_pog
	FROM dbo.kategorije_entiteta b
	LEFT JOIN dbo.kategorije_sifrant c ON b.id_kategorije_sifrant = c.id_kategorije_sifrant
	LEFT JOIN dbo.kategorije_tip d ON b.id_kategorije_tip = d.id_kategorije_tip
	OUTER APPLY (
		SELECT 'HB ' + VALUE AS spl_pog FROM dbo.general_register WHERE id_register = 'RLC_OPCI_UVJETI' AND val_char = d.naziv and val_datetime = (select MAX(val_datetime) as val_datetime from dbo.GENERAL_REGISTER WHERE id_register = 'RLC_OPCI_UVJETI' and VAL_CHAR = 'HAMAG' HAVING a.DAT_SKLEN >= MAX(val_datetime))
	) e
	WHERE c.vrednost = 'DA' AND d.entiteta = 'POGODBA' AND d.naziv = 'HAMAG' AND b.id_entiteta = @id
) ham
where a.id_cont= @id