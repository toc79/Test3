-- 29.07.2020 g_tomislav MR 45163 - dodan dok_hr i pp_hr

declare @id_terj_LOBR char(2) = (select id_terj from dbo.vrst_ter where sif_terj = 'LOBR')

SELECT 	
	A.brez_davka, A.datum, A.ddv_date, A.ddv_id, A.debit, A.debit_davek, A.debit_neto, 
	A.id_cont, A.id_dav_st, A.id_kupca, A.id_rep_ind, A.id_rtip, A.id_tec, A.izpisan, 
	A.ndatum, A.ndavek, A.neobdav, A.nindeks, A.nmarza, A.nneto, A.nobresti, A.nobrok, 
	A.old_ddv_d, A.old_ddv_id, A.opisdok, A.opombe, A.sdatum, A.sdavek, A.sindeks, 
	A.smarza, A.sneto, A.sobresti, A.sobrok, A.st_obrokov, A.timestamp, A.vnesel, A.vrsta_rac,
	A.st_dok, A.ddv_st_dok,
	B.id_pog, B.nacin_leas, B.pred_naj, B.dobrocno, B.fix_del, B.sklic,
	B.po_tecaju/(CASE WHEN N.id_tec_new IS NULL THEN 1 ELSE N.faktor END) AS po_tecaju,
	B.id_strm, B.dat_aktiv, B.ddv,
	C.naz_kr_kup, C.naziv1_kup, C.naziv2_kup, C.ulica, C.mesto, C.dav_stev, C.id_poste, 
	C.polni_naz, C.ulica_sed, C.id_poste_sed, C.mesto_sed, C.emso, C.vr_osebe, C.stev_reg,
	D.naziv as naziv_ind, D.id_tiprep,
	CASE WHEN A.id_tec = '000' THEN 'KN' ELSE T.id_val END AS id_val,
	E.stevilka as st_poste, F.davek, N.naziv as naziv_tec_pog, 
	T.naziv as naziv_tec_rep_ind, O.id_grupe, PP.dat_zap as ddv_dat_zap,
	KS.id_klavzule, KS.klavzula,
	ro.izdal as ro_izdal, ro.dat_vnosa as ro_dat_vnosa,
	dbo.gfn_transformDDV_ID_HR(a.ddv_id,a.ddv_date) as Fis_BrRac,
	RTRIM(CONVERT(VARCHAR(50), ro.dat_vnosa,104) + '. ' + CONVERT(VARCHAR(50), ro.dat_vnosa,108)) as Dat_Izdavanja,
	CASE WHEN a.ddv_date < ISNULL(cust.val, '20500101') AND ISNULL(a.ddv_id,'')<>''  THEN 1 ELSE 0 END as print_r1,
	dbo.gfn_Nacin_leas_HR(b.nacin_leas) as tip_leas, CASE WHEN ISNULL(a.ddv_id,'') = '' THEN 0 ELSE 1 END AS Invoice,
	CASE WHEN A.debit_neto+A.brez_davka <> 0 THEN 1 ELSE 0 END AS Print_C1,
	CASE WHEN LTRIM(RTRIM(c.ulica)) = LTRIM(RTRIM(c.ulica_sed)) THEN 1 ELSE 0 END AS Print_C2
	, case when dok_hr.id_obl_zav is null then 0 else 1 end as Print_moratorij
	, pp_hr.datum_dok as datum_dok_lobr_hr
FROM dbo.rep_ind A  
INNER JOIN dbo.pogodba B ON A.id_cont = B.id_cont
INNER JOIN dbo.tecajnic T ON T.id_tec = A.id_tec
INNER JOIN dbo.tecajnic N ON N.id_tec = B.id_tec
INNER JOIN dbo.partner C ON B.id_kupca = C.id_kupca
INNER JOIN dbo.rtip D ON D.id_rtip = A.id_rtip
INNER JOIN dbo.poste E ON C.id_poste = E.id_poste
LEFT JOIN dbo.dav_stop F ON A.id_dav_st = F.id_dav_st
LEFT JOIN dbo.vrst_opr O ON B.id_vrste = O.id_vrste
LEFT JOIN dbo.planp PP WITH (NOLOCK) ON a.ddv_st_dok = PP.st_dok
LEFT JOIN dbo.rac_out RO ON RO.ddv_id = A.ddv_id
LEFT JOIN dbo.klavzule_sifr KS ON KS.id_klavzule = RO.id_klavzule
LEFT JOIN dbo.custom_settings cust on cust.code = 'Nova.Reports.Print_R1'
outer apply (select top 1 id_obl_zav, velja_do --zacetek, 
			from dbo.dokument 
			where id_obl_zav = 'HR' 
			and A.ddv_date between zacetek and isnull(velja_do, '99991231') --velja_do je popunjena na svim dokumentima, nije obavezno polje, pa sam ipak dodao isnull
			and id_cont = a.id_cont) dok_hr -- and status_akt = 'A' ako je postojao HR dokument
outer apply (select top 1 datum_dok 
			from dbo.planp 
			where id_terj = @id_terj_LOBR
			and datum_dok > A.ddv_date  -- datum izdavanja obavijesti (datum izvršavanja reprograma)
			and id_cont = a.id_cont
			order by datum_dok) pp_hr --prva rata nakon RPG
WHERE A.id_rep_ind = @id