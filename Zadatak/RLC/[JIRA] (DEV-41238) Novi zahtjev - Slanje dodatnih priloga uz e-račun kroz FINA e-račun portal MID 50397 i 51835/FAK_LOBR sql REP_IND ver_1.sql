SELECT 	
	--A.brez_davka, A.datum, A.ddv_date, A.debit_davek, A.debit_neto,
	--A.id_cont, A.id_dav_st, A.id_kupca, A.id_rtip , A.id_tec, A.izpisan, A.ndavek, A.neobdav, A.nindeks, A.nmarza, 
	--A.old_ddv_d, A.old_ddv_id, A.opisdok, A.opombe, A.sdatum, A.sdavek, A.sindeks, A.smarza, 	--A.st_dok, A.ddv_st_dok,
	--A.timestamp, A.vnesel, A.vrsta_rac,
	--C.naz_kr_kup, C.ulica, C.mesto, C.id_poste, 
	--C.ulica_sed, C.id_poste_sed, C.mesto_sed, --C.emso, C.vr_osebe, C.stev_reg,
	--E.stevilka as st_poste, 
	--F.davek, 	--N.naziv as naziv_tec_pog, 
	--T.naziv as naziv_tec_rep_ind, O.id_grupe, PP.dat_zap as ddv_dat_zap,
	--ro.izdal as ro_izdal, ro.dat_vnosa as ro_dat_vnosa, --dbo.gfn_transformDDV_ID_HR(a.ddv_id,a.ddv_date) as Fis_BrRac, --RTRIM(CONVERT(VARCHAR(50), ro.dat_vnosa,104) + '. ' + CONVERT(VARCHAR(50), ro.dat_vnosa,108)) as Dat_Izdavanja, 	--CASE WHEN a.ddv_date < ISNULL(cust.val, '20500101') AND ISNULL(a.ddv_id,'')<>''  THEN 1 ELSE 0 END as print_r1, --CASE WHEN ISNULL(a.ddv_id,'') = '' THEN 0 ELSE 1 END AS Invoice,
	--CASE WHEN LTRIM(RTRIM(c.ulica)) = LTRIM(RTRIM(c.ulica_sed)) THEN 1 ELSE 0 END AS Print_C2,
	--dbo.gfn_Nacin_leas_HR(b.nacin_leas) as tip_leas, 
	A.ddv_id, A.debit, 
	A.id_rep_ind, A.ndatum,  A.nneto, A.nobresti, A.nobrok, 
	A.sneto, A.sobresti, A.sobrok, A.st_obrokov, 
	B.id_pog,
	D.naziv as naziv_ind, 
	KS.klavzula, --KS.id_klavzule,
	CASE WHEN T.id_val = 'HRK' THEN 'KN' ELSE T.id_val END AS id_val,
	case when dok_hr.id_obl_zav is null then 0 else 1 end as Print_moratorij,
	12/obd.obnaleto AS rtip_txt,
    case when c.vr_osebe in ('FO','F1') THEN 1 else 0 end as print_dani
FROM dbo.rep_ind A  
INNER JOIN dbo.pogodba B ON A.id_cont = B.id_cont
INNER JOIN dbo.tecajnic T ON T.id_tec = DBO.GFN_GETNEWTEC(A.id_tec)
INNER JOIN dbo.rtip D ON D.id_rtip = A.id_rtip
INNER JOIN dbo.obdobja obd on obd.id_obd= d.id_obdrep
INNER JOIN dbo.partner C ON B.id_kupca = C.id_kupca
--INNER JOIN dbo.tecajnic N ON N.id_tec = B.id_tec
--INNER JOIN dbo.poste E ON C.id_poste = E.id_poste
--LEFT JOIN dbo.dav_stop F ON A.id_dav_st = F.id_dav_st
--LEFT JOIN dbo.vrst_opr O ON B.id_vrste = O.id_vrste
--LEFT JOIN dbo.planp PP WITH (NOLOCK) ON a.ddv_st_dok = PP.st_dok
--LEFT JOIN dbo.custom_settings cust on cust.code = 'Nova.Reports.Print_R1'
LEFT JOIN dbo.rac_out RO ON RO.ddv_id = A.ddv_id
LEFT JOIN dbo.klavzule_sifr KS ON KS.id_klavzule = RO.id_klavzule
outer apply (select top 1 id_obl_zav, velja_do --zacetek, 
			from dbo.dokument 
			where id_obl_zav = 'HR' and status_akt = 'A' 
			and A.ndatum between zacetek and isnull(velja_do, '99991231') --velja_do je popunjena na svim dokumentima, ali nije obavezno polje pa sam ipak dodao isnull
			and id_cont = a.id_cont) dok_hr 
WHERE A.id_rep_ind in (Select max(id_rep_ind) as id_rep_ind 
						From dbo.rep_ind 
						where izpisan = 0 and datum > '20230630' 
						and id_cont = @id)