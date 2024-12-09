--select * from dbo.oc_reports order by id_oc_report desc
declare @id_oc_report int = 295

SELECT top 1000 occ.id_cont, occ.nacin_leas, occ.ex_nacin_leas_tip_knjizenja 
into #id_contFromOc_contracts
FROM dbo.oc_contracts occ
--inner join dbo.nacini_l nl on occ.nacin_leas = nl.nacin_leas and nl.id_oc_report = @id_oc_report
WHERE occ.id_oc_report = @id_oc_report
and occ.nacin_leas != 'TP'

SELECT id_cont, nova_test.dbo.gfn_GetOpcSt_dok(id_cont, nacin_leas) AS OpcSt_dok 
INTO #OPCST_DOKS_FL
FROM #id_contFromOc_contracts
where ex_nacin_leas_tip_knjizenja = 2

--Datum dokumenta otkupa
SELECT pp.id_cont, pp.datum_dok 
INTO #OPCST_DOKS_DATUM_DOK
FROM nova_test.dbo.planp pp
inner join #OPCST_DOKS_FL on OpcSt_dok = pp.st_dok
--WHERE EXISTS (SELECT * FROM #OpcSt_doks WHERE OpcSt_dok IS NOT NULL AND OpcSt_dok = pp.st_dok)
UNION ALL
SELECT pp.id_cont, pp.datum_dok 
FROM nova_test.dbo.planp pp
inner join #id_contFromOc_contracts ic on pp.id_cont = ic.id_cont
WHERE pp.id_terj = '23' 
and ic.ex_nacin_leas_tip_knjizenja = 1

--Datum zadnje rate za ugovore bez otkupa i s otkupom
SELECT pp.id_cont, max(pp.datum_dok) max_datum_dok 
INTO #PLANP_LOBR_MAX_DATUM_DOK
FROM nova_test.dbo.planp pp
inner join #id_contFromOc_contracts ic on pp.id_cont = ic.id_cont
WHERE NOT EXISTS (SELECT * FROM #OPCST_DOKS_DATUM_DOK WHERE OpcSt_dok = pp.st_dok)
AND pp.id_terj = '21' --sif_terj = 'LOBR' -- za svaki slučaj ako OL ima dva otkupa 
GROUP BY pp.id_cont 

select * from #OPCST_DOKS_DATUM_DOK
select * from #PLANP_LOBR_MAX_DATUM_DOK

drop table #id_contFromOc_contracts
drop table #OPCST_DOKS_FL
drop table #OPCST_DOKS_DATUM_DOK