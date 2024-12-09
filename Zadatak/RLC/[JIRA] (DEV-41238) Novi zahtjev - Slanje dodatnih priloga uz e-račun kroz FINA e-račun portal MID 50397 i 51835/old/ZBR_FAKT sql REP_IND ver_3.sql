SELECT A.id_rep_ind, A.ndatum,  A.nneto, A.nobresti, A.nobrok, 
	A.sneto, A.sobresti, A.sobrok, A.st_obrokov,
	B.id_pog, 
	C.naz_kr_kup, C.ulica, C.mesto, C.id_poste, 
	C.ulica_sed, C.id_poste_sed, C.mesto_sed, 
	D.naziv as naziv_ind, 
	CASE WHEN T.id_val = 'HRK' THEN 'KN' ELSE T.id_val END AS id_val,
	KS.klavzula, 
	dbo.gfn_Nacin_leas_HR(b.nacin_leas) as tip_leas, 
	CASE WHEN LTRIM(RTRIM(c.ulica)) = LTRIM(RTRIM(c.ulica_sed)) THEN 1 ELSE 0 END AS Print_C2,
	case when dok_hr.id_obl_zav is null then 0 else 1 end as Print_moratorij,
	12/obd.obnaleto AS rtip_txt,
    case when c.vr_osebe in ('FO','F1') THEN 1 else 0 end as print_dani
	, pp2.datum_dok
	, pp2.zap_obr
	, pp2.neto
	, pp2.marza
	, pp2.obresti
	, pp2.robresti
	, pp2.debit as debit
	, pp2.txtOpis
	, pp2.id_val as planp_id_val
	, pp2.prva_rata_datum_dok_MinDate
FROM dbo.rep_ind A  
INNER JOIN dbo.pogodba B ON A.id_cont = B.id_cont
INNER JOIN dbo.tecajnic T ON T.id_tec = DBO.GFN_GETNEWTEC(A.id_tec)
INNER JOIN dbo.partner C ON B.id_kupca = C.id_kupca
INNER JOIN dbo.rtip D ON D.id_rtip = A.id_rtip
INNER JOIN dbo.obdobja obd on obd.id_obd= d.id_obdrep
LEFT JOIN dbo.rac_out RO ON RO.ddv_id = A.ddv_id
LEFT JOIN dbo.klavzule_sifr KS ON KS.id_klavzule = RO.id_klavzule
outer apply (select top 1 id_obl_zav --, velja_do, zacetek
			from dbo.dokument 
			where id_obl_zav = 'HR' and status_akt = 'A' 
			and A.ndatum between zacetek and isnull(velja_do, '99991231') --velja_do je popunjena na svim dokumentima, ali nije obavezno polje pa sam ipak dodao isnull
			and id_cont = a.id_cont) dok_hr 
outer apply (	
	Select pp.datum_dok,
		pp.zap_obr,
		pp.neto,
		pp.marza, 
		pp.obresti,
		pp.robresti,
		pp.debit,
		--CASE WHEN pp.ST_DOK = dbo.gfn_GetOpcSt_dok(pp.id_cont, pp.nacin_leas) THEN 'OTKUPNA VRIJEDNOST OBJEKTA LEASINGA' ELSE 'RATA' END AS txtOpis,
		CASE WHEN pp.ST_DOK = dbo.gfn_GetOpcSt_dok(a.id_cont, b.nacin_leas) THEN 'OTKUPNA VRIJEDNOST OBJEKTA LEASINGA' ELSE 'RATA' END AS txtOpis,
		CASE WHEN pp.id_val = 'HRK' THEN 'KN' ELSE pp.id_val END AS id_val
		, min(pp.datum_dok) over (partition by pp.id_cont) as prva_rata_datum_dok_MinDate
	From dbo.planp pp
	Left Join dbo.vrst_ter v on pp.id_terj = v.id_terj
	Where v.sif_terj = 'LOBR' 
	and pp.datum_dok > a.ddv_date
	and	pp.id_cont = a.id_cont
	and dbo.gfn_Nacin_leas_HR(b.nacin_leas) = 'F1'
) pp2
inner join (
		select pp.id_cont, max(ri.id_rep_ind) as max_id_rep_ind --, z.id_zbirnik
		from dbo.zbirniki z
		inner join dbo.zbirniki_najem_fa znf on z.id_zbirnik = znf.id_zbirnik 
		inner join dbo.planp pp on znf.st_dok = pp.st_dok
		inner join dbo.rep_ind ri on pp.id_cont = ri.id_cont
		where ri.izpisan = 0 and ri.ddv_date >= '20230630'
		and z.id_zbirnik = @id
		group by pp.id_cont
	) can on a.ID_REP_IND = can.max_id_rep_ind 