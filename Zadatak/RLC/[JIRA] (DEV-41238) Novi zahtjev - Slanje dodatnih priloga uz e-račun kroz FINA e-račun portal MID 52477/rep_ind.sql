SELECT A.id_cont, 
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
LEFT JOIN dbo.rac_out RO ON RO.ddv_id = A.ddv_id
LEFT JOIN dbo.klavzule_sifr KS ON KS.id_klavzule = RO.id_klavzule
outer apply (select top 1 id_obl_zav --, velja_do, zacetek, 
			from dbo.dokument 
			where id_obl_zav = 'HR' and status_akt = 'A' 
			and A.ndatum between zacetek and isnull(velja_do, '99991231') --velja_do je popunjena na svim dokumentima, ali nije obavezno polje pa sam ipak dodao isnull
			and id_cont = a.id_cont) dok_hr 
WHERE A.id_rep_ind in (Select max(ri.id_rep_ind) as id_rep_ind 
	From dbo.rep_ind ri
	inner join dbo.najem_fa nf on ri.id_cont = nf.id_cont
	where ri.izpisan = 0 and ri.ddv_date > '20230630' 
	and nf.ddv_id = @id) 
	/*24.10.2023 g_tomislav MID 
	Kada se za makne taj poziv @id=najem_fa.DDV_ID, i podesi se jednostavniji poziv @id_rep_ind = najem_fa.id_rep_ind (ili id_rep_ind_varchar), to isto funkcionira, ali kada se podesi Data form other sources PRVA_RATA.datum_dok_MinDate tada se podaci ne prikažu (kada se makne PRVA_RATA.datum_dok_MinDate, onda se podaci prikažu) => BUG?, pa je podešeno ovako kompliciranije. g_igorp je koristio Master component */