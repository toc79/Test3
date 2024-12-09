select p.id_pog as Ugovor
	, pp.count_LOBR as Broj_rata
	, pp.max_zap_obr as Max_rata
	, DateDiff(m, Coalesce(pp.min_datum_dok_lobr, p.zac_naj), Coalesce(dateadd(m,12/obd.obnaleto,pp.max_datum_dok_lobr), p.kon_naj)) Trajanje_ROL
	, TRAJ_NAJ 
	, DateDiff(m, Coalesce(pp.min_datum_dok_lobr, p.zac_naj), Coalesce(dateadd(m,12/obd.obnaleto,pp.max_datum_dok_lobr), p.kon_naj)) c_duration
	, pp.min_datum_dok_lobr -- RLC = 13
		As startDate
	, dateadd(m,12/obd.obnaleto,pp.max_datum_dok_lobr)  -- RLC = 22
		As endDate  
	, pp.max_datum_dok_lobr zadnja_rata
	, pp.count_LOBR
	, pp.max_zap_obr
	, TRAJ_NAJ
	, p.* 
from dbo.pogodba p
Left Join dbo.obdobja obd on p.id_obd = obd.id_obd
Left Join (Select id_cont, 
				--Min(a.datum_dok) As min_datum_dok, 
				Min(Case When v.sif_terj = 'LOBR' Then a.datum_dok Else null End) As min_datum_dok_lobr,
				--Min(Case When charindex(v.sif_terj, @start_date_claims) > 0 Then a.datum_dok Else null End) As min_datum_dok_terj,
				--Max(a.datum_dok) As max_datum_dok, 
				Max(Case When v.sif_terj = 'LOBR' Then a.datum_dok Else null End) As max_datum_dok_lobr
				--Max(Case When v.sif_terj = 'LOBR' And a.obresti <> 0 Then a.datum_dok Else null End) As max_datum_dok_lobr1,
				--Max(Case When v.sif_terj = 'OPC' Then a.datum_dok Else null End) As max_datum_dok_opc, 
				--Max(Case When v.sif_terj in ('LOBR','OPC') Then a.datum_dok Else null End) As max_datum_dok_lobr_opc,
				--Max(Case When v.sif_terj = 'LOBR' Then a.dat_zap Else null End) As max_dat_zap_lobr
				, sum(Case When v.sif_terj = 'LOBR' Then 1 Else 0 End) as count_LOBR
				, Max(Case When v.sif_terj = 'LOBR' Then a.zap_obr Else null End) As max_zap_obr
				From dbo.planp a
				inner join dbo.vrst_ter v on a.id_terj = v.id_terj
				Group by a.id_cont
	) pp on p.id_cont = pp.id_cont
where status_akt in ('A', 'D') and dbo.gfn_Nacin_leas_HR(nacin_leas) = 'OL' --and PRV_OBR != 0 -- and id_obd != '001' 0 zapisa
--and DateDiff(m, Coalesce(pp.min_datum_dok_lobr, p.zac_naj), Coalesce(dateadd(m,12/obd.obnaleto,pp.max_datum_dok_lobr), p.kon_naj)) != count_LOBR -- 1 zapis
--and DateDiff(m, Coalesce(pp.min_datum_dok_lobr, p.zac_naj), Coalesce(dateadd(m,12/obd.obnaleto,pp.max_datum_dok_lobr), p.kon_naj)) != max_zap_obr -- 12 ugovora
order by p.id_cont desc