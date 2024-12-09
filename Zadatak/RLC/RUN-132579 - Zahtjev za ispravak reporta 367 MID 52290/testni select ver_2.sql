--select * from dbo.oc_reports order by id_oc_report desc

--select * from dbo.oc_reports order by id_oc_report desc
declare @id_oc_report int = 315

DECLARE @target_date datetime
Select @target_date=date_to from dbo.gv_OcReports Where id_oc_report=@id_oc_report

SELECT top 1000 occ.id_cont, occ.nacin_leas, occ.ex_nacin_leas_tip_knjizenja 
into #id_contFromOc_contracts
FROM dbo.oc_contracts occ
WHERE occ.id_oc_report = @id_oc_report
and occ.nacin_leas != 'TP'
and (occ.status_akt = 'A' 
	or (occ.status_akt = 'D' and occ.dat_aktiv <= @target_date) 
	or (occ.status_akt = 'N' And occ.dat_podpisa is not null And occ.dat_podpisa <= @target_date) 
	or (occ.status_akt='Z' and occ.dat_zakl>@target_date)
	)

SELECT id_cont, nova_test.dbo.gfn_GetOpcSt_dok(id_cont, nacin_leas) AS OpcSt_dok 
INTO #OPCST_DOKS_FL
FROM #id_contFromOc_contracts
where ex_nacin_leas_tip_knjizenja = 2 and nacin_leas != 'OF'

--Datum dokumenta otkupa
SELECT pp.id_cont, pp.datum_dok, pp.st_dok
INTO #OPCST_DOKS_DATUM_DOK
FROM nova_test.dbo.planp pp
inner join #OPCST_DOKS_FL on OpcSt_dok = pp.st_dok
UNION ALL
SELECT pp.id_cont, max(pp.datum_dok) as datum_dok, max(pp.st_dok) as datum_dok
FROM nova_test.dbo.planp pp
inner join #id_contFromOc_contracts ic on pp.id_cont = ic.id_cont
WHERE pp.id_terj = '23' 
and ic.ex_nacin_leas_tip_knjizenja = 1 or ic.nacin_leas = 'OF'
group by pp.id_cont

--Datum zadnje rate za ugovore bez otkupa i s otkupom
SELECT pp.id_cont, max(pp.datum_dok) max_datum_dok 
INTO #PLANP_LOBR_MAX_DATUM_DOK
FROM nova_test.dbo.planp pp
inner join #id_contFromOc_contracts ic on pp.id_cont = ic.id_cont
WHERE NOT EXISTS (SELECT * FROM #OPCST_DOKS_DATUM_DOK WHERE st_dok = pp.st_dok)
AND pp.id_terj = '21' --sif_terj = 'LOBR' -- za svaki slučaj ako OL ima dva otkupa 
GROUP BY pp.id_cont 

select * from #OPCST_DOKS_DATUM_DOK
select * from #PLANP_LOBR_MAX_DATUM_DOK

drop table #id_contFromOc_contracts
drop table #OPCST_DOKS_FL
drop table #OPCST_DOKS_DATUM_DOK
drop table #PLANP_LOBR_MAX_DATUM_DOK