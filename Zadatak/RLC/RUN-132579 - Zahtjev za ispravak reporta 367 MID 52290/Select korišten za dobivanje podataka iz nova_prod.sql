--g_tomislav MID 39253
--Datum dokumenta predzadnje rate i otkupa 
SELECT occ.id_cont, occ.nacin_leas, occ.ex_nacin_leas_tip_knjizenja 
into #id_contFromOc_contracts
FROM dbo.oc_contracts occ
WHERE occ.id_oc_report = @id_oc_report
and occ.nacin_leas != 'TP'
and (occ.status_akt = 'A' 
	or (occ.status_akt = 'D' and occ.dat_aktiv <= @target_date) 
	or (occ.status_akt = 'N' And occ.dat_podpisa is not null And occ.dat_podpisa <= @target_date) 
	or (occ.status_akt='Z' and occ.dat_zakl>@target_date)
	)

SELECT id_cont, {9}.dbo.gfn_GetOpcSt_dok(id_cont, nacin_leas) AS OpcSt_dok 
INTO #OPCST_DOKS_FL
FROM #id_contFromOc_contracts
where ex_nacin_leas_tip_knjizenja = 2 and nacin_leas != 'OF'

--Datum dokumenta otkupa
SELECT pp.id_cont, pp.datum_dok, pp.st_dok
INTO #OPCST_DOKS_DATUM_DOK
FROM {9}.dbo.planp pp
inner join #OPCST_DOKS_FL on OpcSt_dok = pp.st_dok
UNION ALL
SELECT pp.id_cont, max(pp.datum_dok) as datum_dok, max(pp.st_dok) as datum_dok
FROM {9}.dbo.planp pp
inner join #id_contFromOc_contracts ic on pp.id_cont = ic.id_cont
WHERE pp.id_terj = '23' 
and (ic.ex_nacin_leas_tip_knjizenja = 1 or ic.nacin_leas = 'OF')
group by pp.id_cont

--Datum zadnje rate za ugovore bez otkupa i s otkupom
SELECT pp.id_cont, max(pp.datum_dok) max_datum_dok 
INTO #PLANP_LOBR_MAX_DATUM_DOK
FROM {9}.dbo.planp pp
inner join #id_contFromOc_contracts ic on pp.id_cont = ic.id_cont
WHERE NOT EXISTS (SELECT * FROM #OPCST_DOKS_DATUM_DOK WHERE st_dok = pp.st_dok)
AND pp.id_terj = '21' --sif_terj = 'LOBR' -- za svaki slučaj ako OL ima dva otkupa 
GROUP BY pp.id_cont 

drop table #OPCST_DOKS_FL

-- Broj rate iz plana otplate
SELECT pp.id_cont, count(*) st_obrok 
INTO #PLANP_ST_OBROK
FROM {9}.dbo.planp pp
inner join {9}.dbo.vrst_ter vt on pp.id_terj = vt.id_terj 
inner join (Select id_cont From dbo.oc_contracts 
			Where id_oc_report  = @id_oc_report and 
			(status_akt = 'A' 
			or (status_akt = 'D' and dat_aktiv <= @target_date) 
			or (status_akt = 'N' And dat_podpisa is not null And dat_podpisa <= @target_date) 
			or (status_akt='Z' and dat_zakl>@target_date))
) b on pp.id_cont = b.id_cont
WHERE vt.sif_terj = 'LOBR' 
GROUP BY pp.id_cont